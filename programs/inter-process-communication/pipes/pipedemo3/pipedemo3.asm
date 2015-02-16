; Name:         pipedemo3.asm
; Build:        see makefile
; Run:          ./pipedemo3

BITS 64

[list -]
        %include "unistd.inc"
        %define CHARSTOREAD  8                         ; don't make this bigger than 9
[list +]

section .bss

        p0:             resd    1                               ; STDIN
        p1:             resd    1                               ; STDOUT
        buffer:         resb    20

section .data

        message:        db      "One of the fundamental features that makes Linux and other Unices useful is the 'pipe'."
                        db      "Pipes allow separate processes to communicate without having been designed explicitly "
                        db      "to work together. This allows tools quite narrow in their function to be combined in complex ways."
        .length:        equ     $-message
        out1:
        .nchars:        db      "  chars | "
        .length:        equ     $-out1
        out2:           db      " | received by child",10
        .length:        equ     $-out2

        pipeerror:      db      "pipe error"
        .length:        equ     $-pipeerror
        forkerror:      db      "fork error"
        .length:        equ     $-forkerror
        childfailed:    db      "Child failed",10
        .length:        equ     $-childfailed
        childsucces:    db      "Child finished",10
        .length:        equ     $-childsucces

section .text

global _start
_start:

      mov       rdi, p0
      mov       rax, SYS_PIPE
      syscall
      js        error.pipe

      ; fork the process
      mov       rax, SYS_FORK
      syscall
      cmp       rax, 0
      je        parent
      jl        error.fork
;------------------------------------------------------
; child process
;------------------------------------------------------
child:

      xor       rdi, rdi
      ; close the write end of the pipe
      mov       edi, DWORD[p1]
      mov       rax, SYS_CLOSE
      syscall
      ; now read the messages from the pipe

readBytes:

      mov       edi, DWORD[p0]
      mov       rsi, buffer
      mov       rdx, CHARSTOREAD
      mov       rax, SYS_READ
      syscall
      mov       r8, rax                         ; nchars read
      cmp       rax, 0                          ; have we read any bytes?
      je        .closePipe                      ; if all bytes read, then close pipe and exit
      ; convert AL to ASCII
      add       al, 0x30
      mov       BYTE[out1.nchars], al

      ; now write the message, store rax in r8
      ; first print the first part
      mov       rdi, STDOUT
      mov       rsi, out1
      mov       rdx, out1.length
      mov       rax, SYS_WRITE
      syscall
      
      ; then print the buffer contents
      mov       rdi, STDOUT
      mov       rsi, buffer
      mov       rdx, r8                         ; nchars
      mov       rax, SYS_WRITE
      syscall
      
      ; write the last part of the message
      mov       rdi, STDOUT
      mov       rsi, out2
      mov       rdx, out2.length
      mov       rax, SYS_WRITE
      syscall
      
      ; sync STDOUT 
      mov       rdi, STDOUT                     ; in an attempt not to write on the command prompt
      mov       rax, SYS_FSYNC                  ; possibly not the right way to flush STDOUT
      syscall
           
      jmp       readBytes
      ; close the pipe
.closePipe:
      mov       edi, DWORD[p0]
      mov       rax, SYS_CLOSE
      syscall

      ; and exit
      jmp       exit

;------------------------------------------------------
; parent process
;------------------------------------------------------
parent:

      ; close the read end of the pipe
      mov       edi, DWORD[p0]
      mov       rax, SYS_CLOSE
      syscall

      ; write the message to the pipe
      mov       edi, DWORD[p1]
      mov       rsi, message
      mov       rdx, message.length
      mov       rax, SYS_WRITE
      syscall

      ; close the pipe
      mov       edi, DWORD[p1]
      mov       rax, SYS_CLOSE
      syscall

      ; wait for the child
      mov       rdi, 0
      mov       rsi, 0
      mov       rdx, 0
      mov       rcx, 0
      mov       rax, SYS_WAIT4
      syscall
      and       rax, rax
      jz        error.childFailed
      
      ; following message can be on screen before the child's output has finished
      mov       edi, STDOUT
      mov       rsi, childsucces
      mov       rdx, childsucces.length
      mov       rax, SYS_WRITE
      syscall
      
      jmp       exit
error:
.pipe:
      mov       rsi, pipeerror
      mov       rdx, pipeerror.length
      jmp       error.write

.fork:
      mov       rsi, forkerror
      mov       rdx, forkerror.length
      jmp       error.write

.childFailed:
      mov       rsi, childfailed
      mov       rdx, childfailed.length

.write:
      mov       rdi, STDERR
      mov       rax, SYS_WRITE
      syscall

exit:
      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall
