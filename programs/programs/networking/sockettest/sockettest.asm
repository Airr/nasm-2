; socket.asm
;
; example of a basic connection to a host:port
; basic error handling is used but can be (and must be) improved
;
; Purpose: This program works together with the httpserver demo.

BITS 64
[list -]
      %include "unistd.inc"
      %include "sys/socket.inc"
[list +]

section .bss
 
sockfd:                 resq 1
sock_addr:              resq 1
buffer:                 resb 1000
.length:                equ  $-buffer

section .data

; the message we will send to the server, for http server request we must change this to "GET / HTTP/1.1",10,10

request:                ;db 'POST /taxation_customs/vies/vatResponse.html HTTP/1.1',13, 10
                        ;db 'Host: ec.europa.eu', 13, 10
                        ;db 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0', 13, 10
                        ;; example data
                        ;db 'Accept: application/json;text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',13, 10
                        ;db 'Accept-Language: en-US,en;q=0.5',13, 10
                        ;; not needed
                        ;;db 'Accept-Encoding: gzip, deflate', 13, 10
                        ;;db 'X-Requested-With: XMLHttpRequest', 13, 10
                        ;db 'Referer: http://ec.europa.eu/taxation_customs/vies/vieshome.do', 10
                        ;; not needed
                        ;;db 'Cookie: JSESSIONID=zxptJvkJ2QlcjJzrsQgsjvwpyp9LYLK22hvRnwVPJxxldK6KxpvQ!-1772798430', 13, 10
                        ;db 'Connection: close', 13, 10
                        ;db 'Content-Type: application/x-www-form-urlencoded', 13, 10
                        ;; content length is the length of the posted data -> should be calculated
                        ;db 'Content-Length: 62', 13, 10, 13, 10
                        ;; this is enough info, the entire post is:
                        ;; memberStateCode=BE&number=0437882546&traderName=&traderStreet=&traderPostalCode=&traderCity=&requesterMemberStateCode=&requesterNumber=&action=check&check=Verify
                        
                        ;;;;  db 'memberStateCode=BE&number=0437882546&action=check&check=Verify'
                        ;; will return : 
                        ;; Yes, valid VAT number
                        ;;
                        ;; Member State               BE
                        ;; VAT Number                 BE 0437882546
                        ;; Date when request received 2015/02/17 08:53:02
                        ;; Name                       BV BVBA CENTRUM VOOR MEDISCHE ANALYSE
                        ;; Address                    OUD-STRIJDERSLAAN (HRT) 199
                        ;;                            2200 HERENTALS
                        ;db 'memberStateCode=BE&number=0823633037&action=check&check=Verify'
                        ;; will return :
                        ;; Yes, valid VAT number
                        ;;
                        ;; Member State   BE
                        ;; VAT Number     BE 0823633037
                        ;; Date when request received    2015/02/17 08:58:42
                        ;; Name      BVBA ABSOTECH
                        ;; Address   VAARTSTRAAT 2
                        ;; 3191 BOORTMEERBEEK
                        
                        ;db 'POST /bin/getpostparams HTTP/1.1', 13, 10
                        ;db 'User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)', 13, 10
                        ;db 'Host: www.tutorialspoint.com', 13, 10
                        ;db 'Accept-Language: en-us', 13, 10
                        ;db 'Content-Length: 15', 13, 10
                        ;db 'Connection: close', 13, 10, 13, 10 ;Keep-Alive', 13, 10, 13, 10
                        ;db 'a=10&b=20&c=a+b'
                        db 'PUT /hello.html HTTP/1.1',10
                        db 'User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)',10
                        db 'Host: www.tutorialspoint.com',10
                        db 'Accept-Language: en-us',10
                        db 'Connection: Keep-Alive',10
                        db 'Content-type: text/html',10
                        db 'Content-Length: 182',10,10
                        db '<html><body><h1>Hello, World!</h1></body></html>'
                        
request.length:         equ $-request
socketerror:            db "socket error", 10
.length:                equ $-socketerror
connecterror:           db "connection error", 10
.length:                equ $-connecterror
connected:              db "Connected", 10
.length:                equ $-connected
disconnected:           db "Connection closed", 10
.length:                equ $-disconnected

crlf:                   db 10

section .text
 
global _start
 
_start:
 
; create a socket
        mov     rax, SYS_SOCKET          ; call socket(SOCK_STREAM, AF_NET, 0);
        mov     rdi, PF_INET             ; PF_INET = 2
        mov     rsi, SOCK_STREAM         ; SOCK_STREAM = 1
        xor     rdx, rdx                 ; IPPROTO_IP = 0
        syscall
        and     rax, rax
        jl      .socketerror
        mov     QWORD[sockfd], rax       ; save descriptor
 
; fill in sock_addr structure (on stack)
        xor     r8, r8                   ; clear the value of r8
        mov     r8, 0x0100007F;          ; 8C8BB72E;            0x67774393           ; VIES VAT checker IP 147.67.119.103 (ec.europa.eu); 100007F (IP address : 127.0.0.1)
        push    r8                       ; push r8 to the stack
        push    WORD 0x5000              ; port 80 push our port number to the stack (Port = 4444) don't use PUSH WORD 4444 (endianess!)
        push    WORD AF_INET             ; push protocol argument to the stack (AF_INET = 2)
        mov     QWORD[sock_addr], rsp    ; Save the sock_addr_in

; connect to the remote host
        mov     rax, SYS_CONNECT         ; 
        mov     rdi, QWORD[sockfd]       ; socket descriptor
        mov     rsi, QWORD[sock_addr]    ; sock_addr structure
        mov     rdx, 16                  ; length of sock_addr structure
        syscall
        and     rax, rax
        jl      .connecterror
        
        mov     rsi, connected
        mov     rdx, connected.length
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
        
; send the message to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, request
        mov     rdx, request.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall

; receive a message from the server
.receive:
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
        mov     rsi, buffer
        mov     rdx, buffer.length              ; buffer length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to source address structure
        mov     r9, 0                           ; length of source address structure
        syscall
        and     rax, rax
        jz      .endreceive

; write contents of the buffer to stdout, rax has the bytes read
        mov     rdx, rax                        ; bytes read in rdx
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, buffer
        syscall
        jmp     .receive
        
.endreceive:        
; additional CRLF
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, crlf
        mov     rdx, 1
        syscall

; close connection
        mov     rax, SYS_CLOSE
        mov     rdi, QWORD[sockfd]
        syscall
        
; disconnected message
        mov     rsi, disconnected
        mov     rdx, disconnected.length
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
 
; exit program        

        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall
 
; the errors
.connecterror:
        mov     rsi, connecterror
        mov     rdx, connecterror.length
        jmp     .print
 
.socketerror:
        mov     rsi, socketerror
        mov     rdx, socketerror.length
        jmp     .print
 
.print:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
.exit:  
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall