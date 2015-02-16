;***********************************************************************************************
; Name:         setcookie.asm
; Build:        see makefile
; Description:  set 4 cookies
;               This isn't a state-of-the-art program but to be complete on cgi applications it's
;               a nice example on how to set cookies.
;               The executable of this file need to be uploaded to your webservers cgi directory
;               from there you can access the application from a webbrowser.
;***********************************************************************************************
bits 64

%include "syscalls.inc"
%include "termio.inc"

section .data

cookies:
    db "Set-Cookie:UserID=XYZ", 10
    db "Set-Cookie:Password=XYZ123", 10
    db "Set-Cookie:Domain=www.agguro.be", 10
    db "Set-Cookie:Path=/", 10
    db "Content-type: text/html", 10, 10
    db "<html><head><title>Set Cookies</title></head>"
    db "<body>"
    db "<span>Check your browser's cookies for UserID, Password, Domain and Path cookie</span>"
    db "</body>"
    db "</html>"
cookies.length: equ $-cookies

section .text
        global _start
_start:

     mov        rdi, STDOUT
     mov        rsi, cookies
     mov        rdx, cookies.length
     mov        rax, SYS_WRITE
     syscall
     xor        rdi, rdi
     mov        rax, SYS_EXIT
     syscall