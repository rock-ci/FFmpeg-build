#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

source "${SCRIPT_DIR}/lib/versions.sh"

echo "***********************"
echo "** Building packages **"
echo "***********************"

cd "ffmpeg-${UPSTREAM_VER}"
dpkg-buildpackage -b -us -uc --jobs=auto

echo "****************"
echo "** Build done **"
echo "****************"
