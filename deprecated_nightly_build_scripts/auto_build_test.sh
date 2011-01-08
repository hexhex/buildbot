#!/bin/sh

MAILTO="dlvhex-nightlies@lists.sourceforge.net"
#MAILTO="ps@kr.tuwien.ac.at"
SVN_ROOT=/home/staff/ps/Documents/dlvhex
LOGDIR=/home/staff/ps/Documents/dlvhex/dlvhex-release-builder/logs
WEBLOGDIR=pg/ps/dlvhex/nightly
FSWEBLOGDIR=/srv/www/htdocs/ps/dlvhex/nightly
TESTDIR=/home/staff/ps/Documents/dlvhex/dlvhex-release-builder/testdir/
BOOST_BASEINCLUDEDIR=/home/staff/ps/include/
BOOST_VERSIONS="boost-1_41 boost-1_42 boost-1_43 boost-1_44 boost-1_45"
#BOOST_VERSIONS="boost-1_42"
LOGBASENAME=build_`date +%F_%R`
LOGFILE=${LOGDIR}/${LOGBASENAME}.log
MAILFILE=${LOGDIR}/${LOGBASENAME}.mail
TIMELIMIT="timelimit -t 1800 -T 5" # SIGTERM after 30 minutes, SIGKILL 5 seconds later

# create logdir if it does not exist yet
test -d ${LOGDIR} || mkdir ${LOGDIR}
test -d ${TESTDIR} || mkdir ${TESTDIR}

export LD_LIBRARY_PATH=/home/staff/ps/common/lib/:/home/staff/ps/lib/:${LD_LIBRARY_PATH}
export PATH=/home/staff/ps/common/bin/:/home/staff/ps/bin/:${PATH}
export PKG_CONFIG_PATH=/home/staff/ps/lib/pkgconfig:/usr/lib/pkgconfig:${PKG_CONFIG_PATH}

# svn up in all trunk directories (plus logging)
(
  DIRS="dlvhex dlvhex-stringplugin dlvhex-aggregateplugin dlvhex-scriptplugin dlvhex-wordnetplugin dlvhex-dlplugin dlvhex-mcs/mcs-ie semweb/dlvhex-rdfplugin"
  for dd in $DIRS; do
    d=$SVN_ROOT/$dd/trunk
    echo "updating $d$"
    # use svn from ps bindir
    svn --non-interactive up --set-depth infinity $d || echo "ERROR doing svn up in $d"
    pushd $d
    svn --non-interactive revert -R . || echo "ERROR doing svn revert in $d"
    svn --no-ignore st |grep -v "^    X" |cut -b2-100 |xargs rm -rf || echo "ERROR removing ? files in $d"
    ./bootstrap.sh || echo "ERROR doing bootstrap.sh in $d"
    popd
  done
) >>${LOGFILE} 2>&1

# do the test for several boost versions
for boost in ${BOOST_VERSIONS}; do
  THISTESTDIR=${TESTDIR}/${boost}
  test -d ${THISTESTDIR} || mkdir ${THISTESTDIR}
  THISBOOSTINCLUDEDIR=${BOOST_BASEINCLUDEDIR}/${boost}

  # call buildscript and measure time
  (
    echo "=== USING BOOST $boost ===";
    time \
    ${TIMELIMIT} \
    ${SVN_ROOT}/dlvhex-release-builder/build_and_test_release.sh \
      ${THISTESTDIR} ${THISBOOSTINCLUDEDIR}
    2>&1
  ) >>${LOGFILE} 2>&1
done

# find out if successful
ERRORS=`grep -c "^ERROR" ${LOGFILE}`
if test "$ERRORS" -eq  "0"; then
  SUBJECT="auto_build_test.sh PASS (0 errors)"
else
  SUBJECT="auto_build_test.sh FAIL ($ERRORS errors)"
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

