;***********************************************************************************************
; name:         cgiroot.asm
;
; description:  returns the cgi root directory in a webpage. The program is the same as cwd.asm
;               wich returns the current working directory.  Because this program runs in the cgi
;               directory it returns the cgiroot directory.
;
; build:        nasm -f elf64 -o cgiroot.o cgiroot.asm -l cgiroot.list
;               ld cgiroot.o -o cgiroot
;***********************************************************************************************
BITS 64
ALIGN 8

      [list -]
      %include "syscalls.inc"
      %include "termio.inc"
      [list +]
      
section .bss

      heapstart:        resq 1
           
section .data
      httpheader:       db  "Content-type: text/html",10,10
      .length:          equ $-httpheader
      errorNoMemory:    db  "Error 500: Internal Server Error"
      .length:          equ $-errorNoMemory
      
section .text
        global _start       
_start:
        mov     rsi, httpheader
        mov     rdx, httpheader.length
        call    write                
        xor     rdi, rdi                        ; rdi = 0
        mov     rax, SYS_BRK                    ; get start of heap
        syscall
        and     rax, rax                        ; if rax < 0 then no memory available
        js      error                           ; no more memory available
        mov     QWORD[heapstart], rax           ; save the current memory break
        
        ; reserve memory with chunks of 16 bytes, until the current working directory fits in the
        ; created buffer or until there is no more memory available (should not may occur)
repeat: 
        mov     rdi, rax                        ; set in RDI
        add     rdi, 16                         ; add 16 bytes to the current memory break
        mov     rax, SYS_BRK
        syscall                                 ; try to allocate 16 bytes
        cmp     rdi, rax                        ; RAX == new memory break?
        jne     error                           ; no more memory available to allocate
        sub     rdi, QWORD[heapstart]           ; size = end in RDI - start in [heapstart]
        mov     rsi, rdi                        ; size of allocated memory
        mov     rdi, QWORD[heapstart]           ; start of allocated memory
        mov     rax, SYS_GETCWD                 ; get the current working directory
        syscall
        and     rax, rax
        jns     printcwd                        ; if no sign then the cwd is succesfully read
        mov     rax, rdi                        ; buffer not large enough rax = [heapstart]
        add     rax, rsi                        ; heapstart + size of already allocated memory -> new memory break
        jmp     repeat                          ; retry allocating more memory
printcwd:
        mov     rdx, rax                        ; save length
        mov     rsi, QWORD[heapstart]           ; pointer to the zero terminated string
        call    write
        
        mov     rdi, QWORD[heapstart]           ; release all allocated memory
        mov     rax, SYS_BRK
        syscall        
        jmp     exit                            ; and exit the program
error:
        mov     rsi, errorNoMemory
        mov     rdx, errorNoMemory.length
        call    write
        jmp     exit
exit:
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall
write:
        xor     rdi, rdi
        inc     rdi                             ; short method for rdi = STDOUT
        mov     rax, rdi                        ; rax = syscall write
        syscall
        ret