#!/bin/bash

set -e

mkdir -p x86 x86_64 armeabi-v7a arm64-v8a

LOCAL_DIR=.boringssl
NDK=${ANDROID_NDK:-${ANDROID_NDK_HOME}}

if [ -d boringssl ]; then
    if [ ! -d $LOCAL_DIR ]; then
        mv boringssl $LOCAL_DIR
    else
        echo "Warning: detected both folders 'boringssl' and '$LOCAL_DIR'. Only '$LOCAL_DIR' will be used for the build. You should rm -rf boringssl"
    fi
fi

for tool in go ninja; do
    brew list $tool || brew install $tool
done

if [ ! -d $LOCAL_DIR ]; then
    git clone https://github.com/google/boringssl.git $LOCAL_DIR --depth=1
fi

cd $LOCAL_DIR
git pull

rm -rf ../include/*
cp -R include ../

mkdir -p build
cd build

rm -rf *
cmake -DANDROID_ABI=x86 \
      -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake \
      -DANDROID_NATIVE_API_LEVEL=9 \
      -DCMAKE_BUILD_TYPE=Release \
      -DOPENSSL_SMALL=1 \
      -GNinja ..
ninja
cp ssl/libssl.a crypto/libcrypto.a ../../x86

rm -rf *
cmake -DANDROID_ABI=x86_64 \
      -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake \
      -DANDROID_NATIVE_API_LEVEL=21 \
      -DCMAKE_BUILD_TYPE=Release \
      -DOPENSSL_SMALL=1 \
      -GNinja ..
ninja
cp ssl/libssl.a crypto/libcrypto.a ../../x86_64

rm -rf *
cmake -DANDROID_ABI="armeabi-v7a with NEON" \
      -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake \
      -DANDROID_NATIVE_API_LEVEL=16 \
      -DCMAKE_BUILD_TYPE=Release \
      -DOPENSSL_SMALL=1 \
      -GNinja ..
ninja
cp ssl/libssl.a crypto/libcrypto.a ../../armeabi-v7a

rm -rf *
cmake -DANDROID_ABI=arm64-v8a \
      -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake \
      -DANDROID_NATIVE_API_LEVEL=21 \
      -DCMAKE_BUILD_TYPE=Release \
      -DOPENSSL_SMALL=1 \
      -GNinja ..
ninja
cp ssl/libssl.a crypto/libcrypto.a ../../arm64-v8a
