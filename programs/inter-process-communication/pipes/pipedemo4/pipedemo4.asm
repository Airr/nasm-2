; Name:         pipedemo4.asm
;
; Source : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/pipes.html
;
; August 24, 2014 : assembler 64 bits version
;
; Description:
; A demonstration on pipes based on an example from Beej's Guide to IPC
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

    msg1:           db      "writing to file descriptor #"
    .length:        equ     $-msg1
    
    .pdf1:          times   10 db 0                            ; max size of DWORD
                    db      0
    
    msg2:           db      "reading from file descriptor #"
    .length:        equ     $-msg2
  
    .pdf0:          times   10 db 0                            ; max size of DWORD
                    db      0

    data:           db      DATA
    .length:        equ     $-data
  
    msg3:           db      "read ", 0x22                   ; ASCII for "
    .buffer:        times   data.length db 0
                  db      0x22, 10
    .length:        equ     $-msg3
  
    pipeerror:      db      "pipe call error"
    .length:        equ     $-pipeerror
 
section .text
    global _start

_start:
    
    ; create pipe, pdfs is an array to the READ and WRITE ends of the pipe
    mov         rdi, pdfs                                       ; create pipe
    mov         rax, SYS_PIPE
    syscall
    jns         startpipe                                       ; if RAX < 0 then error
    
    mov         rsi, pipeerror
    mov         rdx, pipeerror.length
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall
    jmp         Exit
      
startpipe:
    ; prepare messages to be displayed with one syscall
    xor         rax, rax
    mov         eax, DWORD[pdfs.0]
    call        Hex2Dec
    mov         rdi, msg2.pdf0
    call        StoreDecimal
    add         rdx, msg2.length
    mov         BYTE[rdi], 10                                   ; EOL behind the decimal
    inc         rdx                                             ; adjust length of decimal
    mov         r14, rdx                                        ; R14 is length of msg2
    
    xor         rax, rax
    mov         eax, DWORD[pdfs.1]
    call        Hex2Dec
    mov         rdi, msg1.pdf1
    call        StoreDecimal
    add         rdx, msg1.length
    mov         BYTE[rdi], 10                                   ; EOL behind the decimal
    inc         rdx                                             ; adjust length of decimal
    mov         r15, rdx                                        ; R15 is length of msg1

    ; write message msg1
    mov         rsi, msg1
    mov         rdx, r15
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
    mov         rsi, msg2
    mov         rdx, r14
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall
    
    ; read from pipe
    mov         edi, DWORD[pdfs.0]
    mov         rsi, msg3.buffer
    mov         rdx, data.length
    mov         rax, SYS_READ
    syscall
    
    ; write output with buffer to STDOUT
    mov         rsi, msg3
    mov         rdx, msg3.length
    mov         rdi, STDOUT
    mov         rax, SYS_WRITE
    syscall
      
Exit:      
    xor         rdi, rdi
    mov         rax, SYS_EXIT
    syscall
      
Hex2Dec:
    ; r10:r9:r8 = decimal(rax)
    xor         r10, r10                ; R10:R9:R8 will hold the decimal value of RAX
    xor         r9, r9                  
    xor         r8, r8
    mov         rbx, 10                 ; base 10 for decimal
    clc
.repeat:        
    xor         rdx, rdx                ; clear remainder register
    idiv        rbx
    or          dl, "0"
    mov         rcx, 8
.shift:        
    rcr         dl, 1                   ; rotate ASCII decimal in R10:R9:R8
    rcr         r10, 1
    rcr         r9, 1
    rcr         r8, 1
    dec         rcx
    and         rcx, rcx
    jnz         .shift
    and         rax, rax                ; if quotient is zero, nothing to be done anymore
    jnz         .repeat                 ; if not repeat procedure
    ret

StoreDecimal:
    ; RDI = pointer to buffer
    ; R10:R9:R8 = decimal value in ASCII
    ; return:
    ; RDX = length of decimal number
    ; RDI = offset to byte right after the stored integer
    
    clc
    xor         rdx, rdx
.repeat:
    inc         rdx
    mov         rcx, 8
.shift:        
    rcl         r8, 1
    rcl         r9, 1
    rcl         r10, 1
    rcl         rax, 1
    dec         rcx
    and         rcx, rcx
    jnz         .shift
    and         al, al
    jz          .done
    stosb
    jmp         .repeat
.done:
    dec         rdx
    ret