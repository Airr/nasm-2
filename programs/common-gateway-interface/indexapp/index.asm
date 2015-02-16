; index cgi application

BITS 64
ALIGN 8

[list -]
      %include "syscalls.inc"
      %include "termio.inc"
[list +]
      
section .bss

      heapstart:        resq 1
           
section .data
      message:          db  "Content-type: text/html",10,10
                        db  "<pre>Agguro localhost index cgi</pre>"
      .length:          equ $-message
      
section .text
        global _start       
_start:
        mov     rsi, message
        mov     rdx, message.length
        xor     rdi, rdi
        inc     rdi                             ; short method for rdi = STDOUT
        mov     rax, rdi                        ; rax = syscall write
        syscall
        
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall