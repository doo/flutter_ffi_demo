import 'dart:ffi' as ffi;
import 'dart:io';

import '../models/image.dart';

final sdkNative = Platform.isAndroid
    ? ffi.DynamicLibrary.open('libflutter_ffi.so')
    : ffi.DynamicLibrary.process();

final createImageFrame =
    sdkNative.lookupFunction<_CreateImageFrameNative, _CreateImageFrame>(
        'MathUtils_createImageFrame');

final createImagePlane =
    sdkNative.lookupFunction<_CreateImagePlaneNative, _CreateImagePlane>(
        'MathUtils_createPlane');

typedef _CreateImageFrameNative = ffi.Pointer<SdkImage> Function();
typedef _CreateImageFrame = ffi.Pointer<SdkImage> Function();

typedef _CreateImagePlaneNative = ffi.Pointer<SdkImagePlane> Function();
typedef _CreateImagePlane = ffi.Pointer<SdkImagePlane> Function();
