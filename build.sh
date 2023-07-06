#!/bin/bash
# to clone a single commit - https://stackoverflow.com/questions/31278902/how-to-shallow-clone-a-specific-commit-with-depth-1
# to find a commit hash - shallow clone, fetch tags, and then
# git tag to find release/11.3.0, and then git show release/11.3.0 to find
# the commit hash

# clone repos
cd $HOME/src
if ! test -d "binutils-gdb"; then
    git clone git://sourceware.org/git/binutils-gdb.git
    cd binutils-gdb
    git reset --hard 20756b0fbe065a84710aa38f2457563b57546440
fi

cd $HOME/src
if ! test -d "gcc"; then
    mkdir gcc
    cd gcc
    git init
    git remote add origin git://gcc.gnu.org/git/gcc.git
    git fetch --depth 1 origin 2d280e7eafc086e9df85f50ed1a6526d6a3a204d 
    git checkout FETCH_HEAD
fi
# build cmd goes here

# build
# env vars
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

mkdir $HOME/src
cd $HOME/src
mkdir build-binutils
cd build-binutils
../binutils-gdb/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot \
    --disable-nls --disable-werror
make
make install

cd $HOME/src

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

mkdir build-gcc
cd build-gcc
../gcc/configure --target=$TARGET --prefix="$PREFIX" --disable-nls \
    --enable-languages=c,c++ --without-headers
make -j 4 all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc

