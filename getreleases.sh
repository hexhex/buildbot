BASE=/var/lib/buildbot/dlvhex-slave
mkdir pkgdir || { echo "please remove dir!"; exit -1; }

#pushd ${BASE}/dlvhex-1.7.3-boost-1_42-g++-4.5/build
#make doxygen-doc
#tar cvzf dlvhex-1.7.3-doxygen-html.tar.gz doc/html/ --transform='s/^doc\/html/dlvhex-1.7.3-doxygen-html/'
#popd
cp ${BASE}/dlvhex-1.7.3-boost-1_42-g++-4.5/build/dlvhex-1.7.3-doxygen-html.tar.gz pkgdir
cp ${BASE}/dlvhex-1.7.3-boost-1_42-g++-4.5/build/dlvhex-1.7.3.tar.gz pkgdir
cp ${BASE}/dlvhex-1.7.3-boost-1_42-g++-4.5/build/dlvhex-1.7.3.tar.gz pkgdir
cp ${BASE}/plugin-aggregate-dlvhex-1.7.3-boost-1_42-g++-4.5/build/dlvhex-aggregateplugin-1.7.1.tar.gz pkgdir
cp ${BASE}/plugin-script-dlvhex-1.7.3-boost-1_42-g++-4.5/build/dlvhex-scriptplugin-1.7.2.tar.gz pkgdir

#pushd ${BASE}/dlvhex-2.0.0-boost-1_45-g++-4.6/build
#make doxygen-doc
#tar cvzf dlvhex-2.0.0-doxygen-html.tar.gz doc/html/ --transform='s/^doc\/html/dlvhex-2.0.0-doxygen-html/'
#popd
cp ${BASE}/dlvhex-2.0.0-boost-1_45-g++-4.6/build/dlvhex-2.0.0-doxygen-html.tar.gz pkgdir
cp ${BASE}/dlvhex-2.0.0-boost-1_45-g++-4.6/build/dlvhex-2.0.0.tar.gz pkgdir
cp ${BASE}/plugin-string-dlvhex-2.0.0-boost-1_45-g++-4.6/build/dlvhex-stringplugin-2.0.0.tar.gz pkgdir
cp ${BASE}/plugin-aggregate-dlvhex-2.0.0-boost-1_45-g++-4.6/build/dlvhex-aggregateplugin-2.0.0.tar.gz pkgdir
cp ${BASE}/plugin-script-dlvhex-2.0.0-boost-1_45-g++-4.6/build/dlvhex-scriptplugin-2.0.0.tar.gz pkgdir
cp ${BASE}/plugin-wordnet-dlvhex-2.0.0-boost-1_45-g++-4.6/build/dlvhex-wordnetplugin-2.0.0.tar.gz pkgdir
