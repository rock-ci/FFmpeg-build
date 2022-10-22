#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

source "${SCRIPT_DIR}/lib/versions.sh"

echo ""
echo "Upstream version: $UPSTREAM_VER"
echo "Debian revision:  $DEBIAN_REV"
echo "Our revision      $OUR_REV"
echo "Debian arch:      $DEB_ARCH"
echo ""


echo "***********************"
echo "** Retrieving source **"
echo "***********************"

apt-get -y source "ffmpeg=${BASE_VERSION}"

cd "ffmpeg-${UPSTREAM_VER}"

echo "************************"
echo "** Patching changelog **"
echo "************************"

cat << EOF | tee debian/changelog.new
ffmpeg (10:${UPSTREAM_VER}-${OUR_REV}) unstable; urgency=medium

  * Add v4l2-request hardware acceleration based on LibreELEC

 -- Hugh Cole-Baker <sigmaris@gmail.com>  $(date '+%a, %d %b %Y %H:%M:%S %z')

EOF
cat debian/changelog >> debian/changelog.new
mv debian/changelog.new debian/changelog

echo "***************************"
echo "** Applying ffmpeg patches **"
echo "***************************"

for patchfile in "${SCRIPT_DIR}"/patches/*.patch
do
    echo "* Applying $patchfile ..."
    patch -p1 < "$patchfile"
done

echo "******************"
echo "** Prepare done **"
echo "******************"
