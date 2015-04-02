; Name: sleep.asm
; Build: see makefile or
; Description:  running the program will delay for 5 seconds
;               This program can be extended with the use of a signal to prematurely interrupt the
;               nanosleep syscall. (in case you should set it to sleep for several hours, and by passing
;               the 'sleeping' time as an argument. (see linux sleep command).

[list -]
     %include "unistd.inc"
     %include "time.inc"
[list +]

     %define SECONDS         5
     %define NANOSECONDS     0

bits 64

section .bss
    
section .data

     msgSleeping:   db   'sleeping for 5 seconds...', 10
     .length:       equ  $-msgSleeping
     msgAwake:      db   'back up and running.', 10
     .length:       equ  $-msgAwake
    
     TIMESPEC timer

section .text
     global _start
    
_start:
     mov       QWORD [timer.tv_sec], SECONDS
     mov       QWORD [timer.tv_nsec], NANOSECONDS

     mov       rsi, msgSleeping
     mov       rdx, msgSleeping.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall

     mov       rdi, QWORD timer
     xor       rsi, rsi
     mov       rax, SYS_NANOSLEEP
     syscall

     mov       rsi, msgAwake
     mov       rdx, msgAwake.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall

     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall