#!/bin/bash
UNIXTIME=$(date +%s)
DEPLOY_TO=server@senjuctf.lab
WEBROOT=/srv/senjuCTF # if you unset this, everything will explode
TMP_FILE=$(printf "/tmp/%s_site.tar.gz" "$UNIXTIME")
set -e

echo building website
bash ./build.sh

echo making archive...
tar --zstd -cvf $TMP_FILE
echo uploading archive to $DEPLOY_TO : "$TMP_FILE"
scp $TMP_FILE $DEPLOY_TO:"$TMP_FILE"
echo installing archive in webroot: $WEBROOT
echo "
set -e
mkdir -p $WEBROOT
rm -rvf $WEBROOT/* $WEBROOT/.*
tar --zstd -xvf $TMP_FILE --directory $WEBROOT
rm -vf $TMP_FILE
mv -fv $WEBROOT/_site/* $WEBROOT
rmdir -v $WEBROOT/_site
" \
| ssh $DEPLOY_TO /bin/bash
echo removing local upload file
rm -f $TMP_FILE
