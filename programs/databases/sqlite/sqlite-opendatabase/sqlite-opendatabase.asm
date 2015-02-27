; Name:        sqlite-opendatabase
; Build:       see makefile
; Run:         ./sqlite-opendatabase
; Description: Opens or create if non-existing a database (test.sqlite)
; See Also:    http://www.sqlite.org/c3ref/open.html
;              http://www.sqlite.org/c3ref/close.html
; Remark:      To see the error part in action, you can point the databasename to a non-writable
;              directory or in general, to a place where you have no permissions to operate.
;              If the database isn't present a new database will be made but without the tables.

BITS 64

[list -]
      %include "sqlite3.inc"
      %include "stdio.inc"
[list +]

section .bss
    
section .data

    handle:      dq 0
    
    databaseName:   db "test.sqlite", 0
    notcreated:     db "The database 'test.sqlite' could not be created", 10, 0
    created:        db "The database 'test.sqlite' is succesfully created", 10, 0
    error:          db "The error returned is: %d - %s.", 10, 0
    website:        db "More info can be found at: "
                    db "http://www.sqlite.org/c3ref/open.html and "
                    db "http://www.sqlite.org/c3ref/close.html", 10, 0
                  
section .text
        global _start

_start:
        mov     rsi, handle                 ; pointer handle in RSI
        mov     rdi, databaseName           ; databasename in RDI
        call    sqlite3_open                ; open or create if non existing database
        cmp     rax, SQLITE_OK              ; if RAX is SQLITE_OK then all right
        je      .created
        mov     rdi, notcreated             ; database is not created
        call    Print
        jmp     .error                      ; print the reason
.created:
        mov     rdi, created                ; database is created, inform user
        call    Print
        mov     rdi, QWORD[handle]          ; handle in RDI
        call    sqlite3_close               ; close the database
        cmp     rax, SQLITE_OK              ; if RAX = SQLITE_OK then no problems
        je      Exit                        ; 
.error:
        mov     rdi, QWORD[handle]          ; handle in RDI
        call    sqlite3_extended_errcode    ; get extended errorcode
        push    rax                         ; push errorcode on stack
        mov     rdi, QWORD[handle]          ; handle in RDI
        call    sqlite3_errmsg              ; get the error message
        mov     rdx, rax                    ; error message pointer in RDX
        pop     rsi                         ; get errorcode from stack in RSI
        mov     rdi, error                  ; the pointer to string to display in RDI
        call    Print                       ; print the error message
Exit:
        mov     rdi, website                ; print more info
        call    Print
        call    exit                        ; exit the program
    
Print:
        xor     rax, rax
        call    printf
        ret