; Name:         pipedemo6.asm
;
; Source : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/pipes.html
;
; August 24, 2014 : assembler 64 bits version
;
; Description:
; A demonstration on pipes and fork based on an example from Beej's Guide to IPC
; executes ls | wc -l
;
; Disclaimer:
; GNU GENERAL PUBLIC LICENSE 3 
 
BITS 64
 
BITS 64
 
[list -]
        %include "unistd.inc"
[list +]
 
section .bss
 
section .data

    pdfs:
    .stdin:         dd      0                                  ; STDIN
    .stdout:        dd      0                                  ; STDOUT
    
    Child.Cmd:
    .filename       db      "/bin/ls",0                        ; full path! 
    .argvPtr        dq      Child.Cmd.filename
    ; to save space the end of argvPtr list is the same as the end of the envPtr list
    .envPtr         dq      0                                  ; terminate the list of pointers with NULL

    Parent.Cmd:
    .filename       db      "/usr/bin/wc",0                    ; again full path!
    .argv1          db      "-l", 0                            ; argument to pass
    .argvPtr        dq      Parent.Cmd.filename
                    dq      Parent.Cmd.argv1
    ; to save space the end of argvPtr list is the same as the end of the envPtr list
    .envPtr         dq      0                                  ; terminate the list of pointers with NULL
    
    errorexecve:    db      "execve error", 10
    .length:        equ     $-errorexecve
    errorfork:      db      "fork error", 10
    .length:        equ     $-errorpipe
    errorpipe:      db      "pipe error", 10
    .length:        equ     $-errorpipe
    
section .text
 
global _start
_start:

    ; create pipe
    mov       rdi, pdfs
    mov       rax, SYS_PIPE
    syscall
    and       rax, rax
    js        Error.PIPE
    
    ; fork child
    mov       rax, SYS_FORK
    syscall
    and       rax, rax
    js        Error.FORK
    jnz       ParentProcess
    
    ; close STDOUT
    mov       edi, STDOUT
    mov       rax, SYS_CLOSE
    syscall
    ; duplicate STDOUT to pdfs.stdout
    mov       edi, DWORD[pdfs.stdout]
    mov       rax, SYS_DUP
    syscall
    ; close pdfs.stdin, not needed
    mov       edi, DWORD[pdfs.stdin]
    mov       rax, SYS_CLOSE
    syscall
    ; execute ls command
    mov       rdx, Child.Cmd.envPtr             ; environment pointers
    mov       rsi, Child.Cmd.argvPtr            ; pointer to array with arguments
    mov       rdi, Child.Cmd.filename           ; pointer to the command to execute
    mov       rax, SYS_EXECVE                   ; syscall execute
    syscall
    and       rax, rax
    js        Error.EXECVE

    jmp       Exit
    
ParentProcess:      
    ; close STDIN
    mov       edi, STDIN
    mov       rax, SYS_CLOSE
    syscall
    ; duplicate STDIN to pdfs.stdin
    mov       edi, DWORD[pdfs.stdin]
    mov       rax, SYS_DUP
    syscall
    ; close pdfs.stdout, not needed
    mov       edi, DWORD[pdfs.stdout]
    mov       rax, SYS_CLOSE
    syscall
    ; execute wc -l command with input from pdfs.stdin, output to STDOUT
    mov       rdx, Parent.Cmd.envPtr            ; environment pointers
    mov       rsi, Parent.Cmd.argvPtr           ; pointer to array with arguments
    mov       rdi, Parent.Cmd.filename          ; pointer to the command to execute
    mov       rax, SYS_EXECVE                   ; syscall execute
    syscall
    and       rax, rax
    js        Error.EXECVE
    jmp       Exit

Error:
.EXECVE:
    mov       rsi, errorexecve
    mov       rdx, errorexecve.length
    jmp       Write
.FORK:
    mov       rsi, errorfork
    mov       rdx, errorfork.length
    jmp       Write
.PIPE:
    mov       rsi, errorpipe
    mov       rdx, errorpipe.length
    jmp       Write

Write:
    mov       rdi, STDOUT
    mov       rax, SYS_WRITE
    syscall
Exit:      
    xor       rdi, rdi
    mov       rax, SYS_EXIT
    syscall