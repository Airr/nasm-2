%ifndef __NASM_SYSCALL32_INC__
%define __NASM_SYSCALL32_INC__

; ---------------------------------
; SysCall Macro
; ---------------------------------

%imacro syscall 0-6
%if %0 > 0
  %if %0 > 1
    %if %0 > 2
      %if %0 > 3
        %if %0 > 4
          %if %0 > 5
            %ifnum %{6}
              %if %{6} == 0
                xor edi, edi
              %elif %{6} == -1
                or  edi, -1
              %else
                mov edi, %{6}
              %endif
            %elifnidni %{6}, edi
              mov edi, %{6}
            %endif
          %endif
          %ifnum %{5}
            %if %{5} == 0
              xor esi, esi
            %elif %{5} == -1
              or  esi, -1
            %else
              mov esi, %{5}
            %endif
          %elifnidni %{5}, esi
            mov esi, %{5}
          %endif
        %endif
        %ifnum %{4}
          %if %{4} == 0
            xor edx, edx
          %elif %{4} == -1
            or  edx, -1
          %else
            mov edx, %{4}
          %endif
        %elifnidni %{4}, edx
          mov edx, %{4}
        %endif
      %endif
      %ifnum %{3}
        %if %{3} == 0
          xor ecx, ecx
        %elif %{3} == -1
          or  ecx, -1
        %else
          mov ecx, %{3}
        %endif
      %elifnidni %{3}, ecx
        mov ecx, %{3}
      %endif
    %endif
    %ifnum %{2}
      %if %{2} == 0
        xor ebx, ebx
      %elif %{2} == -1
        or  ebx, -1
      %else
        mov ebx, %{2}
      %endif
    %elifnidni %{2}, ebx
      mov ebx, %{2}
    %endif
  %endif
  mov eax, SYS_ %+ %{1}
  int 0x80
%else
  int 0x80
%endif  
%endmacro
; ---------------------------------
; System Call Listing
; ---------------------------------

%define SYS_restart_syscall    0           ;old setup() system call
%define SYS_exit               1
%define SYS_fork               2
%define SYS_read               3
%define SYS_write              4
%define SYS_open               5
%define SYS_close              6
%define SYS_waitpid            7
%define SYS_creat              8
%define SYS_link               9
%define SYS_unlink             10
%define SYS_execve             11
%define SYS_chdir              12
%define SYS_time               13
%define SYS_mknod              14
%define SYS_chmod              15
%define SYS_lchown16           16
%define SYS_break              17          ;old break syscall holder
%define SYS_stat               18
%define SYS_lseek              19
%define SYS_getpid             20
%define SYS_mount              21
%define SYS_oldumount          22
%define SYS_setuid16           23
%define SYS_getuid16           24
%define SYS_stime              25
%define SYS_ptrace             26
%define SYS_alarm              27
%define SYS_fstat              28
%define SYS_pause              29
%define SYS_utime              30
%define SYS_stty               31          ;old stty syscall holder
%define SYS_gtty               32          ;old gtty syscall holder
%define SYS_access             33
%define SYS_nice               34
%define SYS_ftime              35          ;old ftime syscall holder
%define SYS_sync               36
%define SYS_kill               37
%define SYS_rename             38
%define SYS_mkdir              39
%define SYS_rmdir              40
%define SYS_dup                41
%define SYS_pipe               42
%define SYS_times              43
%define SYS_prof               44          ;old prof syscall holder
%define SYS_brk                45
%define SYS_setgid16           46
%define SYS_getgid16           47
%define SYS_signal             48
%define SYS_geteuid16          49
%define SYS_getegid16          50
%define SYS_acct               51
%define SYS_umount             52          ;recycled never used phys()
%define SYS_lock               53          ;old lock syscall holder
%define SYS_ioctl              54
%define SYS_fcntl              55
%define SYS_mpx                56          ;old mpx syscall holder
%define SYS_setpgid            57
%define SYS_ulimit             58          ;old ulimit syscall holder
%define SYS_olduname           59
%define SYS_umask              60
%define SYS_chroot             61
%define SYS_ustat              62
%define SYS_dup2               63
%define SYS_getppid            64
%define SYS_getpgrp            65
%define SYS_setsid             66
%define SYS_sigaction          67
%define SYS_sgetmask           68
%define SYS_ssetmask           69
%define SYS_setreuid16         70
%define SYS_setregid16         71
%define SYS_sigsuspend         72
%define SYS_sigpending         73
%define SYS_sethostname        74
%define SYS_setrlimit          75
%define SYS_old_getrlimit      76
%define SYS_getrusage          77
%define SYS_gettimeofday       78
%define SYS_settimeofday       79
%define SYS_getgroups16        80
%define SYS_setgroups16        81
%define SYS_old_select         82
%define SYS_symlink            83
%define SYS_lstat              84
%define SYS_readlink           85
%define SYS_uselib             86
%define SYS_swapon             87
%define SYS_reboot             88
%define SYS_old_readdir        89
%define SYS_readdir            89
%define SYS_old_mmap           90
%define SYS_mmap               90
%define SYS_munmap             91
%define SYS_truncate           92
%define SYS_ftruncate          93
%define SYS_fchmod             94
%define SYS_fchown16           95
%define SYS_getpriority        96
%define SYS_setpriority        97
%define SYS_profil             98          ;old profil syscall holder
%define SYS_statfs             99
%define SYS_fstatfs            100
%define SYS_ioperm             101
%define SYS_socketcall         102
%define SYS_syslog             103
%define SYS_setitimer          104
%define SYS_getitimer          105
%define SYS_newstat            106
%define SYS_newlstat           107
%define SYS_newfstat           108
%define SYS_uname              109
%define SYS_iopl               110
%define SYS_vhangup            111
%define SYS_idle               112         ;old idle syscall
%define SYS_vm86old            113
%define SYS_wait4              114
%define SYS_swapoff            115
%define SYS_sysinfo            116
%define SYS_ipc                117
%define SYS_fsync              118
%define SYS_sigreturn          119
%define SYS_clone              120
%define SYS_setdomainname      121
%define SYS_newuname           122
%define SYS_modify_ldt         123
%define SYS_adjtimex           124
%define SYS_mprotect           125
%define SYS_sigprocmask        126
%define SYS_create_module      127         ;old create_module syscall
%define SYS_init_module        128
%define SYS_delete_module      129
%define SYS_get_kernel_syms    130         ;old get_kernel_syms
%define SYS_quotactl           131
%define SYS_getpgid            132
%define SYS_fchdir             133
%define SYS_bdflush            134
%define SYS_sysfs              135
%define SYS_personality        136
%define SYS_afs_syscall        137         ;reserved for andrew file system syscall
%define SYS_setfsuid16         138
%define SYS_setfsgid16         139
%define SYS_llseek             140
%define SYS_getdents           141
%define SYS_select             142
%define SYS_flock              143
%define SYS_msync              144
%define SYS_readv              145
%define SYS_writev             146
%define SYS_getsid             147
%define SYS_fdatasync          148
%define SYS_sysctl             149
%define SYS_mlock              150
%define SYS_munlock            151
%define SYS_mlockall           152
%define SYS_munlockall         153
%define SYS_sched_setparam     154
%define SYS_sched_getparam     155
%define SYS_sched_setscheduler 156
%define SYS_sched_getscheduler 157
%define SYS_sched_yield        158
%define SYS_sched_get_priority_max 159
%define SYS_sched_get_priority_min 160
%define SYS_sched_rr_get_interval  161
%define SYS_nanosleep          162
%define SYS_mremap             163
%define SYS_setresuid16        164
%define SYS_getresuid16        165
%define SYS_vm86               166
%define SYS_query_module       167         ;old SYS_query_module
%define SYS_poll               168
%define SYS_nfsservctl         169
%define SYS_setresgid16        170
%define SYS_getresgid16        171
%define SYS_prctl              172
%define SYS_rt_sigreturn       173
%define SYS_rt_sigaction       174
%define SYS_rt_sigprocmask     175
%define SYS_rt_sigpending      176
%define SYS_rt_sigtimedwait    177
%define SYS_rt_sigqueueinfo    178
%define SYS_rt_sigsuspend      179
%define SYS_pread64            180
%define SYS_pwrite64           181
%define SYS_chown16            182
%define SYS_getcwd             183
%define SYS_capget             184
%define SYS_capset             185
%define SYS_sigalstack         186
%define SYS_sendfile           187
%define SYS_getpmsg            188         ;reserved for streams1
%define SYS_putpmsg            189         ;reserved for streams2
%define SYS_vfork              190
%define SYS_getrlimit          191
%define SYS_mmap_pgoff         192
%define SYS_truncate64         193
%define SYS_ftruncate64        194
%define SYS_stat64             195
%define SYS_lstat64            196
%define SYS_fstat64            197
%define SYS_lchown             198
%define SYS_getuid             199
%define SYS_getgid             200
%define SYS_geteuid            201
%define SYS_getegid            202
%define SYS_setreuid           203
%define SYS_setregid           204
%define SYS_getgroups          205
%define SYS_setgroups          206
%define SYS_fchown             207
%define SYS_setresuid          208
%define SYS_getresuid          209
%define SYS_setresgid          210
%define SYS_getresgid          211
%define SYS_chown              212
%define SYS_setuid             213
%define SYS_setgid             214
%define SYS_setfsuid           215
%define SYS_setfsgid           216
%define SYS_pivot_root         217
%define SYS_mincore            218
%define SYS_madvise            219
%define SYS_getdents64         220
%define SYS_fcntl64            221
; SYS_ni_syscall        222         ;reserved for TUX
; SYS_ni_syscall        223
%define SYS_gettid             224
%define SYS_readahead          225
%define SYS_setxattr           226
%define SYS_lsetxattr          227
%define SYS_fsetxattr          228
%define SYS_getxattr           229
%define SYS_lgetxattr          230
%define SYS_fgetxattr          231
%define SYS_listxattr          232
%define SYS_llistxattr         233
%define SYS_flistxattr         234
%define SYS_removexattr        235
%define SYS_lremovexattr       236
%define SYS_fremovexattr       237
%define SYS_tkill              238
%define SYS_sendfile64         239
%define SYS_futex              240
%define SYS_sched_set_affinity 241
%define SYS_sched_get_affinity 242
%define SYS_set_thread_area    243
%define SYS_get_thread_area    244
%define SYS_io_setup           245
%define SYS_io_destroy         246
%define SYS_io_getevents       247
%define SYS_io_submit          248
%define SYS_io_cancel          249
%define SYS_fadvise64          250
; SYS_ni_syscall        251
%define SYS_exit_group         252
%define SYS_lookup_dcookie     253
%define SYS_epoll_create       254
%define SYS_epoll_ctl          255
%define SYS_epoll_wait         256
%define SYS_remap_file_pages   257
%define SYS_set_tid_address    258
%define SYS_timer_create       259
%define SYS_timer_settime      260
%define SYS_timer_gettime      261
%define SYS_timer_getoverrun   262
%define SYS_timer_delete       263
%define SYS_clock_settime      264
%define SYS_clock_gettime      265
%define SYS_clock_getres       266
%define SYS_clock_nanosleep    267
%define SYS_statfs64           268
%define SYS_fstatfs64          269
%define SYS_tgkill             270
%define SYS_utimes             271
%define SYS_fadvise64_64       272
%define SYS_vserver            273
%define SYS_mbind              274
%define SYS_get_mempolicy      275
%define SYS_set_mempolicy      276
%define SYS_mq_open            277
%define SYS_mq_unlink          278
%define SYS_mq_timedsend       279
%define SYS_mq_timedreceive    280
%define SYS_mq_notify          281
%define SYS_mq_getsetattr      282
%define SYS_kexec_load         283
%define SYS_waitid             284
; SYS_ni_syscall        285         ;available
%define SYS_add_key            286
%define SYS_request_key        287
%define SYS_keyctl             288
%define SYS_ioprio_set         289
%define SYS_ioprio_get         290
%define SYS_inotify_init       291
%define SYS_inotify_add_watch  292
%define SYS_inotify_rm_watch   293
%define SYS_migrate_pages      294
%define SYS_openat             295
%define SYS_mkdirat            296
%define SYS_mknodat            297
%define SYS_fchownat           298
%define SYS_futimesat          299
%define SYS_fstatat64          300
%define SYS_unlinkat           301
%define SYS_renameat           302
%define SYS_linkat             303
%define SYS_symlinkat          304
%define SYS_readlinkat         305
%define SYS_fchmodat           306
%define SYS_faccessat          307
%define SYS_pselect6           308
%define SYS_ppoll              309
%define SYS_unshare            310
%define SYS_set_robust_list    311
%define SYS_get_robust_list    312
%define SYS_splice             313
%define SYS_sync_file_range    314
%define SYS_tee                315
%define SYS_vmsplice           316
%define SYS_move_pages         317
%define SYS_getcpu             318
%define SYS_epoll_pwait        319
%define SYS_utimensat          320
%define SYS_signalfd           321
%define SYS_timerfd_create     322
%define SYS_eventfd            323
%define SYS_fallocate          324
%define SYS_timerfd_settime    325
%define SYS_timerfd_gettime    326
%define SYS_signalfd4          327
%define SYS_eventfd2           328
%define SYS_epoll_create1      329
%define SYS_dup3               330
%define SYS_pipe2              331
%define SYS_inotify_init1      332
%define SYS_preadv             333
%define SYS_pwritev            334
%define SYS_rt_tgsigqueueinfo  335
%define SYS_perf_event_open    336
%define SYS_recvmmsg           337
%define SYS_fanotify_event     338
%define SYS_fanotify_mark      339
%define SYS_prlimit64          340

%endif