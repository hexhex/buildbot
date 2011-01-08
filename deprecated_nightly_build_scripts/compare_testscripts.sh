#!/bin/bash

# this script compares the run-dlvhex-tests.sh scripts in all trunk/ directories
# (there should only exists two variants, and fixes should be cross-ported)
# (perhaps we should use svn:externals and use only one variant?)

# call this script from this directory

# relative(!) path to repository root (the directory where dlvhex, dlvhex-*plugin directories are inside)
SVN_CHECKOUT_ROOT=..

# variant 1 is in dlvhex
VARIANT1=$SVN_CHECKOUT_ROOT/dlvhex/trunk/src/testsuite/dlvhex/run-dlvhex-tests.sh
# variant 2 originated in dlplugin
VARIANT2=$SVN_CHECKOUT_ROOT/dlvhex-dlplugin/trunk/testsuite/run-dlvhex-tests.sh
FILES=`find .. -name run-dlvhex-tests.sh |grep "trunk\/"`

for f in $FILES; do
  OK=0
  if diff $f $VARIANT1 >/dev/null; then
    OK=1
  fi
  if diff $f $VARIANT2 >/dev/null; then
    OK=1
  fi
  if test $OK -eq 0; then
    echo "$f has changes!"
    echo "\tdiff $f $VARIANT1"
    echo "\tdiff $f $VARIANT2"
  else
    echo "$f is ok!"
  fi
done

