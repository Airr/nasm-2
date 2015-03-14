%ifndef _ASM_FCNTL_INC_
%define _ASM_FCNTL_INC_

%ifndef _ASM_STAT_INC_
     %include "sys/stat.inc"
%endif

; Values for the second argument to access. These may be OR'd together.

%define   R_OK 4         ; Test for read permission.
%define   W_OK 2         ; Test for write permission.
%define   X_OK 1         ; Test for execute permission.
%define   F_OK 0         ; Test for existence.

%define   SEEK_SET   0    ; Seek from beginning of file.
%define   SEEK_CUR   1    ; Seek from current position.
%define   SEEK_END   2    ; Seek from end of file.

%define   F_ULOCK 0  ; /* Unlock a previously locked region.  */
%define   F_LOCK  1  ; /* Lock a region for exclusive use.  */
%define   F_TLOCK 2  ; /* Test and lock a region for exclusive use.  */
%define   F_TEST  3  ; /* Test a region for other processes locks.  */

%define F_DUPFD          0    ; /* dup */
%define F_GETFD          1    ; /* get close_on_exec */
%define F_SETFD          2    ; /* set/clear close_on_exec */
%define F_GETFL          3    ; /* get file->f_flags */
%define F_SETFL          4    ; /* set file->f_flags */
%define F_GETLK          5
%define F_SETLK          6
%define F_SETLKW    7
%define F_SETOWN    8    ; /* for sockets. */
%define F_GETOWN    9    ; /* for sockets. */
%define F_SETSIG    10   ; /* for sockets. */
%define F_GETSIG    11   ; /* for sockets. */

%define F_GETLK64   12   ; /*  using 'struct flock64' */
%define F_SETLK64   13
%define F_SETLKW64  14
%define F_SETOWN_EX 15
%define F_GETOWN_EX 16
%define F_GETOWNER_UIDS  17
%define F_OWNER_TID 0
%define F_OWNER_PID 1
%define F_OWNER_PGRP     2


; for F_[GET|SET]FL
%define FD_CLOEXEC  1    ; actually anything with low bit set goes */

; for posix fcntl() and lockf()
%define F_RDLCK          0
%define F_WRLCK          1
%define F_UNLCK          2

; for old implementation of bsd flock ()
%define F_EXLCK          4    ;; /* or 3 */
%define F_SHLCK          8    ;; /* or 4 */

; operations for bsd flock(), also used by the kernel implementation */
%define LOCK_SH          1    ;; /* shared lock */
%define LOCK_EX          2    ;; /* exclusive lock */
%define LOCK_NB          4    ;; /* or'd with one of the above to prevent blocking */
%define LOCK_UN          8    ;; /* remove lock */

%define LOCK_MAND   32   ;; /* This is a mandatory flock ... */
%define LOCK_READ   64   ;; /* which allows concurrent read operations */
%define LOCK_WRITE  128  ;; /* which allows concurrent write operations */
%define LOCK_RW          192  ;; /* which allows concurrent read & write ops */

%define F_LINUX_SPECIFIC_BASE 1024

;
;struct f_owner_ex {
;     int  type;
;     __kernel_pid_t pid;
;};

;struct flock {
;     short     l_type;
;     short     l_whence;
;     __kernel_off_t l_start;
;     __kernel_off_t l_len;
;     __kernel_pid_t l_pid;
;     __ARCH_FLOCK_PAD
;};

%endif