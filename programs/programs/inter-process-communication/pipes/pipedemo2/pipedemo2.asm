; Name:         pipedemo2.asm
; Build:        see makefile
; Run:          ./pipedemo2
; Description:  Same program as pipedemo1, but this time with Fork.
;               The child writes the messages to the pipe. The parent will read the messages
;               from the read-end of the pipe and displays them.

BITS 64

[list -]
    %include "unistd.inc"
[list +]

section .bss
        
     p0:         resd    1                               ; STDIN
     p1:         resd    1                               ; STDOUT
     inbuf:      resb    childmsg.length*3
        
section .data
        
     childmsg:   db      "hello #1",0x0A
     .length:    equ     $-childmsg
     parentmsg:  db      "Parent received: ",0x0A
     .length:    equ     $-parentmsg
     pipeerror:  db      "pipe call error"
     .length:    equ     $-pipeerror
     forkerror:  db      "fork error"
     .length:    equ     $-forkerror
        
section .text
      global _start
        
_start:

      ; open pipê
      mov       rdi, p0
      mov       rax, SYS_PIPE
      syscall
      jns       fork
      
      mov       rsi, pipeerror
      mov       rdx, pipeerror.length
      mov       rdi, STDOUT
      mov       rax, SYS_WRITE
      syscall
      jmp       exit
      
fork:
      ; fork the process
      mov       rax, SYS_FORK
      syscall
      and       rax, rax
      jz        parent
      jnz       child
      
      mov       rsi, forkerror
      mov       rdx, forkerror.length
      mov       rdi, STDOUT
      mov       rax, SYS_WRITE
      syscall
      
      jmp       exit
      
; write down pipe
child:
      ; close the read end of the pipe
      mov       edi, DWORD[p0]
      mov       rax, SYS_CLOSE
      syscall
      ; write the messages
      mov       edi, DWORD[p1]
      mov       rsi, childmsg
      mov       rdx, childmsg.length                   ; we will write the same text 3 times, modifying the # each time
                                                       ; so we will write hello #1,0x0A,hello #2,0x0A,hello #3,0x0A to the write-end of the pipe.
      mov       rax, SYS_WRITE
      syscall
      inc       BYTE[childmsg+childmsg.length-2]
      mov       rax, SYS_WRITE
      syscall
      inc       BYTE[childmsg+childmsg.length-2]
      mov       rax, SYS_WRITE
      syscall
      jmp       exit
      
; parent reads pipe
parent:            
      ; close the write end of the pipe
      mov       edi, DWORD[p1]
      mov       rax, SYS_CLOSE
      syscall      
@1:      
      ; read pipe into buffer
      mov       edi, DWORD[p0]
      mov       rsi, inbuf
      mov       rdx, childmsg.length*3
      mov       rax, SYS_READ
      syscall
      
      ; write 'parent' message to STDOUT
      mov       rdx, parentmsg.length
      mov       edi, STDOUT
      mov       rsi, parentmsg
      mov       rax, SYS_WRITE
      syscall
      ; write buffer to STDOUT
      mov       rdx, childmsg.length*3
      mov       edi, STDOUT
      mov       rsi, inbuf
      mov       rax, SYS_WRITE
      syscall
      ; wait for the child
      xor       rdi, rdi
      xor       rsi, rsi
      xor       rdx, rdx
      xor       rcx, rcx
      mov       rax, SYS_WAIT4
      syscall
      ; and exit      
exit:      
      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall