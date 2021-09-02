default_target: all

LIB_PREFIX        ?= /usr/local/lib
CC                 = clang -O2 -g -Wall
CLANG_GEN_IDR_LIB  = clang -O2 -g -Wall -shared -fPIC

all: init fmt isocline readline doc test install

install: readline
	(idris2 --install readline.ipkg)
	(rm -rf ${LIB_PREFIX}/libisocline.so)
	(cp ./libisocline.so ${LIB_PREFIX}/)

clean:
	(idris2 --clean readline.ipkg)
	(cd ./rltest || exit && \
		idris2 --clean rltest.ipkg)
	(cd ./depends/isocline || exit && \
		make clean                   && \
		rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake a.out)
	(rm -rf build libisocline.so)

init:
	(cd ./depends/isocline && \
		git checkout idris)

fmt:
	(clang-format -i ./depends/isocline/src/idris.c)

doc:
	(idris2 --mkdoc readline.ipkg)

isocline:
	(cd ./depends/isocline || exit    && \
		cmake CMakeLists.txt            && \
		make all                        && \
		$(CLANG_GEN_IDR_LIB) ./src/idris.c \
			-o ../../libisocline.so)

test: readline
	(cd ./rltest || exit && \
		idris2 --build rltest.ipkg)
	(cd ./rltest && \
		./build/exec/runtests idris2 --interactive --failure-file failures)

readline:
	(idris2 --build readline.ipkg)