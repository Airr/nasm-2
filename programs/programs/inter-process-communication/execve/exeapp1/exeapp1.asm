; Name:         exeapp1.asm
; Build:        see makefile
; Run:          ./exeapp1
; Description:  First demonstration on how to execute a program or shell script from within an
;               assembler program. Assumed is that the 'hello' program is present and that you
;               know the path to it.
;               If everything behaves, the child exits after the execution of the child process (the hello application)
;               make sure that hello is executable or no messages will be displayed at all.

BITS 64

[list -]
        %include "unistd.inc"
[list +]

section .data
        
     filename:      db   "hello",0          ; full path!
     .length:       equ  $-filename
     ; argument pointer list to pass to the application to be executed, terminated by NULL
     argvPtr:       dq   filename           ; this is not a must but some programs (nasm for example) requires it.
                                            ; remark this line and change hello in /usr/bin/nasm for a demonstration.
                    dq   0   
     envPtr:        dq   0                  ; pointer to environment parameters
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
     
