; Name:        sqlite-version
; Build:       see makefile
; Run:         ./sqlite-version
; Description: Shows version string and number
; See also:    http://www.sqlite.org/c3ref/libversion.html

BITS 64

[list -]
      %include "sqlite3.inc"
      %include "stdio.inc"
[list +]

section .bss
    
section .data
    versionformat   db "SQLITE version: %s", 10, 0
    version         db "SQLITE version number: %d", 10, 0
    
section .text
        global _start

_start:
    
    call    sqlite3_libversion
    mov     rsi, rax
    mov     rdi, versionformat
    xor     rax, rax
    call    printf
    
    call    sqlite3_libversion_number
    mov     rsi, rax
    mov     rdi, version
    xor     rax, rax
    call    printf
    
    call    exit
