#!/bin/bash

set -e

WD=`pwd`
INSTALLDIR="build"

rm -rf "$INSTALLDIR"
mkdir "$INSTALLDIR"

pushd $INSTALLDIR
cmake ../ \
-DCMAKE_TOOLCHAIN_FILE=$WD/opencv-build/opencv-4.5.0/platforms/ios/cmake/Toolchains/Toolchain-iPhoneOS_Xcode.cmake \
  -DIOS_ARCH=arm64 \
  -DIPHONEOS_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_OSX_SYSROOT=iphoneos \
  -DCMAKE_CONFIGURATION_TYPES:=Debug \
  -GXcode

xcodebuild -project flutter_ffi.xcodeproj -target flutter_ffi

echo "***********  Moving and cleaning after build"
rm -rf $WD/../../ios/flutter_ffi.framework
mv $WD/build/Debug-iphoneos/flutter_ffi.framework $WD/../../ios/flutter_ffi.framework
echo "***********  COMPLETED"
popd
