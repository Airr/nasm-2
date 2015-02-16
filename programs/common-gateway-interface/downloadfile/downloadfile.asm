;***********************************************************************************************
; Name:		cgi-download.asm
; Build:	see makefile
; Description:	cgi program to download a file (logo.png in this example).
; Remarks:	putting a link in a webpage does the same with less effort. The disadvantage is
;		that the file to download must be in the http-root directory to be accessable.
;		a additional directory need to be created ("downloads") where the file ("logo.png"
;		must be reside in or the program ends in error because the file isn't found.
;		The program, however, ends with a general error message for all errors.
;***********************************************************************************************

%include "syscalls.inc"
%include "termio.inc"
%include "fileio.inc"

BITS 64

section .bss
      memalloc:	resq	1	; pointer to memory break
      fd:	resq	1	; filedescriptor
      
section .data

      httpheader:	db	'Content-type: application/octet-stream', 10
			db	'Content-Disposition: attachment; filename="logo.png"', 10, 10
      .length:		equ	$-httpheader
      response:		db	'Content-type: text/html', 10, 10
			db	'<span>Something went wrong, or file not found or the server ran out of memory</span>', 10
      .length:		equ 	$-response
      filename:		db	'../downloads/logo.png',0
  
      STAT stat		; STAT structure instance for FSTAT syscall
       
section .text
        global _start
_start:
     
	; open the file and get filedescriptor
	mov	rdi, filename
	mov	rsi, O_RDONLY
	mov	rax, SYS_OPEN
	syscall
	cmp	rax, 0
	jl	error				; Error, file doesn't exists
	mov	QWORD[fd], rax			; save filedescriptor
      
	; read the filesize
	mov	rdi, QWORD[fd]
	mov	rsi, stat
	mov	rax, SYS_FSTAT
	syscall
      
	; get memory break
	mov	rdi, 0
	mov	rax, SYS_BRK
	syscall
      
	cmp	rax, 0
	jle	error				; no memory available to allocate
      
	mov	QWORD[memalloc], rax		; save pointer to memory break
	add	rax, QWORD[stat.st_size]	; add filesize to allocate memory
      
	; try to allocate additional memory
	mov	rdi, rax
	mov	rax, SYS_BRK
	syscall
	cmp	rax, rdi			; new memory break equal to calculated one?
	jne	error				; not enough memory available
           
      ; read the file in the allocated memory
	mov	rdi, QWORD[fd]
	mov	rsi, QWORD[memalloc]
	mov	rdx, QWORD[stat.st_size]	; bytes to read
	mov	rax, SYS_READ
	syscall

	; close the file
	mov	rdi, QWORD[fd]
	mov	rax, SYS_CLOSE
	syscall

	; write the HTTP header
	mov	rdi, STDOUT
	mov	rsi, httpheader
	mov	rdx, httpheader.length
	mov	rax, SYS_WRITE
	syscall
	; write the filecontents
	mov	rdi, STDOUT
	mov	rsi, QWORD[memalloc]
	mov	rdx, QWORD[stat.st_size]
	mov	rax, SYS_WRITE
	syscall
      
	; release allocated memory
	mov	rdi, QWORD[memalloc]
	mov	rax, SYS_BRK
	syscall
exit:      
	; exit the program
	xor	rdi, rdi
	mov	rax, SYS_EXIT
	syscall
      
error:
	mov	rdi, STDOUT
	mov	rsi, response
	mov	rdx, response.length
	mov	rax, SYS_WRITE
	syscall
	jmp	exit
