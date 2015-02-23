; Name        : applicationicon
; Build       : see makefile
; Run         : ./applicationicon
; Description : a simple window with the basic functionalities and a title, centered on screen with application icon

; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

; when copying the linked application to another location you need to copy the image file 'logo.png' with it in the same directory.
; If you want to change the logo.png file with another picture, just overwrite the logo.png file with the new picture.
;
; C - source : http://zetcode.com/tutorials/gtktutorial/firstprograms/

bits 64

[list -]
     %include "gtk/gtk.inc"
     %include "gtk/gobject.inc"
     %include "gtk/gdk.inc"
     %include "stdio.inc"
[list +]

section .bss
     window          resq    1       ; pointer to the GtkWidget, in this case the window
     pixbuffer       resq    1       ; pointer to pixel buffer for icon
     error           resq    1
        
section .data
     title           db      "window with application icon",0
     destroy         db      "destroy",0
     icon            db      "icon",0
     iconfile        db      "logo.png",0              ; must reside in the same directory
        
section .text
     global _start

_start:
     xor     rsi, rsi                  ; argv
     xor     rdi, rdi                  ; argc
     call    gtk_init
     
     mov     rdi, iconfile
     mov     rsi, error
     call    gdk_pixbuf_new_from_file
     mov     qword [pixbuffer], rax
     
     mov     rdi,GTK_WINDOW_TOPLEVEL
     call    gtk_window_new
     mov     qword [window], rax
     
     mov     rdi, qword [window]
     mov     rsi, title
     call    gtk_window_set_title

     mov     rdi, qword [window]
     mov     rsi, 230
     mov     rdx, 150
     call    gtk_window_set_default_size
     
     mov     rdi, qword [window]
     mov     rsi, GTK_WIN_POS_CENTER
     call    gtk_window_set_position

     mov     rdi, qword [window]
     mov     rsi, qword [pixbuffer]
     call    gtk_window_set_icon

     xor     r9d, r9d                ; combination of GConnectFlags 
     xor     r8d, r8d                ; a GClosureNotify for data
     xor     rcx, rcx                ; pointer to the data to pass
     mov     rdx, Quit               ; pointer to the handler
     mov     rsi, destroy            ; pointer to the signal
     mov     rdi, qword[window]      ; pointer to the widget instance
     call    g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

     mov     rdi, qword [window]
     call    gtk_widget_show

     call    gtk_main

     xor     rdi, rdi                ; we don't expect much errors now
     call    exit
Quit:
     ; if your window disappears but your application is still running then you probably forgot this.
     call    gtk_main_quit
     ret