; Name        : centeredwindow
; Build       : see makefile
; Run         : ./centeredwindow
; Description : a simple window with the basic functionalities and a title, centered on screen

BITS 64

[list -]
    %include "gtk/gtk.inc"
    %include "gtk/gobject.inc"
    %include "stdio.inc"
[list +]

section .bss
    window      resq    1   ; pointer to the GtkWidget, in this case the window
    
section .data
    title       db  "A centered window",0
    destroy     db  "destroy",0
    
section .text
    global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window], rax

    ; gtk_window_set_title
    mov     rdi, QWORD[window]
    mov     rsi, title
    call    gtk_window_set_title

    mov     rdi, qword [window]
    mov     rsi, 230
    mov     rdx, 150
    call    gtk_window_set_default_size
    
    mov     rdi, QWORD[window]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    xor     r9d, r9d                ; combination of GConnectFlags 
    xor     r8d, r8d                ; a GClosureNotify for data
    xor     rcx, rcx                ; pointer to the data to pass
    mov     rdx, Quit               ; pointer to the handler
    mov     rsi, destroy            ; pointer to the signal
    mov     rdi, QWORD[window]      ; pointer to the widget instance
    call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

    mov     rdi, QWORD[window]
    call    gtk_widget_show

    call    gtk_main

    xor     rdi, rdi                ; we don't expect much errors now thus errorcode=0
    call    exit

Quit:
    ; if your window disappears but your application is still running then you probably forgot this.
    
    call    gtk_main_quit
    ret