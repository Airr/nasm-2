; Name:         facrec.asm
; Build:        see makefile
; Run:          ./facrec
; Description:  calculate factorial of n, result on STDOUT with recursion.          

[list -]
        %include "unistd.inc"
        %include "time.inc"
[list +]

BITS 64

%define MAX_VALUE 20

section .bss
        buffer:         resb    21
        .end:
        .length:        equ     $-buffer
        
section .data
        usage:          db "Recursive Factorial - by Agguro - 2013",10,"Usage: facrec n",10,"n must be an integer in [0..20]",10
        .length:        equ     $-usage
        sResult:        db "!="
        .length:        equ     $-sResult
        sLf:            db 10
        .length:        equ     $-sLf
        sExecution:     db "     Execution time: "
        .length:        equ     $-sExecution
        sPeriod:        db "."
        .length:        equ     $-sPeriod
        sSeconds:       db " secs"
        .length:        equ     $-sSeconds
        sZero:          db "0"
        .length:        equ     $-sZero
        
        TIMESPEC starttime
        TIMESPEC endtime
        
section .text
        global _start
_start:

        pop     rax                             ; argc
        cmp     rax, 2
        jne     ShowUsage
        pop     rax                             ; the command
        pop     rsi                             ; pointer to argument
        call    StringLength                    ; string length in RAX
        cmp     rax, 2                          ; maximum number of bytes allowed
        jg      ShowUsage
        call    ParseInteger                    ; Value of the ascii number in RAX, -1 if error
        cmp     rax, 0                          ; if RAX < 0 then error
        jl      ShowUsage
        cmp     rax, MAX_VALUE                  ; if RAX > 20 then to big
        jg      ShowUsage
        push    rax                             ; save n
        
        push    rax
        call    GetTime
        mov     QWORD[starttime.tv_sec], RDX
        mov     QWORD[starttime.tv_nsec], RAX
        pop     rax
        
        call    Factorial                       ; RAX contains the factorial
        
        push    rax
        call    GetTime
        mov     QWORD[endtime.tv_sec], RDX
        mov     QWORD[endtime.tv_nsec], RAX
        pop     rax
        
        pop     rbx                             ; get n
        xchg    rbx, rax                        ; swap result and n
        push    rbx                             ; result on stack
        mov     rsi, buffer.end-1               ; convert and write n
        xor     rdx, rdx
        call    Bits128ToDecimal
        mov     rdx, buffer.end+1
        sub     rdx, rsi
        call    Write
        mov     rsi, sResult                    ; second part of output to STDOUT
        mov     rdx, sResult.length
        call    Write
        pop     rax                             ; get result back from stackframe
        mov     rsi, buffer.end-1
        xor     rdx, rdx
        call    Bits128ToDecimal
        mov     rdx, buffer.end+1               ; write factorial
        sub     rdx, rsi
        call    Write
        call    WriteTime
        mov     rsi, sLf                        ; write linefeed
        mov     rdx, 1
        call    Write
        jmp     Exit
ShowUsage:
        mov     rsi, usage
        mov     rdx, usage.length
        call    Write
Exit:        
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall       
; calculate the factorial of a number in RAX.
Factorial:
        cmp     rax, 0
        jne     .next
        mov     rax, 1
        push    rax
        jmp     .done
.next:        
        push    rax
        dec     rax
        call    Factorial
.done:
        pop     rbx
        imul    rbx                             ; RDX:RAX = RAX * RBX
        ret

; Following routine is a bit overkill but at the time I wrote this I got the routine already written.
; My laziness led me to use this routine instead of writing a 64 bit conversion.
;***********************************************************************************************
; Bits128ToDecimal
; ----------------
; IN  : RDX:RAX is number to convert
; OUT : RSI pointer to first digit in buffer
;       RDX length of decimal number
;***********************************************************************************************
Bits128ToDecimal:
        push    rax
        push    rbx
        push    rcx
        push    rdi
        push    r8
        push    rbp                     ; create stackframe
        mov     rbp, rsp
        sub     rsp, 24                 ; 3 help variables to store 4 - 32 bit registers
        ; prepare help registers
        mov     r8, rax
        shl     r8, 32
        shr     r8, 32
        mov     QWORD[rsp],r8           ; 32 lowest bits in [rsp]
        shr     rax, 32
        mov     QWORD[rsp+8],rax        ; next 32 bits in [rsp+8]
        mov     r8, rdx
        shl     r8, 32
        shr     r8, 32
        mov     QWORD[rsp+16],r8        ; next 32 bits in [rsp+16]
        shr     rdx, 32
        mov     QWORD[rsp+24],rdx       ; 32 highest bits in [rsp+8]
        mov     rdi, buffer.end-1       ; point to last byte in buffer
        xor     rcx, rcx                ; digit counter  
.repeat:
        mov     rbx, 4
.checkNextDigit:
        dec     rbx                     ; point to 32 bits value on stack
        mov     rax, QWORD[rsp+rbx*8]   ; load 32 bits
        cmp     rax, 0                  ; are 32 bits zero?
        jnz     .convert
        cmp     rbx, 0
        jne     .checkNextDigit
        cmp     rcx, 0                  ; already digits converted?
        jne     .adjustPointer          ; yes, stop
        mov     BYTE[rdi],"0"
        mov     rcx, 1
        jmp     .exit
.convert:
        ;convertion                     ; not zero, convert
        xor     rdx, rdx                ; prepare for division
        push    rbx                     ; store 32 bits pointer
        mov     rbx, 10                 ; base 10
        idiv    rbx                     ; RAX = quotient, RDX = remainder
        pop     rbx                     ; restore 32 bits pointer
        mov     QWORD[rsp+rbx*8], rax   ; store quotient back
        cmp     rbx, 0                  ; last set of 32 bits?
        je      .isLastDigit            ; yes
        shl     rdx, 32                 ; no, adjust remainder
        add     QWORD[rsp+rbx*8-8], rdx ; and add to next set
        jmp     .checkNextDigit         ; and continue convertion
.isLastDigit:
        add     dl, "0"                 ; if last digit then make ASCII
        mov     BYTE[rdi], dl           ; and store in buffer
        dec     rdi                     ; adjust buffer
        inc     rcx                     ; increment number of digits
        jmp     .repeat                 ; repeat
.adjustPointer:
        inc     rdi                     ; adjust buffer
.exit:
        mov     rsi, rdi                ; RSI is pointer to buffer with decimal number
        mov     rdx, rcx                ; RDX is number of digits in decimal number
        mov     rsp, rbp
        pop     rbp                     ; leave stackframe
        pop     r8                      ; restore registers
        pop     rdi
        pop     rcx
        pop     rbx
        pop     rax
        ret
;***********************************************************************************************
; GetTime
; -------
; This subroutine returns the time in RDX:RAX
; IN  : none
; OUT : RDX = seconds
;       RAX = nanoseconds
;***********************************************************************************************
GetTime:
        push    rsi
        push    rdi
        push    rcx
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16                 ; reserve 2 QWORDS
        mov     rsi, rsp
        xor     rdi, rdi                ; CLOCK_REALTIME
        mov     rax, SYS_CLOCK_GETTIME
        syscall
        mov     rdx, [rsp]              ; seconds
        mov     rax, [rsp+8]            ; nanoseconds
        mov     rsp, rbp
        pop     rbp    
        pop     rcx
        pop     rdi
        pop     rsi
        ret
;***********************************************************************************************
; WriteTime
; ---------
; This subroutine writes a time in RDX:RAX in decimal seconds
;***********************************************************************************************
WriteTime:
        push    rsi
        push    rax
        push    rcx
        push    rdx
        mov     rsi, sExecution
        mov     rdx, sExecution.length
        call    Write
        mov     rax, QWORD[endtime.tv_nsec]
        mov     rdx, QWORD[endtime.tv_sec]
        stc
        sub     rax, QWORD[starttime.tv_nsec]
        sbb     rdx, QWORD[starttime.tv_sec]
        cmp     rax, 0
        jge     .done
        add     rax,1000000000
.done:
        push    rax                     ; nanosecs on stack
        mov     rax, rdx                ; seconds in RAX
        xor     rdx, rdx
        call    Bits128ToDecimal
        call    Write
        mov     rsi, sPeriod
        mov     rdx, 1
        call    Write
        pop     rax                     ; nanosecs from stack
        xor     rdx, rdx
        call    Bits128ToDecimal
        push    rdx
        push    rsi
        mov     rcx, rdx
.leadingZero:
        cmp     rcx, 9
        je      .writeNanos
        mov     rsi, sZero
        mov     rdx, sZero.length
        call    Write
        inc     rcx
        jmp     .leadingZero
        pop     rdx
        call    Write
.writeNanos:
        pop     rsi
        pop     rdx
        call    Write
        mov     rsi, sSeconds
        mov     rdx, sSeconds.length
        call    Write
        pop     rdx
        pop     rcx     
        pop     rax
        pop     rsi
    ret
;***********************************************************************************************
; Write
; -----
; Write a string pointed by RSI with length RDX to STDOUT
;***********************************************************************************************
Write:
        push    rax                         ; store used registers
        push    rdi
        push    rcx                         ; RCX will also be modified!!
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE              ; write string pointed to by RSI on STDOUT
        syscall
        pop     rcx                         ; restore used registers
        pop     rdi
        pop     rax
        ret
;***********************************************************************************************        
; determine the length of a zero terminated string pointed to by RSI
; the result is returned in RAX. All registers except RAX are restored.
;***********************************************************************************************
StringLength:
        push    rcx
        push    rsi
        xor     rcx, rcx
.repeat:        
        lodsb                           ; byte in AL
        cmp     al, 0                   ; terminating zero?
        je      .done                   ; yes, we're done
        inc     rcx                     ; increment bytecount
        jmp     .repeat
.done:
        mov     rax, rcx
        pop     rsi
        pop     rcx
        ret
;***********************************************************************************************        
; ParseInteger
; ------------
; Parse an integer from an zero terminated ascii string.  Only numbers are
; allowed.  The routine stops at the first non decimal character or when
; ending zero is reached. The result is returned in RAX. If a parse error occur -1 is returned.
;  All registers except RAX are restored.
;***********************************************************************************************
ParseInteger:
        push    rsi
        push    rbx
        push    rcx
        mov     rbx, 10
        xor     rcx, rcx
.repeat:        
        lodsb
        cmp     al, 0
        je      .done
        cmp     al, "0"
        jb      .error
        cmp     al, "9"
        ja      .error
        and      al, 0x0F               ; ascii to decimal
        xchg    rcx, rax
        imul    rbx
        xchg    rcx, rax
        add     rcx, rax
        jmp     .repeat
.error:
        mov     rax, -1
        jmp     .exit
.done:
        mov     rax, rcx
.exit:        
        pop     rcx
        pop     rbx
        pop     rsi
        ret