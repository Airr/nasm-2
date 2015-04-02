; Name:         pipedemo5.asm
;
; Source : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/pipes.html
;
; August 24, 2014 : assembler 64 bits version
;
; Description:
; A demonstration on pipes and fork based on an example from Beej's Guide to IPC
;
; Disclaimer:
; GNU GENERAL PUBLIC LICENSE 3 
 
BITS 64
 
[list -]
    %include "unistd.inc"
[list +]

    %define         DATA    "test"
        
section .bss
    ; pdfs
    pdfs:
    .0:             resd    1
    .1:             resd    1
 
section .data

    data:           db      DATA
    .length:        equ     $-data
  
    Child:
    .msg1:          db      " CHILD: writing to the pipe", 10
    .msg1.length:   equ     $-Child.msg1
    .msg2:          db      " CHILD: exiting", 10
    .msg2.length:   equ     $-Child.msg2
    
    Parent:
    .msg1:          db      "PARENT: reading from pipe", 10
    .msg1.length:   equ     $-Parent.msg1
    .msg2:          db      "PARENT: read ", 0x22
    .buffer:        times   data.length db 0
                    db      0x22, 10
    .msg2.length:   equ     $-Parent.msg2                    
    
    pipeerror:      db      "Pipe error"
    .length:        equ     $-pipeerror
    
    forkerror:      db      "Fork error"
    .length:        equ     $-forkerror
    
section .text
    global _start

_start:
    
    ; create pipe, pdfs is an array to the READ and WRITE ends of the pipe
    mov         rdi, pdfs                                       ; create pipe
    mov         rax, SYS_PIPE
    syscall
    and         rax, rax
    js          Error.Pipe   
      
    ; fork the process
    mov         rax, SYS_FORK
    syscall
    and         rax, rax
    js          Error.Fork
    jnz         ParentProcess
    
    ; write message msg1
    mov         rsi, Child.msg1
    mov         rdx, Child.msg1.length
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall
    
    ; write to the pipe
    mov         edi, DWORD[pdfs.1]
    mov         rsi, data
    mov         rdx, data.length
    mov         rax, SYS_WRITE
    syscall
    
    ; write message msg2
    mov         rsi, Child.msg2
    mov         rdx, Child.msg2.length
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall
    
    jmp         Exit
    
ParentProcess:    
    ; write output with buffer to STDOUT
    mov         rsi, Parent.msg1
    mov         rdx, Parent.msg1.length
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall

    ; read from pipe
    mov         edi, DWORD[pdfs.0]
    mov         rsi, Parent.buffer
    mov         rdx, data.length
    mov         rax, SYS_READ
    syscall
    
    ; write output with buffer to STDOUT
    mov         rsi, Parent.msg2
    mov         rdx, Parent.msg2.length
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall

    ; wait for child to terminate
    mov         rcx, 0
    mov         rdx, 0
    mov         rsi, 0
    mov         rdi, 0                              ; wait for all childs
    mov         rax, SYS_WAIT4                      ; wait for child to terminate
    syscall
    
    jmp         Exit
    
Error:
.Fork:
    mov         rsi, forkerror
    mov         rdx, forkerror.length
    jmp         Write
.Pipe:
    mov         rsi, pipeerror
    mov         rdx, pipeerror.length
Write:    
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall

Exit:      
    xor         rdi, rdi
    mov         rax, SYS_EXIT
    syscall
      
