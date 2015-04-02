; speak.asm
;
; example of named pipes in assembler, goes together with tick.asm
; source: http://beej.us/guide/bgipc/output/html/multipage/fifos.html
;         converted from C
;
; don't put more characters in the buffer than the size allows - You could get an error "Bad file descriptor"
; there is no error handling in this example

[list -]
     %include "unistd.inc"
     %include "fcntl.inc"
[list +]

bits 64

%include "section.bss.inc"                                      ; common definitions in one file

section .data

     fifo_name:     db        FIFO_NAME, 0
     waiting:       db        "waiting for readers...", 10
     .length:       equ       $-waiting
     gotreader:     db        "got a reader--type some stuff", 10
     .length:       equ       $-gotreader
     wrotebytes:
     .part1:        db        "speak: wrote "
     .part1.length: equ       $-wrotebytes.part1
     .part2:        db        " bytes", 10
     .part2.length: equ       $-wrotebytes.part2
     
section .text
     global _start

_start:
     ; create named pipe fifo-buffer
     mov       rdi, fifo_name
     mov       rsi, S_IFIFO | S_IRUSR | S_IWUSR                  ; type = FIFO, read write by user
     xor       rdx, rdx
     mov       rax, SYS_MKNOD
     syscall
     
     ; print message waiting for readers
     mov       rsi, waiting
     mov       rdx, waiting.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     ; open named pipe in write only mode, named pipe is in blockmode thus waiting for a reader
     mov       rdi, fifo_name
     mov       rsi, O_WRONLY
     mov       rax, SYS_OPEN
     syscall
     mov       QWORD[fd], rax
     
     ; print message got reader
     mov       rsi, gotreader
     mov       rdx, gotreader.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
repeat:     
     ; get input from user
     mov       rsi, buffer
     mov       rdx, buffer.length
     mov       rdi, STDIN
     mov       rax, SYS_READ
     syscall
     dec       rax                                ; bytes read minus 1 for linefeed
     mov       QWORD[num], rax
         
     ; write read bytes to named pipe
     mov       rdx, rax                           ; bytes read in RDX
     and       rdx, rdx                           ; bytes left to write?
     jz        exit                               ; nope, user just pressed ENTER, we can quit
     mov       rsi, buffer
     mov       rdi, QWORD[fd]
     mov       rax, SYS_WRITE
     syscall
     
     ; write num of bytes written
     mov       rsi, wrotebytes.part1
     mov       rdx, wrotebytes.part1.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     ; convert bytes read to decimal and print
     mov       rax, QWORD[num]
     mov       rbx, 10  
     xor       rdx, rdx
     div       rbx
     or        dl, "0"
     mov       BYTE[numbuffer.digits], dl
     xor       rdx, rdx
     div       rbx
     and       dl, dl
     or        dl, "0"
     mov       BYTE[numbuffer.tens], dl
     xor       rdx, rdx
     div       rbx
     or        dl, "0"
     mov       BYTE[numbuffer.hundreds], dl
     
     mov       rsi, numbuffer
     mov       rdx, 3
     mov       al, BYTE[numbuffer.hundreds]
     xor       al, "0"
     jnz       checktens
     inc       rsi
     dec       rdx
     mov       rcx, 1                                            ; hundreds are zero
checktens:
     mov       al, BYTE[numbuffer.tens]
     xor       al, "0"
     jnz       printnum
     cmp       rcx, 1
     jne       printnum
     inc       rsi
     dec       rdx
printnum:
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     mov       rsi, wrotebytes.part2
     mov       rdx, wrotebytes.part2.length
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     jmp       repeat
     
exit:

     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall
     
     
     
     
