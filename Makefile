# Mf-a6osx
# Copyright 1984-2017 Cisco Systems, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

m = a6osx
Cpu = X86_64

mdclib = -liconv -lm ${ncursesLib}
C = ${CC} ${CPPFLAGS} -m64 -Wpointer-arith -Wall -Wextra -Wno-implicit-fallthrough -Werror -O2 -I/opt/X11/include/ ${CFLAGS}
o = o
mdsrc = i3le.c
mdobj = i3le.o

.SUFFIXES:
.SUFFIXES: .c .o

.c.o:
	$C -c -D${Cpu} -I${Include} ${zlibInc} ${LZ4Inc} $*.c

CC=gcc
CPPFLAGS=
CFLAGS=
LD=ld
LDFLAGS=
AR=ar
ARFLAGS=rc
RANLIB=ranlib
WINDRES=windres
cursesLib=-lcurses
ncursesLib=-lncurses
zlibInc=-Izlib
LZ4Inc=-Ilz4/lib
zlibDep=zlib/libz.a
LZ4Dep=lz4/lib/liblz4.a
zlibLib=zlib/libz.a
LZ4Lib=lz4/lib/liblz4.a
zlibHeaderDep=zlib/zconf.h zlib/zlib.h
LZ4HeaderDep=lz4/lib/lz4.h lz4/lib/lz4frame.h
Kernel=${KernelO}
KernelLinkDeps=${KernelOLinkDeps}
KernelLinkLibs=${KernelOLinkLibs}

Include=boot/$m
PetiteBoot=boot/$m/petite.boot
SchemeBoot=boot/$m/scheme.boot
Main=boot/$m/main.$o
Scheme=bin/$m/scheme

# One of these sets is referenced in Mf-config to select between
# linking with kernel.o or libkernel.a

KernelO=boot/$m/kernel.$o
KernelOLinkDeps=
KernelOLinkLibs=

KernelLib=boot/$m/libkernel.a
KernelLibLinkDeps=${zlibDep} ${LZ4Dep}
KernelLibLinkLibs=${zlibLib} ${LZ4Lib}

kernelsrc=statics.c segment.c alloc.c symbol.c intern.c gcwrapper.c gc-ocd.c gc-oce.c\
 number.c schsig.c io.c new-io.c print.c fasl.c stats.c foreign.c prim.c prim5.c flushcache.c\
 schlib.c thread.c expeditor.c scheme.c compress-io.c

kernelobj=${kernelsrc:%.c=%.$o} ${mdobj}

kernelhdr=system.h types.h version.h globals.h externs.h segment.h gc.c sort.h thread.h config.h compress-io.h itest.c nocurses.h

mainsrc=main.c

mainobj:=${mainsrc:%.c=%.$o}

doit: ${Scheme}

source: ${kernelsrc} ${kernelhdr} ${mdsrc} ${mainsrc}

${Main}: ${mainobj}
	cp -p ${mainobj} ${Main}

scheme.o: itest.c
scheme.o main.o: config.h
${kernelobj}: system.h types.h version.h externs.h globals.h segment.h thread.h sort.h compress-io.h nocurses.h
${kernelobj}: ${Include}/equates.h ${Include}/scheme.h
${mainobj}: ${Include}/scheme.h
${kernelobj}: ${zlibHeaderDep} ${LZ4HeaderDep}
gc-ocd.o gc-oce.o: gc.c

zlib/zlib.h zlib/zconf.h: zlib/configure.log

zlib/libz.a: zlib/configure.log
	(cd zlib; ${MAKE})

LZ4Sources=lz4/lib/lz4.h lz4/lib/lz4frame.h \
           lz4/lib/lz4.c lz4/lib/lz4frame.c \
           lz4/lib/lz4hc.c lz4/lib/xxhash.c

clean:
	rm -f *.$o ${mdclean} boot/a6osx/*.$o
	rm -f Make.out
	rm -f bin/a6osx/scheme

${KernelO}: ${kernelobj} ${zlibDep} ${LZ4Dep}
	${LD} -r -o ${KernelO} ${kernelobj} ${zlibLib} ${LZ4Lib}

${KernelLib}: ${kernelobj}
	${AR} ${ARFLAGS} ${KernelLib} ${kernelobj}

${Scheme}: ${Kernel} ${KernelLinkDeps} ${Main}
	$C -o ${Scheme} ${Main} ${Kernel} ${mdclib} ${KernelLinkLibs} ${LDFLAGS}

zlib/configure.log:
	(cd zlib; CFLAGS="${CFLAGS} -m64" ./configure --64)

lz4/lib/liblz4.a: ${LZ4Sources}
	(cd lz4/lib; CFLAGS="${CFLAGS} -m64" ${MAKE} liblz4.a)