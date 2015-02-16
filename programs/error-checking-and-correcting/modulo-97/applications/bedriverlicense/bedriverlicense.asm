; Name:  bedriverlicense
; Build: see makefile
; Run:   ./bedriverlicense n
;        n is a Belgian 10 digit drivers license number.
; Description:
;        Modulo 97 check on driver license number.

BITS 64

[list -]
        %include "syscalls.inc"
        %include "termio.inc"
[list +]

section .data

        msgUsage:       db      "usage: bedriverlicense n",10,"n = 10 digit Belgian drivers license number",10
        .length:        equ     $-msgUsage
        msgResult:      db      "illegal driver license number", 10
        .length:        equ     $-msgResult

section .text
        global _start
    
_start:
        pop     rax                     ; argc
        cmp     rax, 2                  ; two arguments?
        jne     .usage                  ; nope, show usage
        pop     rax                     ; the commandstring string pointer
        pop     rsi                     ; the argument string pointer
        ; check length
        push    rsi
        pop     rdi
        xor     rcx, rcx
        not     rcx
        xor     rax, rax
        cld
        repne   scasb
        neg     rcx                     ; for the stringlength we need to subtract 2
        cmp     rcx, 12                 ; for the program we don't need the stringlength thus we check if length = 10 + 2
        jne     .usage
        xor     rdx, rdx                ; result
.repeat:        
        xor     rax, rax                ; RAX zero
        lodsb                           ; character in AL
.ascii:        
        cmp     al, "0"
        jb      .usage
        cmp     al, "9"
        ja      .usage
        and     al, 0x0F                ; make decimal
        add     rdx, rax
        cmp     rcx, 1                  ; last digit of drivers license number?
        je      .done                   ; yes
        cmp     rcx, 5                  ; 10th byte reached?
        je      .checkdigit             ; yes, is last digit
        mov     rax, rdx
        shl     rax, 1                  ; mul 10
        shl     rdx, 3
        add     rdx, rax
        loop    .repeat
.checkdigit:                            ; get the checkdigits
        mov     rbx, rdx
        xor     rdx, rdx
        mov     rcx, 3                  ; adjust loop counter
        loop    .repeat
.done:
        ; RBX has the number, RDX the checkdigits
        ; check if checkdigits are equal to modulo 97 of the number
        mov     rcx, rdx                ; checkdigits in RCX
        mov     rax, rbx                ; number in RAX
        xor     rdx, rdx                ; prepare division
        mov     rbx, 97                 ; divisor
        idiv    rbx                     ; RAX = quotient, RDX is modulo 97
        sub     rbx, rdx                ; 97 - modulo 97
        mov     rax, rbx
        mov     rsi, msgResult
        mov     rdx, msgResult.length
        cmp     rax, rcx
        jne     .isnotequal
        inc     rsi                     ; adjust pointer
        inc     rsi
        dec     rdx                     ; adjust length
        dec     rdx
.isnotequal:
        jmp     .write
.usage:        
        mov     rsi, msgUsage
        mov     rdx, msgUsage.length
.write:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
.exit:        
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall