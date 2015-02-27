; Name:          mysql-showdatabases
; Build:         see makefile
; Run:           ./mysql-showdatabases
; Description:   Program to view all databases from mysql server according to the user who has access to it

;
; you need to execute sudo apt-get install libmysqlclient-dev libmysqlclient18 to install the mysql client libary

BITS 64

[list -]
    extern mysql_close
    extern mysql_errno
    extern mysql_error
    extern mysql_fetch_row
    extern mysql_free_result
    extern mysql_init
    extern mysql_query
    extern mysql_real_connect
    extern mysql_server_end
    extern mysql_server_init
    extern mysql_use_result    
    %include "unistd.inc"
    %include "fileio.inc"
[list +]

section .bss
    conn:               resq  1
    result:             resq  1
    row:		resq  1
    heapstart:          resq  1
    fd:                 resq  1
    host:               resq  1
    port:               resq  1
    user:               resq  1
    password:           resq  1
    database:           resq  1
    socket:             resq  1
    clientflag:         resq  1

section .data

string:
    .filenotfound:              db      "../configuration/mysql not found", 10
    .filenotfound.length:       equ     $-.filenotfound
    .fileread:                  db      "error reading config file", 10
    .fileread.length:           equ     $-.fileread
    .filestatus:                db      "error reading file status", 10
    .filestatus.length:         equ     $-.filestatus
    .fileclose:                 db      "error closing file", 10
    .fileclose.length:          equ     $-.fileclose
    
    .notenoughmemory:           db      "not enough memory", 10
    .notenoughmemory.length:    equ     $-.notenoughmemory
    .deallocmemory:             db      "error deallocating memory", 10
    .deallocmemory.length:      equ     $-.deallocmemory
    
    .mysqlserverinit:           db      "MySQL library could not be initialized",10
    .mysqlserverinit.length:    equ     $-.mysqlserverinit
    .mysqlobjinit:              db      "MySQL init object failed", 10
    .mysqlobjinit.length:       equ     $-.mysqlobjinit
    .mysqlresult:               db      "MySQL result error", 10
    .mysqlresult.length:        equ     $-.mysqlresult
    .mysqlfetchrow:             db      "MySQL fetch row error", 10
    .mysqlfetchrow.length:      equ     $-.mysqlfetchrow

; assemble with make cgi, if you want to make a cgi application of this program
%ifdef CGI
    httpheader:                 db      "Content-type: text/html",10,10
    .length:                    equ     $-httpheader
    br:				db	"<br />"
    .length:			equ 	$-br
%endif

mysqlerror:
    .2000:                      db      "Unknown error"
    .2000.length:               equ     $-.2000

    .2003:                      db      "Connection to server lost"
    .2003.length:               equ     $-$$


    query:                      db  "show databases",0
    
    configfilename:             db  "../configuration/mysql",0
    hoststring:                 db  "DBHOST="
    .length:                    equ $-hoststring
    userstring:                 db  "DBUSER="
    .length:                    equ $-userstring
    passwordstring:             db  "DBPASSWORD="
    .length:                    equ $-passwordstring
    portstring:                 db  "DBPORT="
    .length:                    equ $-portstring
    
    ; file status structure
    STAT stat
    
section .text
        global _start

_start:

%ifdef CGI
      mov	rsi, httpheader
      mov	rdx, httpheader.length
      call	String.Write
%endif

ConfigFile:
      ; open configuration file
      mov       rdi, configfilename
      mov       rsi, O_RDONLY
      mov       rax, SYS_OPEN
      syscall
      and       rax, rax
      js        Error.filenotfound
      mov       QWORD[fd], rax                          ; save filedescriptor
      ; get the filesize
      mov       rdi, rax
      mov       rsi, stat
      mov       rax, SYS_FSTAT
      syscall
      and       rax, rax
      js        Error.filestatus
; reserve memory for file contents
      ; get memory break
      xor       rdi, rdi
      mov       rax, SYS_BRK
      syscall
      and       rax, rax
      js        Error.notenoughmemory
      mov       QWORD[heapstart], rax                   ; save pointer to memory break
      add       rax, QWORD[stat.st_size]                ; add filesize to allocate memory
      inc       rax                                     ; one extra byte, to be sure the string ends with 00
      
      ; try to allocate additional memory
      mov       rdi, rax
      mov       rax, SYS_BRK
      syscall
      sub       rax, rdi                                ; new memory break equal to calculated one?
      and       rax, rax
      jnz       Error.notenoughmemory
      
      ; read the file in the allocated memory
      mov       rdi, QWORD[fd]
      mov       rsi, QWORD[heapstart]
      mov       rdx, QWORD[stat.st_size]        ; bytes to read
      mov       rax, SYS_READ
      syscall
      and       rax, rax
      js        Error.fileread
      
      ; close file
      mov       rdi, QWORD[fd]
      mov       rax, SYS_CLOSE
      syscall
      and       rax, rax
      js        Error.fileclose
      
; loop through our string, replacing each 0x0A and 0x0D with 00
      mov       rsi, QWORD[heapstart]
      mov       rdi, QWORD[stat.st_size]
      call      String.ZeroCRLF

; get the values for host, user, password, port, database, socket and clientflag, if socket and clientflag are
; empty strings then the values for these are NULL instead of the pointer to the socket and clientflag string.
; Port need to be stored as an unsigned integer.
      ; get pointer to HOST
      mov       rdi, hoststring.length
      mov       rsi, hoststring
      call      String.Search
      mov       QWORD[host], rax
      ; get pointer to USER
      mov       rdi, userstring.length
      mov       rsi, userstring
      call      String.Search
      mov       QWORD[user], rax
      ; get pointer to PASSWORD
      mov       rdi, passwordstring.length
      mov       rsi, passwordstring
      call      String.Search
      mov       QWORD[password], rax
      ; get pointer to PORT      
      mov       rdi, portstring.length
      mov       rsi, portstring
      call      String.Search
      ; parse PORT to integer
      mov       rdi, rax
      call      String.ToInt
      mov       QWORD[port], rax
      ; all necessary values are known, now connect to mysql server and get an uuid
      ; not an embedded MySQL so all arguments must be zero
      xor       rdi, rdi
      xor       rsi, rsi
      xor       rdx, rdx
      call      mysql_server_init
      and       rax, rax
      jnz       Error.mysqlserverinit
      ; From this point we need to cleanup the library!!!!
      xor       rdi, rdi
      call      mysql_init
      and       rax, rax
      jz        Error.mysqlobjinit
      ; no errors, connect and login 
      mov       QWORD [conn], rax                 ; save *mysql
      mov       rdi, rax                          ; value of mysql = pointer to mysql instance of connection
      push      0                                 ; the value of clientflags or NULL if none
      push      0                                 ; the value of socket or NULL if none
      mov       r9d, DWORD [port]                 ; the value of the port to connect to               
      xor       r8, r8                            ; pointer to zero terminated database string
      mov       rcx, QWORD [password]             ; pointer to zero terminated password string
      mov       rdx, QWORD [user]                 ; pointer to zero terminated user string
      mov       rsi, QWORD [host]                 ; pointer to zero terminated host string
      call      mysql_real_connect                ; connect
      pop       rdx                               ; restore stackpointer
      pop       rdx
      sub       rax, QWORD [conn]       ; if conn == pointer to mysql instance then succes
      and       rax, rax      
      jnz       Error.mysqlconnect
      ; We are connected, execute the query

      mov       rsi, query                              ; pointer to zero terminated query string
      mov       rdi, QWORD [conn]                ; value of mysql = pointer to mysql instance of connection
      call      mysql_query             ; query the server
      ; check for errors
      mov       rdi, QWORD [conn]                 ; check if an error occured
      call      mysql_errno
      and       rax, rax
      jnz       Error.mysqlquery

      mov       rdi, QWORD[conn]
      call      mysql_use_result        ; we don't ask all the records at once (less client side memory)
      and       rax, rax
      jz        Error.mysqlresult

      ; get databases from resultset
      mov       QWORD [result], rax
nextRecord:
      mov	rdi, QWORD [result]
      call      mysql_fetch_row
      ; the result is a pointer to a row
      ; first 8 bytes of that result is a pointer to the name of the item in the row
      ; we have to loop this procedure until the row == null
      ; after row == null received always check first for errors
      and	rax, rax
      jz        NoRows			; any record left?
      cmp       rax, 2000               ; unknown error
      je        Error.mysqlfetchrow
      cmp       rax, 2013               ; connection lost
      je        Error.mysqlfetchrow
      mov       QWORD[row], rax
      
      ; print the record
      mov       rsi, [rax]
      mov       rdi, rsi
      call      String.Length
      mov       rdx, rax
      add       rax, rsi
%ifndef CGI
      inc       rdx
      mov       BYTE [rax], 0x0A
%endif
      call	String.Write
      
%ifdef CGI
      mov	rsi, br
      mov	rdx, br.length
      call	String.Write
%endif      
      
      ; and go for next record
      jmp       nextRecord

NoRows:      
      mov       rdi, QWORD[conn]
      call      mysql_errno
      and       rax, rax
      jnz       Error.mysqlerror
      ; free result
      mov       rdi, QWORD[result]
      call      mysql_free_result
CloseConnection:
      mov       rdi, QWORD [conn]
      call      mysql_close
ServerEnd:        
      call      mysql_server_end
FreeHeap:
      mov       rdi, QWORD[heapstart]
      mov       rax, SYS_BRK
      syscall
      and       rax, rax
      js        Error.deallocmemory
Exit:
      xor       rdi, rdi
      mov       rax, SYS_EXIT
      syscall

Error:
.mysqlserverinit:
      mov       rdi, STDERR
      mov       rsi, string.mysqlserverinit
      mov       rdx, string.mysqlserverinit.length
      mov       rax, SYS_WRITE
      syscall
      jmp       Exit
.mysqlobjinit:
      mov       rdi, STDERR
      mov       rsi, string.mysqlobjinit
      mov       rdx, string.mysqlobjinit.length
      mov       rax, SYS_WRITE
      syscall
      jmp       ServerEnd
.mysqlconnect:
      mov       rdi, QWORD [conn]
      call      mysql_error
      mov       rsi, rax
      mov       rdi, rax
      call      String.Length
      mov       rdx, rax
      add       rax, rsi
      mov       BYTE [rax], 0x0A
      inc       rdx
      mov       rdi, STDERR
      mov       rax, SYS_WRITE
      syscall
      jmp       ServerEnd
.mysqlquery:
      mov       rdi, QWORD [conn]
      call      mysql_error
      mov       rsi, rax
      mov       rdi, rax
      call      String.Length
      mov       rdx, rax
      add       rax, rsi
      mov       BYTE [rax], 0x0A
      inc       rdx
      mov       rdi, STDERR
      mov       rax, SYS_WRITE
      syscall
      jmp       CloseConnection
.mysqlresult:
      mov       rdi, STDERR
      mov       rsi, string.mysqlresult
      mov       rdx, string.mysqlresult.length
      mov       rax, SYS_WRITE
      syscall
      jmp       CloseConnection
.mysqlfetchrow:
      mov       rdi, STDERR
      mov       rsi, string.mysqlfetchrow
      mov       rdx, string.mysqlfetchrow.length
      mov       rax, SYS_WRITE
      syscall
      jmp       CloseConnection
.mysqlerror:
      mov       rdi, QWORD [conn]
      call      mysql_error
      mov       rsi, rax
      mov       rdi, rax
      call      String.Length
      mov       rdx, rax
      add       rax, rsi
      mov       BYTE [rax], 0x0A
      inc       rdx
      mov       rdi, STDERR
      mov       rax, SYS_WRITE
      syscall
      jmp       CloseConnection      
      
.notenoughmemory:
      mov       rdi, STDERR
      mov       rsi, string.notenoughmemory
      mov       rdx, string.notenoughmemory.length
      mov       rax, SYS_WRITE
      syscall
      jmp       Exit
.deallocmemory:
      mov       rdi, STDERR
      mov       rsi, string.deallocmemory
      mov       rdx, string.deallocmemory.length
      mov       rax, SYS_WRITE
      syscall
      jmp       Exit
.fileread:
      mov       rdi, STDERR
      mov       rsi, string.fileread
      mov       rdx, string.fileread.length
      mov       rax, SYS_WRITE
      syscall
      jmp       Exit
.filenotfound:
      mov       rdi, STDERR
      mov       rsi, string.filenotfound
      mov       rdx, string.filenotfound.length
      mov       rax, SYS_WRITE
      syscall
      jmp       Exit
.filestatus:
      mov       rdi, STDERR
      mov       rsi, string.filestatus
      mov       rdx, string.filestatus.length
      mov       rax, SYS_WRITE
      syscall
      jmp       Exit
.fileclose:
      mov       rdi, STDERR
      mov       rsi, string.fileclose
      mov       rdx, string.fileclose.length
      mov       rax, SYS_WRITE
      syscall
      jmp       Exit      
      
String.Search:                                  ; on succes CF=0 and RAX has pointer
      mov       rax, rdi                        ; the length in rax
      mov       rbx, rsi                        ; the stringpointer in rbx
      mov       rsi, QWORD[heapstart]
      mov       rdx, QWORD[stat.st_size]
      sub       rdx, rdi
.@1:    
      mov       rdi, rbx
      mov       rcx, rax
      cld
      repe      cmpsb
      je        .@2
      dec       rdx
      and       rdx, rdx
      jnz       .@1
      stc
      ret
.@2:
      mov       rax, rsi
      clc
      ret
      
String.ToInt:
      mov       rsi, rdi
      xor       rdx, rdx
.@1:    
      xor       rax, rax
      lodsb
      and       al, al                                  ; end of string?
      jz        .@2
      and       al, 0x0F                                ; un-ascii
      and       rdx, rdx
      jz        .@3
      mov       rcx, rax
      mov       rax, rdx
      xor       rdx, rdx
      mov       rbx, 10
      imul      rbx
      mov       rdx, rcx
.@3:    
      add       rax, rdx
      mov       rdx, rax
      jmp       .@1
.@2:
      mov       rax, rdx
      ret
      
String.Length:
      xor       rcx, rcx
      dec       rcx
      xor       rax, rax
      repne     scasb
      neg       rcx
      dec       rcx
      dec       rcx
      and       rcx, rcx
      mov       rax, rcx
      ret
      
String.ZeroCRLF:
      mov       rcx, rdi
      inc       rcx
.@1:
      cld
      lodsb
      cmp       al, 0x0A
      je        .@2
      cmp       al, 0x0D
      jne       .@3
.@2:
      dec       rsi
      xor       al, al
      mov       BYTE[rsi], al
.@3:      
      loop      .@1
      ret
      
String.Write:
      mov	rdi, STDOUT
      mov	rax, SYS_WRITE
      syscall
      ret