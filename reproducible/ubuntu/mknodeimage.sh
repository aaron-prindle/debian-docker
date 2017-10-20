#!/bin/bash
set -ex

usage() {
  echo "Usage: $0 [VERSION]"
  echo
  echo "[VERSION]: The node version to use."
  echo
  exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

VERSION=$1

ln -s /usr/bin/python2.7 /usr/bin/python

WORKDIR="/workspace/nodejs_build"
OUTPUTDIR="$WORKDIR/nodejs"
mkdir -p "$OUTPUTDIR"
cd "$WORKDIR"

tar -xvf "/node-v$VERSION.tar.gz"
cd "node-v$VERSION"
./configure --prefix="$OUTPUTDIR"
make -j4
make install

# pass -n to gzip to strip timestamps
# strip the '.' with --transform thatp tar includes at the root to build nodejs
GZIP="-n" tar --numeric-owner -czf /workspace/nodejs.tar.gz -C "$OUTPUTDIR" . --transform='s,^./,,' --mtime='1970-01-01'
