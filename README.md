# Readme
This is example project of how to use opencv with flutter::ffi utilities
#Preparation
### Install the latest cmake (minimum version is 3.21.1)
```bash
brew install cmake
brew unlink cmake && brew link cmake
```
### Add additional global params to you rc file
```bash
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk-bundle
export ANDROID_NDK=$ANDROID_NDK_HOME
export NDK=$ANDROID_HOME/ndk/23.0.7599858
```
Here 23.0.7599858 could be any version > 23.0.75..
### Don't forget to switch you console to the new source!!

## Prebuild opencv for both platforms
This will take some big amount of time cause we need to build opencv for ios and android for ALL architectures
```bash
cd src
sh prebuild.sh
```
### For ios also need to call build.sh from the ios folder
This script will prepare ios `framework` file that will contain all c++ code. It also should be applied each time you change c++ code and need to check it or iphone
```bash
cd src/ios
sh build.sh
```
