#!/bin/bash
set -euo pipefail

echo "***********************"
echo "** Building packages **"
echo "***********************"

dpkg-buildpackage -b -us -uc --jobs=auto

echo "****************"
echo "** Build done **"
echo "****************"
