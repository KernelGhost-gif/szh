cmd_/root/src/linux/tools/objtool/librbtree.o := gcc -Wp,-MD,/root/src/linux/tools/objtool/.librbtree.o.d -Wp,-MT,/root/src/linux/tools/objtool/librbtree.o -Werror -Wbad-function-cast -Wdeclaration-after-statement -Wformat-security -Wformat-y2k -Winit-self -Wmissing-declarations -Wmissing-prototypes -Wnested-externs -Wno-system-headers -Wold-style-definition -Wpacked -Wredundant-decls -Wstrict-prototypes -Wswitch-default -Wswitch-enum -Wundef -Wwrite-strings -Wformat -Wno-type-limits -Wstrict-aliasing=3 -Wshadow -Wno-switch-default -Wno-switch-enum -Wno-packed -Wno-nested-externs -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu11 -I ./scripts/include -Werror -g -I/root/src/linux/tools/include -I/root/src/linux/tools/include/uapi -I/root/src/linux/tools/arch/x86/include/uapi -I/root/src/linux/tools/arch/x86/include -I/root/src/linux/tools/objtool/include -I/root/src/linux/tools/objtool/arch/x86/include -I/root/src/linux/tools/objtool/libsubcmd/include -D"BUILD_STR(s)=$(pound)s" -c -o /root/src/linux/tools/objtool/librbtree.o ../lib/rbtree.c

source_/root/src/linux/tools/objtool/librbtree.o := ../lib/rbtree.c

deps_/root/src/linux/tools/objtool/librbtree.o := \
  /usr/include/stdc-predef.h \
  /root/src/linux/tools/include/linux/rbtree_augmented.h \
  /root/src/linux/tools/include/linux/compiler.h \
  /root/src/linux/tools/include/linux/compiler_types.h \
  /root/src/linux/tools/include/linux/compiler-gcc.h \
  /root/src/linux/tools/include/linux/types.h \
  /usr/include/stdbool.h \
  /usr/include/stddef.h \
  /usr/include/bits/alltypes.h \
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
  /root/src/linux/tools/include/linux/rbtree.h \
  /root/src/linux/tools/include/linux/kernel.h \
  /usr/include/stdarg.h \
  /usr/include/assert.h \
  /usr/include/features.h \
  /root/src/linux/tools/include/linux/build_bug.h \
  /root/src/linux/tools/include/linux/math.h \
  /root/src/linux/tools/include/linux/panic.h \
  /usr/include/fortify/stdio.h \
  /usr/include/stdio.h \
  /usr/include/fortify/fortify-headers.h \
  /usr/include/fortify/stdlib.h \
  /usr/include/stdlib.h \
  /usr/include/alloca.h \
  /usr/include/limits.h \
  /usr/include/bits/limits.h \
  /usr/include/endian.h \
  /usr/include/byteswap.h \
  /root/src/linux/tools/include/linux/container_of.h \
  /root/src/linux/tools/include/uapi/linux/stddef.h \
  /root/src/linux/tools/include/linux/export.h \

/root/src/linux/tools/objtool/librbtree.o: $(deps_/root/src/linux/tools/objtool/librbtree.o)

$(deps_/root/src/linux/tools/objtool/librbtree.o):
