; Name:         exeapp4.asm
; Build:        see makefile
; Run:          ./exeapp4
; Description:  Demonstration on how to execute a program / shell script from within an assembler program.
;               Let's make ourself an application that directly opens our favorite website with just a mouseclick in
;               our favorite webbrowser.
;               We need to define the DISPLAY parameter to tell the application to which display we need to write it.
;
; More info:    http://geoffgarside.co.uk/2009/08/28/using-execve-for-the-first-time/
;
; Remarks:      Passing arguments more than the url via the arguments list doesn't have any effect, however when we add
;               the options in the command string, we can run firefox in a new tab like I would.
;               Problem solved.
;
; Todo:         - extend the program to check wether the user runs in a textbased or gui-based terminal and apply the right browser.
;               - config file to read favorite browser

BITS 64

[list -]
        %include "unistd.inc"
[list +]

%define FAVO_BROWSER    "firefox"
%define FAVO_SITE       "http://www.agguro.be"

section .data
        
    filename:      db    "/usr/bin/",FAVO_BROWSER,0        ; full path!
    .length:       equ   $-filename
    command:       db    FAVO_BROWSER, " -new-tab", 0      ; do not forget the space before -new-tab
    
    argv1:         db    FAVO_SITE, 0                      ; argument to pass
    ;... put more arguments here

    envp1:         db    "DISPLAY=:0",0                    ; environment parameter, if you forget this then
                                                           ; Error: no display specified will be displayed
    envp2:         db    "PATH=/usr/bin",0                                        
    argvPtr:       dq    command                           ; argument list
                   dq    argv1
                   dq    0                    
    envPtr:        dq    envp1                             ; environment parameter list
                   dq    envp2
                   dq    0
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
     mov     rdx, envPtr             ; no environment pointers
     mov     rsi, argvPtr            ; pointer to array with arguments
     mov     rdi, filename           ; ponter to the command to execute
     mov     rax, SYS_EXECVE         ; syscall execute
     syscall
     xor     rdi, rdi
     mov     rax, SYS_EXIT
     syscall