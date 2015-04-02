%MACRO STRING 2
     %strlen charcnt %2
         
     STRUC %1_STRING_STRUC
          .value:        resb      charcnt              ; the bytes in the string
          .size:         resq      1
          .Write:        resq      1
          .WriteLn:      resq      1
     ENDSTRUC
     
     [section .data]
     %1: ISTRUC %1_STRING_STRUC
          at  %1_STRING_STRUC.value,       db %2
          at  %1_STRING_STRUC.size,        dq charcnt
          at  %1_STRING_STRUC.Write,       dq write_string
          at  %1_STRING_STRUC.WriteLn,     dq writeln_string
     IEND
     
     %define   %1.address          %1+%1_STRING_STRUC.value                     ; the address where the string is stored
     %define   %1.size             QWORD[%1+%1_STRING_STRUC.size]               ; the value, not the address
     %define   %1.Write            QWORD[%1+%1_STRING_STRUC.Write]              ; the value, not the address
     %define   %1.WriteLn          QWORD[%1+%1_STRING_STRUC.WriteLn]            ; the value, not the address
%ENDM

     ; for syscalls and stdout
     [list -]
     %include "unistd.inc"
     [list +]    
     
BITS 64

section .bss

section .data
       
    STRING    a,"This is the string you want to store"
    STRING    b,{"and"}
    
    linefeed:  db   10
    .length:   equ  $-linefeed
    
section .text
    global _start
_start:
       
    mov   rsi, a.address
    mov   rdx, a.size
    call  a.WriteLn
    
    mov   rsi, b.address
    mov   rdx, b.size
    call  b.WriteLn
      
    xor   rdi, rdi
    mov   rax, SYS_EXIT
    syscall

writeln_string:
     call      write_string
     mov       rsi, linefeed
     mov       rdx, linefeed.length
     call      write_string
     ret
     
write_string:
    mov   rdi, STDOUT
    mov   rax, SYS_WRITE
    syscall
    ret