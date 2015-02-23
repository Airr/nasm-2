; Name:     datadownload.asm
; Build:    see makefile
; Description:
; Demonstration of a simple downloadable file, the contents of the file are in the program.
; (It could be the binary of this program too.)
; If you should see errors instead of a download window check if fastcgi is enabled on your apache server.
; appearantle mod-cgi alone isn't enough to serve this program
; sudo apt-get install libapache2-mod-fastcgi
; sudo a2enmod fastcgi
; sudo service apache2 restart

bits 64

[list -]
     %include 'unistd.inc'
[list +]

section .bss

section .data

reply:
     db   'Content-type: application/octet-stream', 10
     db   'Content-Disposition: attachment; filename="data.bin"', 10, 10
     db   'This data will be send to the web client'
     db   'This data is send to the web client as a file named data.bin'
reply.length: equ $-reply     

section .text
    global _start
    
_start:

     mov       rax, SYS_WRITE
     mov       rsi, reply
     mov       rdx, reply.length
     mov       rdi, STDOUT
     syscall

     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall