cmd_/root/src/linux/tools/objtool/str_error_r.o := gcc -Wp,-MD,/root/src/linux/tools/objtool/.str_error_r.o.d -Wp,-MT,/root/src/linux/tools/objtool/str_error_r.o -Werror -Wbad-function-cast -Wdeclaration-after-statement -Wformat-security -Wformat-y2k -Winit-self -Wmissing-declarations -Wmissing-prototypes -Wnested-externs -Wno-system-headers -Wold-style-definition -Wpacked -Wredundant-decls -Wstrict-prototypes -Wswitch-default -Wswitch-enum -Wundef -Wwrite-strings -Wformat -Wno-type-limits -Wstrict-aliasing=3 -Wshadow -Wno-switch-default -Wno-switch-enum -Wno-packed -Wno-nested-externs -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu11 -I ./scripts/include -Werror -g -I/root/src/linux/tools/include -I/root/src/linux/tools/include/uapi -I/root/src/linux/tools/arch/x86/include/uapi -I/root/src/linux/tools/arch/x86/include -I/root/src/linux/tools/objtool/include -I/root/src/linux/tools/objtool/arch/x86/include -I/root/src/linux/tools/objtool/libsubcmd/include -D"BUILD_STR(s)=$(pound)s" -c -o /root/src/linux/tools/objtool/str_error_r.o ../lib/str_error_r.c

source_/root/src/linux/tools/objtool/str_error_r.o := ../lib/str_error_r.c

deps_/root/src/linux/tools/objtool/str_error_r.o := \
  /usr/include/stdc-predef.h \
  /usr/include/fortify/string.h \
  /usr/include/string.h \
  /usr/include/features.h \
  /usr/include/bits/alltypes.h \
  /usr/include/fortify/strings.h \
  /usr/include/strings.h \
  /usr/include/fortify/fortify-headers.h \
  /usr/include/fortify/stdio.h \
  /usr/include/stdio.h \
  /root/src/linux/tools/include/linux/string.h \
  /root/src/linux/tools/include/linux/types.h \
  /usr/include/stdbool.h \
  /usr/include/stddef.h \
  /usr/include/stdint.h \
  /usr/include/bits/stdint.h \
  /usr/include/asm/types.h \
  /usr/include/asm-generic/types.h \
  /usr/include/asm-generic/int-ll64.h \
  /root/src/linux/tools/include/uapi/asm/bitsperlong.h \
  /root/src/linux/tools/arch/x86/include/uapi/asm/bitsperlong.h \
  /root/src/linux/tools/include/asm-generic/bitsperlong.h \
  /root/src/linux/tools/include/uapi/asm-generic/bitsperlong.h \
  /usr/include/asm/posix_types.h \
  /usr/include/asm/posix_types_64.h \
  /usr/include/asm-generic/posix_types.h \

/root/src/linux/tools/objtool/str_error_r.o: $(deps_/root/src/linux/tools/objtool/str_error_r.o)

$(deps_/root/src/linux/tools/objtool/str_error_r.o):
