; Name:         exeapp3.asm
; Build:        see makefile
; Run:          ./exeapp3
; Description:  Demonstration on how to execute a bash script from a program and the environment parameters.

BITS 64

[list -]
        %include "unistd.inc"
[list +]

section .data
     filename:      db   "test.sh",0             ; full path!
     .length:       equ  $-filename
     
     ;... put more arguments here

     envp1:         db   "PATH=/usr/bin",0
     envp2:         db   "TESTVAR=123456",0
     
     
     argvPtr:       dq   filename
                    ; more pointers to arguments here
                    dq      0                               ; terminate the list of pointers with NULL

     envPtr:        dq   envp1
                    dq   envp2
                    dq   0
        
     forkerror:     db   "fork error", 10
     .length:       equ  $-forkerror
     execveerror:   db   "return not expected -> execve error for command: "
     .length:       equ  $-execveerror
    
section .text
     global _start

_start:

     mov       rax, SYS_FORK
     syscall
     and       rax, rax
     js        Error.Fork
     jnz       ParentProcess
     
ChildProcess:
       
     mov       rdx, envPtr             ; pointer to environment
     mov       rsi, argvPtr            ; array with arguments
     mov       rdi, filename           ; the command
     mov       rax, SYS_EXECVE         ; syscall execute
     syscall
     
ParentProcess:
     ; wait for child to terminate
     mov       rcx, 0
     mov       rdx, 0
     mov       rsi, 0
     mov       rdi, 0                  ; wait for all childs
     mov       rax, SYS_WAIT4          ; wait for child to terminate
     syscall
Exit:
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall
     
Error.Fork:
     mov       rsi, forkerror
     mov       rdx, forkerror.length
     call      Write
     jmp       Exit
     
Error.Execve:
     mov       rsi, execveerror
     mov       rdx, execveerror.length
     call      Write
     mov       rsi, filename
     mov       rdx, filename.length
     mov       byte[rsi+rdx-1], 10     ; change trailing zero into EOL
     call      Write
     jmp       Exit
     
Write:     
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     ret