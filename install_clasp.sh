#!/bin/bash

# getting args:
# $1 = daemon directory
# $2 = target directory

# our task: copy structure and all .{h,hpp,a} and some binaries

DDIR=$1/build/
TDIR=$2/

test -n "${DDIR}" || exit 1
test -n "${TDIR}" || exit 1

# dbg
echo $DDIR
echo $TDIR

# clean target
rm -rf $TDIR

#set -x

# sync {h,hpp,a} files
rsync -rv \
  --exclude=tests \
  --exclude="*cmake*" --exclude="*Make*" \
  --exclude="*.dep" --exclude="*.vcproj" --exclude="*.sln" \
  --exclude=".svn" \
  --exclude="*.cpp" --exclude="*.o" \
  $DDIR $TDIR 

# permissions for all users
chmod -R ugo+X,ugo+r $TDIR
chmod -R ugo+x $TDIR/build/release/bin/

exit 0
