;***********************************************************************************************
; Name:     simpledownload.asm
; Build:    see makefile
; Description:
;   Demonstration of a simple downloadable file, the contents of the file are within the
;   program (simple hello world!! message)
;***********************************************************************************************

BITS 64

section .bss

section .data

    filedownload:
          db    'Content-type: application/octet-stream',10
          db    'Content-Disposition: attachment',59,'filename="hello.txt"',10,10
          ; contents of the file to download
          db    'Hello world!!',10
        .length: equ $-filedownload

section .text
    global _start
    
_start:

    mov rax, 1                          ; SYS_WRITE
    mov rsi, filedownload
    mov rdx, filedownload.length
    mov rdi, 1                          ; STDOUT
    syscall
    
    mov rdi, 0                          ; no errors
    mov rax, 60                         ; SYS_EXIT
    syscall
