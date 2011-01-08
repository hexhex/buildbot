#!/bin/sh

#MAILTO="dlvhex-nightlies@lists.sourceforge.net"
MAILTO="ps@kr.tuwien.ac.at tkren@kr.tuwien.ac.at"
SVN_ROOT=/home/staff/ps/Documents/dlvhex
SVN_ROOT_BOOST=/home/staff/ps/Documents/tools/boost
LOGDIR=/home/staff/ps/Documents/dlvhex/dlvhex-release-builder/logs
WEBLOGDIR=pg/ps/dlvhex/nightly
FSWEBLOGDIR=/srv/www/htdocs/ps/dlvhex/nightly
TESTDIR=/home/staff/ps/Documents/dlvhex/dlvhex-release-builder/testdir_withboost/
BOOST_BRANCHES="release trunk"
LOGBASENAME=build_withboost_`date +%F_%R`
LOGFILE=${LOGDIR}/${LOGBASENAME}.log
#LOGFILE=~ps/test.log
MAILFILE=${LOGDIR}/${LOGBASENAME}.mail
#MAILFILE=~ps/test.mail
TIMELIMIT="timelimit -t 1800 -T 5" # SIGTERM after 30 minutes, SIGKILL 5 seconds later

# create logdir if it does not exist yet
test -d ${LOGDIR} || mkdir ${LOGDIR}
test -d ${TESTDIR} || mkdir ${TESTDIR}

export LD_LIBRARY_PATH=/home/staff/ps/common/lib/:/home/staff/ps/lib/:${LD_LIBRARY_PATH}
export PATH=/home/staff/ps/common/bin/:/home/staff/ps/bin/:${PATH}
export PKG_CONFIG_PATH=/home/staff/ps/lib/pkgconfig:/usr/lib/pkgconfig:${PKG_CONFIG_PATH}

# update boost branches
for boost in ${BOOST_BRANCHES}; do
  THISTESTDIR=${TESTDIR}/${boost}
  test -d ${THISTESTDIR} || mkdir -p ${THISTESTDIR}
  THISBOOSTPREFIX=${THISTESTDIR}/boost_instdir

  (
    export BZIP2_INCLUDE=/home/staff/ps/include/
    export BZIP2_LIBPATH=/home/staff/ps/lib/ 
    test -d ${THISTESTDIR} || echo "ERROR boost checkout ${THISBOOSTDIR} not found"
    d=$SVN_ROOT_BOOST/$boost
    echo "updating boost: $d"
    svn --non-interactive up $d || echo "ERROR doing svn up in $d"
    cd $d &&
    (
    svn --non-interactive revert -R . || echo "ERROR doing svn revert in $d"
    svn --no-ignore st |grep -v "^....X" |cut -b2-100 |xargs rm -rf || echo "ERROR removing ? files in $d"
    echo "bootstrapping boost: $d"
    ./bootstrap.sh \
      --prefix=${THISBOOSTPREFIX} \
      --without-libraries=python,serialization || echo "ERROR doing bootstrap.sh in $d"
    echo "building boost: $d"
    ./bjam || echo "ERROR doing bjam in $d"
    echo "installing boost: $d"
    ./bjam install || echo "ERROR doing bjam install in $d"
    )
  ) >>${LOGFILE} 2>&1
done

# svn up in all trunk directories (plus logging)
(
  DIRS="dlvhex dlvhex-stringplugin dlvhex-aggregateplugin dlvhex-scriptplugin dlvhex-wordnetplugin dlvhex-dlplugin dlvhex-mcs/mcs-ie semweb/dlvhex-rdfplugin"
  for dd in $DIRS; do
    d=$SVN_ROOT/$dd/trunk
    echo "updating $d"
    # use svn from ps bindir
    svn --non-interactive up --set-depth infinity $d || echo "ERROR doing svn up in $d"
    pushd $d
    svn --non-interactive revert -R . || echo "ERROR doing svn revert in $d"
    svn --no-ignore st |grep -v "^....X" |cut -b2-100 |xargs rm -rf || echo "ERROR removing ? files in $d"
    ./bootstrap.sh || echo "ERROR doing bootstrap.sh in $d"
    popd
  done
) >>${LOGFILE} 2>&1

# call buildscript and measure time
for boost in ${BOOST_BRANCHES}; do
  THISTESTDIR=${TESTDIR}/${boost}
  test -d ${THISTESTDIR} || mkdir -p ${THISTESTDIR}
  THISBOOSTPREFIX=${THISTESTDIR}/boost_instdir

  (
    echo "=== USING BOOST $boost ===";
    time \
    ${TIMELIMIT} \
    ${SVN_ROOT}/dlvhex-release-builder/build_and_test_release.sh \
      ${THISTESTDIR} ${THISBOOSTPREFIX}/include
  ) >>${LOGFILE} 2>&1
done

# find out if successful
ERRORS=`grep -c "^ERROR" ${LOGFILE}`
if test "$ERRORS" -eq  "0"; then
  SUBJECT="auto_build_test_includingboost.sh PASS (0 errors)"
else
  SUBJECT="auto_build_test_includingboost.sh FAIL ($ERRORS errors)"
fi

# copy logfile to web
cp ${LOGFILE} ${FSWEBLOGDIR}/${LOGBASENAME}.txt

# create mail: summarize
egrep "^=== USING BOOST|^FAIL|^WARN|^ERROR|failed.*warnings$|^Tested|^All|ready for distribution|^[^ ]+.tar.gz$" \
  ${LOGFILE} >${MAILFILE}

# create mail: don't append log but put location of log into mail
#cat ${LOGFILE} >>${MAILFILE}
echo "" >>${MAILFILE}
echo "Full Logfile: ${LOGFILE}">>${MAILFILE}
echo "Web Logfile: http://www.kr.tuwien.ac.at/${WEBLOGDIR}/${LOGBASENAME}.txt">>${MAILFILE}
echo "" >>${MAILFILE}

# send mail
cat ${MAILFILE} | mail -s "${SUBJECT}" ${MAILTO}

