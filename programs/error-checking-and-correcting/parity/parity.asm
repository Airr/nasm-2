; parity.asm
; calculate parity bit
;
; Source: Hacker's Delight - 5.2 page 98
 
[list -]
      %include "unistd.inc"
[list +]
 
bits 64
 
section .bss
     buffer: resb 1
 
section .data
     message:           db   " has parity "
     .length:           equ  $-message
     .odd:              db   "odd"
     .odd.length:       equ  $-message.odd
     .even:             db   "even"
     .even.length:      equ  $-message.even
     .end:              db   ".", 0x0A
     .end.length:       equ  $-message.end
      
section .text
     global _start
 
_start:
 
     mov       rax, 123643
     call      printBinary
     call      parity
     push      rax
     mov       rsi, message
     mov       rdx, message.length
     call      print
     pop       rax
     and       rax, rax
     jnz       oddparity
     mov       rsi, message.even
     mov       rdx, message.even.length
     jmp       write
oddparity:
     mov       rsi, message.odd
     mov       rdx, message.odd.length
write:      
     call      print
     mov       rsi, message.end
     mov       rdx, message.end.length      
     call      print
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall
 
parity:                                            ; calculate parity bit 0 = even, 1 is odd
     mov       rcx, 32
repeat:      
     mov       rbx, rax
     shr       rbx, cl
     xor       rax, rbx
     shr       rcx, 1
     cmp       rcx, 0
     jne       repeat
     and       rax, 1                             ; rightmost bit is parity bit
     ret

printBinary:
     push      rax
     mov       rcx, 64                 ; 64 bits to display
     clc                               ; clear carry flag
.repeat:
     rcl       rax, 1                  ; start with leftmost bit
     adc       BYTE[buffer],0x30       ; make it ASCII
     push      rcx
     push      rax
     call      printBuffer
     pop       rax
     pop       rcx
     loop      .repeat
     pop       rax
     ret
 
printBuffer:
     mov       rsi, buffer
     mov       rdx, 1
print:      
     mov       rax, SYS_WRITE
     mov       rdi, STDOUT
     syscall
     and       BYTE[buffer],0          ; clear buffer
     ret