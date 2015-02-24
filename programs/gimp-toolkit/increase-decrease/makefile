NAME=inc-dec
AS=nasm
LD=ld

O           = .o
ASM         = .asm
INC         = .inc
LST         = .lst
ASFLAGS     = "-felf64"
LDFLAGS     = -s -melf_x86_64

OBJS = $(NAME)$(O)
LIBS=-lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0 -lgdk_pixbuf-2.0
####   -lgdk-3 -latk-1.0 -lgio-2.0 -lpangoft2-1.0  -lpangocairo-1.0 -lcairo -lpango-1.0 -lfreetype -lfontconfig  -lgmodule-2.0 -lgthread-2.0 -lrt -lglib-2.0

OBJS = $(NAME)$(O)

$(NAME): $(OBJS)
	$(LD) $(LDFLAGS) -o $(NAME) $(OBJS) $(LIBS)

$(NAME)$(O): $(NAME)$(ASM)
	$(AS) $(ASFLAGS) $(NAME)$(ASM) -l $(NAME)$(LST) -o $(NAME)$(O)
all:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME)
debug:
	touch $(NAME)$(ASM)
	$(MAKE) $(NAME) ASFLAGS="-felf64 -Fstabs -g" LDFLAGS="-g -melf_x86_64"
	valgrind --tool=callgrind --dump-instr=yes --collect-jumps=yes ./$(NAME)
clean:
	@rm -f *.out.* $(NAME) $(NAME)$(LST) $(NAME)$(O)