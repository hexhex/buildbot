#!/bin/bash

ERROR="ERROR doing build_test_release.sh"
set -v
set -x

# call this script without parameters
# (building with default boost and into default directory)
# or with one parameter (build directory)
# or with two parameters (build directory, boost directory)

#######################################################################
# release will be built into the following directory and subdirectories
#######################################################################
# (get as first commandline parameter, or use default)
ROOT=${1:-/home/staff/ps/Documents/dlvhex/dlvhex-release-builder}

#################
# start of config
#################

# absolute(!) paths

# to repository root (the directory where dlvhex and $PLUGINS are inside)
SVN_ROOT=/home/staff/ps/Documents/dlvhex
# to the directory where the boost is installed which shall be used
# (get as second commandline parameter, or use default)
BOOSTDIR=${2:-/home/staff/ps/include/boost-1_42}
# extra CFLAGS for customly built headers (wordnet, cppunit)
EXTRA_CFLAGS=-I/home/staff/ps/include
# extra LDFLAGS for customly built headers (wordnet, cppunit)
EXTRA_LDFLAGS=-L/home/staff/ps/lib

# which plugins shall be built
PLUGINS="dlvhex-stringplugin dlvhex-aggregateplugin dlvhex-scriptplugin dlvhex-wordnetplugin dlvhex-dlplugin dlvhex-mcs/mcs-ie semweb/dlvhex-rdfplugin"
PARALLEL=""
BUILD_DLVHEX=/bin/true
### EDIT BELOW ###
### EDIT BELOW ###
### EDIT BELOW ###
PLUGINS="dlvhex-mergingplugin"
PARALLEL=" -j 5 "
BUILD_DLVHEX=/bin/false
# plugins which are known not to work: xpathplugin actionplugin

###############
# end of config
###############

DLVHEX_ROOT=$SVN_ROOT/dlvhex/trunk
INSTALLDIR=${ROOT}/instdir

function disp_versions()
{
  # display versions of all trunks
  (
    set +x
    set +v
    echo -n "dlvhex @ "
    svnversion $DLVHEX_ROOT
    for plugin in $PLUGINS; do
      echo -n "$plugin @ "
      svnversion $SVN_ROOT/$plugin/trunk
    done
  )
}

disp_versions

# remove whole installdir (we need a clean space for testing,
# especially for make distcheck which otherwise finds duplicate plugins)
#test -d ${INSTALLDIR} && rm -rf ${INSTALLDIR}

# create installdir
mkdir ${INSTALLDIR}

### EDIT BELOW ###
### EDIT BELOW ###
### EDIT BELOW ###
# use this "if" to comment out the dlvhex core build
if ${BUILD_DLVHEX}; then
  DD=${ROOT}/dlvhex_builddir
  echo "=== configuring and building dlvhex into ${DD} ==="
  test ! -d ${DD} && mkdir ${DD}
  pushd ${DD}
    # subshell where we can mess with the environment
    (
      export LDFLAGS=${EXTRA_LDFLAGS}
      export CPPFLAGS=${EXTRA_CFLAGS}
      # maintainer-clean (do not reconfigure, try to clean as much as possible)
      test -f Makefile && touch Makefile && make -k distclean
      # configure
      ${DLVHEX_ROOT}/configure --prefix=${INSTALLDIR} \
        --with-boost=${BOOSTDIR} || echo ${ERROR}
      # test and create package
      #make distcheck || echo ${ERROR}
      # install it to instdir for manual testing/usage by further tests
      make ${PARALLEL}|| echo ${ERROR}
			make check || echo ${ERROR}
      make install || echo ${ERROR}
    )
  popd
fi

# use this "if" to comment out the plugin builds
if /bin/true; then
  for plugin in $PLUGINS; do
    DD=${ROOT}/${plugin}_builddir
    echo "=== configuring and building $plugin into ${DD} ==="
    test ! -d ${DD} && mkdir -p ${DD}
    pushd ${DD}
      # subshell where we can mess with the environment
      (
        export LDFLAGS=${EXTRA_LDFLAGS}
        export CPPFLAGS=${EXTRA_CFLAGS}
        export PATH=${INSTALLDIR}/bin:${PATH}
        export LD_LIBRARY_PATH=${INSTALLDIR}/lib:${LD_LIBRARY_PATH}
        export PKG_CONFIG_PATH=${INSTALLDIR}/lib/pkgconfig:/usr/lib/pkgconfig
        # maintainer-clean (do not reconfigure, try to clean as much as possible)
        test -f Makefile && touch Makefile && make -k distclean
        # configure
        ${SVN_ROOT}/$plugin/trunk/configure \
          --prefix=${INSTALLDIR} --with-boost=${BOOSTDIR} || echo ${ERROR}
        # test and create package
        #make distcheck || echo ${ERROR}
        # install it to instdir for manual testing/usage by further tests
        make ${PARALLEL}|| echo ${ERROR}
        make check || echo ${ERROR}
        make install || echo ${ERROR}
      )
    popd
  done
fi

disp_versions
