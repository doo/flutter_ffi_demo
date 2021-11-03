#!/bin/bash

set -e

OPENCV_VERSION=${1:-4.4.0}

NDK_ROOT=${ANDROID_NDK:-${ANDROID_NDK_HOME}}
WD=`pwd`
INSTALLDIR="${WD}/opencv-$OPENCV_VERSION-android"

rm -rf "$INSTALLDIR"

if [ ! -d "opencv-$OPENCV_VERSION" ]; then
	curl -L https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz | tar xz
fi;
if [ ! -d "opencv_contrib-$OPENCV_VERSION" ]; then
	curl -L https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.tar.gz | tar xz
fi;

brew list ant >/dev/null || brew install ant 

for config in armeabi-v7a,16 arm64-v8a,21 x86,16 x86_64,21
do
    IFS=',' config=($config)
    ANDROID_ABI=${config[0]}
    API_LEVEL=${config[1]}

    echo "Start building ${ANDROID_ABI}, API level: ${API_LEVEL}"

    temp_build_dir="${WD}/cmake-build-opencv-${ANDROID_ABI}"
    rm -rf "${temp_build_dir}" && mkdir -p "${temp_build_dir}"

    OPENJPEG_INSTALLDIR="${WD}/openjpeg-install-${ANDROID_ABI}"
    INSTALLDIR="$OPENJPEG_INSTALLDIR" ANDROID_ABI="$ANDROID_ABI" API_LEVEL="$API_LEVEL" ./build-openjpeg.sh

    pushd "${temp_build_dir}"
    /usr/local/bin/cmake -D CMAKE_BUILD_WITH_INSTALL_RPATH=ON \
            -D CMAKE_TOOLCHAIN_FILE=${NDK_ROOT}/build/cmake/android.toolchain.cmake \
            -D ANDROID_NDK="${NDK_ROOT}" \
            -D ANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
            -D ANDROID_ABI="${ANDROID_ABI}" \
            -D ANDROID_STL="c++_shared" \
            -D WITH_OPENCL=YES \
            -D WITH_CUDA=NO \
            -D WITH_MATLAB=NO \
            -D WITH_OPENEXR=NO \
            -D WITH_JASPER=NO \
            -D WITH_IMGCODEC_HDR=NO \
            -D WITH_IMGCODEC_SUNRASTER=NO \
            -D WITH_IMGCODEC_PXM=NO \
            -D WITH_IMGCODEC_PFM=NO \
            -D WITH_WEBP=NO \
            -D WITH_IPP=NO \
            -D BUILD_JAVA=NO \
            -D OPENCV_ENABLE_NONFREE=NO \
            -D BUILD_ANDROID_EXAMPLES=NO \
            -D BUILD_ANDROID_PROJECTS=NO \
            -D BUILD_DOCS=NO \
            -D BUILD_PERF_TESTS=NO \
            -D BUILD_TESTS=NO \
            -D BUILD_ZLIB=YES \
            -D OPENCV_EXTRA_MODULES_PATH="${WD}/opencv_contrib-$OPENCV_VERSION/modules/"  \
            -D OpenJPEG_DIR="$(dirname $(find "$OPENJPEG_INSTALLDIR" -name OpenJPEGConfig.cmake))" \
            -D CMAKE_INSTALL_PREFIX="${INSTALLDIR}" \
            "${WD}/opencv-$OPENCV_VERSION"


    make -j20
    make install
    cp "$OPENJPEG_INSTALLDIR/lib/libopenjp2.a" "$INSTALLDIR/sdk/native/3rdparty/libs/$ANDROID_ABI/"

    popd
done
