import 'dart:async';
import 'dart:core';
import 'dart:ffi' as ffi;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ffi_demo/src/ffi/ffi_lookup.dart';

import '../camera_preview.dart';
import '../src/extensions.dart';
import '../src/models/image.dart';

final _processFrame = sdkNative
    .lookupFunction<_ProcessFrameNative, _ProcessFrame>('processFrame');

typedef _ProcessFrameNative = ffi.Pointer<_FrameProcessingResult> Function(
    ffi.Pointer<SdkImage>);
typedef _ProcessFrame = ffi.Pointer<_FrameProcessingResult> Function(
    ffi.Pointer<SdkImage>);

final _init = sdkNative
    .lookupFunction<_InitDetectorNative, _InitDetector>('initDetector');

typedef _InitDetectorNative = ffi.Pointer<ffi.Void> Function(ffi.Pointer<Utf8>);
typedef _InitDetector = ffi.Pointer<ffi.Void> Function(ffi.Pointer<Utf8>);

final _deinit = sdkNative
    .lookupFunction<_InitDetectorNative, _InitDetector>('initDetector');

typedef _DeinitDetectorNative = ffi.Void Function(ffi.Pointer<Utf8>);
typedef _DeinitDetector = ffi.Void Function(ffi.Pointer<Utf8>);

/// this is private class that maps into ffi native struct result object
class _FrameProcessingResult extends ffi.Struct {
  ///Scanned barcode format
  @ffi.Int32()
  external int format;

  ///Result data from barcode
  external ffi.Pointer<Utf8> text;

  external ffi.Pointer<ffi.Uint8> rawBytes;
  @ffi.Int32()
  external int rawBytesLength;

  external ffi.Pointer<_FrameProcessingResult> next;
}

class ProcessingResult {}

class OpenCvFaceDetector {
  String faceDetectionConfiguration = "files/deploy.prototxt";
  String faceDetectionWeights =
      "files/res10_300x300_ssd_iter_140000_fp16.caffemodel";

  OpenCvFaceDetector();

  Future<ProcessingResult> processFrame(CameraImage image, int rotation) async {
    if (!image.isEmpty()) {
      //some checks to ignore problems with flutter camera plugin
      return compute(
          processFrameAsync,
          _FrameData(
            image,
            rotation,
          ));
    } else {
      return ProcessingResult();
    }
  }
}

class _FrameData {
  CameraImage image;
  int rotation;

  _FrameData(this.image, this.rotation);
}

Future<ProcessingResult> processFrameAsync(_FrameData detect) async {
  try {
    final stopwatch = Stopwatch()..start();
    ffi.Pointer<SdkImage> image =
        detect.image.toSdkImagePointer(detect.rotation);
    final result = _processFrame(image);
    print('recognise() detect in ${stopwatch.elapsedMilliseconds}');
    stopwatch.stop();
    //final resultItem = _mapResult(result);
    image.release();
    return ProcessingResult();
  } catch (e) {
    print(e);
  }

  return ProcessingResult();
}

/*
List<BarcodeItem> _mapResult(ffi.Pointer<_FrameProcessingResult> result) {
  final barcodeItems = <BarcodeItem>[];
  var currentItem = result;
  while (currentItem != ffi.nullptr) {
    try {
      final item = currentItem.ref;
      final barcodeFormat = item.format.toBarcodeFormat();
      final text = item.text.toDartString();
      Uint8List? rawBytes = null;
      rawBytes = item.rawBytes.asTypedList(item.rawBytesLength);

      malloc
          .free(item.text); // need to deallocate all strings and other pointers
      malloc.free(
          item.rawBytes); // need to deallocate all strings and other pointers
      barcodeItems.add(BarcodeItem(barcodeFormat, text, rawBytes));
      final tempItem = currentItem;
      currentItem = item.next;
      malloc.free(tempItem); // need to deallocate pointer to the object
    } catch (e) {
      print(e);
    }
  }
  return barcodeItems;
}
*/

class OpenCvFramesHandler extends FrameHandler<ProcessingResult> {
  OpenCvFaceDetector imageProcessor;

  @override
  StreamController<ProcessingResult> detectionResultStreamController;

  OpenCvFramesHandler(
      this.imageProcessor, this.detectionResultStreamController);

  @override
  Future<void> detect(CameraImage image, Rect? roi, int rotation) async {
    final ProcessingResult result;
    if (roi != null) {
      // here we will ignore roi for this demo
      result = ProcessingResult();
    } else {
      result = await imageProcessor.processFrame(image, rotation);
    }
    detectionResultStreamController.add(result);
  }
}
