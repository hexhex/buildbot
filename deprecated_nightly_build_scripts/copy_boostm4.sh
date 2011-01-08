#!/bin/sh

# copy boost.m4 from dlvhex into all other trunk/m4/ directories
# call this script from this directory!

find .. -name boost.m4 \
  |grep "trunk\/m4\/boost.m4" \
  |xargs --replace=FILE \
     cp ../dlvhex/trunk/m4/boost.m4 FILE
