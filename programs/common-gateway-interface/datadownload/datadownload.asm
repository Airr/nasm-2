; Name:     datadownload.asm
; Build:    see makefile
; Description:
;   Demonstration of a simple downloadable file, the contents of the file are in the program.
;   (It could be the binary of this program too.)

bits 64

section .bss

section .data

reply:
     db    'Content-Description: File Transfer', 10                                                       ; FOR I.E.
     db    'Content-type: application/octet-stream',10
     db    'Content-Disposition: attachment',59,'filename="thisprogram.bin"',10                    ; 59 is ascii code for ';'
     db    'Content-Transfer-Encoding: binary', 10
     db    'Expires: 0', 10
     db    'Cache-Control: must-revalidate', 10
     db    'Pragma: public', 10
     db    'Content-Length: '
     db    data.length, 10, 10
data:     
     db    'This data will be send to the web client'
data.length:  equ $-data
reply.length: equ $-reply     

section .text
    global _start
    
_start:

    mov rax, 1                          ; SYS_WRITE
    mov rsi, reply
    mov rdx, reply.length
    mov rdi, 1                          ; STDOUT
    syscall
    
    mov rdi, 0                          ; no errors
    mov rax, 60                         ; SYS_EXIT
    syscall