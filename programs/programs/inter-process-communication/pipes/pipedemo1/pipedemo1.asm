; Name:         pipedemo1.asm
; Build:        see makefile
; Run:          ./pipedemo1
 
BITS 64
 
[list -]
     %include "unistd.inc"
[list +]

%define MSGSIZE  8

section .bss
 
     p0:             resd    1                         ; new STDIN
     p1:             resd    1                         ; new STDOUT
     inbuf:          resb    MSGSIZE
 
section .data

     msg1:           db      "hello #1"
     msg2:           db      "hello #2"
     msg3:           db      "hello #3"
     EOL:            db      10
     pipeerror:      db      "pipe call error"
     .length:        equ     $-pipeerror
 
section .text
     global _start

_start:
 
     mov       rdi, p0                 ; create pipe
     mov       rax, SYS_PIPE           ; 
     syscall
     and       rax, rax
     jns       startpipe               ; if RAX < 0 then error
     
     mov       rsi, pipeerror
     mov       rdx, pipeerror.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     jmp       exit
      
startpipe:      
     mov       rsi, msg1               ; write msg1 to the pipe
     mov       rdx, MSGSIZE
     mov       edi, DWORD[p1]
     mov       rax, SYS_WRITE
     syscall
     mov       rsi, msg2               ; write msg2 to the pipe
     mov       rdx, MSGSIZE
     mov       edi, DWORD[p1]
     mov       rax, SYS_WRITE
     syscall
     mov       rsi, msg3               ; write msg3 to the pipe
     mov       rdx, MSGSIZE
     mov       edi, DWORD[p1]
     mov       rax, SYS_WRITE
     syscall

     xor       r8, r8                  ; init loopcounter
@1:      
     mov       rsi, inbuf              ; read MSGSIZE bytes from the pipe
     mov       rdx, MSGSIZE            ; into the buffer
     mov       edi, DWORD[p0]
     mov       rax, SYS_READ
     syscall
     
     mov       rdx, MSGSIZE            ; n bytes read, must be MSGSIZE
     mov       rsi, inbuf              ; write buffer to STDOUT
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     mov       rsi, EOL                ; write '\n' to STDOUT
     xor       rdx, rdx
     inc       rdx
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     inc       r8
     cmp       r8, 3
     jl        @1                      ; repeat 2 more times
      
exit:      
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall