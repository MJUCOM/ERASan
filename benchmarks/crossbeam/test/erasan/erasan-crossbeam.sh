#!/bin/bash

# immediately stop building if error occurs
set -e

# Make sure that you set the environmetal settings by ERASan/env/env.sh

# Also make sure that you set the LLVM pass to ERASan.cpp by using ERASan/build/erasan.sh before conducting benchmark test
#
# cd ERASan/build
# ./erasan.sh
#

export TEST=$PWD
export BINARY_DIR=$TEST/../../build/crossbeam/crossbeam-utils
LIBRARY_DIR="$BUILD_DIR/rust/build/x86_64-unknown-linux-gnu/stage1/lib/rustlib/x86_64-unknown-linux-gnu/lib"
RLIBS=$(find $LIBRARY_DIR -name "*.rlib")
cp $TEST/../total.ll $TEST

erasan total.ll -erasan
opt --asan-module -S erasanOptAnalysis.ll -o erasanOptAnalysis.ll
llvm-as erasanOptAnalysis.ll -o erasanOptAnalysis.bc
llc -filetype=obj erasanOptAnalysis.bc -o erasanOptAnalysis.o
clang erasanOptAnalysis.o -o erasan -L$LIBRARY_DIR -lstd-bc021c2817d56996 -lpthread -ldl -lm -fsanitize=address -lssl -lcrypto $RLIBS $RLIBS
cp erasan $BINARY_DIR
cd $BINARY_DIR
./erasan --bench

