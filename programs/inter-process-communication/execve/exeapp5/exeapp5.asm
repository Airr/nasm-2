; Name:         exeapp3.asm
; Build:        see makefile
; Run:          ./exeapp3
; Description:  Demonstration on how to execute a bash script from a program.
;               The program starts the sh command and executes a script named test.
;
; More info:    http://geoffgarside.co.uk/2009/08/28/using-execve-for-the-first-time/
;
; Remark:       Before running this tiny program, you have to run (only once) the following command in your terminal:
;               echo "echo 'hello world'" > test
;               or you make your own test script which the program then executes.

BITS 64

[list -]
        %include "errors.inc"
        %include "unistd.inc"
[list +]

section .bss

section .data
        
filename    db      "/usr/bin/nasm",0             ; full path!

;argv1       db      "2", 0;                                      ; "test.sh", 0            ; script to execute
;argv2       db      "mmap", 0

;... put more arguments here

envp1       db      "DISPLAY=:0",0
envp2       db      "SHELL=/bin/bash",0
envp3:      db      "TERM=xterm",0
    
argvPtr :   dq      filename
            ;dq      argv1
            ;dq      argv2
            ;dq      0
            ; more pointers to arguments here
            dq      0                               ; terminate the list of pointers with NULL

envPtr:      ;dq      envp1
            ;dq      envp2
            ;dq      envp3
            dq      0
        
section .text

global _start
_start:

      mov       rdx, envPtr             ; no environment pointers
      mov       rsi, argvPtr            ; pointer to array with arguments
      mov       rdi, filename           ; ponter to the command to execute
      mov       rax, SYS_EXECVE         ; syscall execute
      syscall
      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall