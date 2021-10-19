#!/bin/bash

set -e

VERSION=${1:-$(ls -d opencv-*/)}
VERSION=${VERSION%/}
VERSION=${VERSION##*-}
if [ -z $VERSION ]; then
    echo Version required
    exit 1
fi

brew list pigz 2>/dev/null || brew install pigz

BASENAME=opencv-$VERSION-android
TARBALL=${BASENAME}.tar.gz
echo Preparing $TARBALL
if [ ! -e "$TARBALL" ]; then
    tar cvf - "$BASENAME" | pigz -9 > "$TARBALL"
fi

aws s3 cp "$TARBALL" s3://scanbotsdk-deployment/opencv/
aws s3api put-object-acl --bucket scanbotsdk-deployment --key opencv/$TARBALL --acl public-read
