import 'dart:async';
import 'dart:core';
import 'dart:ffi' as ffi;
import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ffi_demo/src/ffi/ffi_lookup.dart';

import '../src/extensions.dart';
import '../src/models/image.dart';

final _processFrame = sdkNative
    .lookupFunction<_ProcessFrameNative, _ProcessFrame>('processFrame');

typedef _ProcessFrameNative = ffi.Pointer<_ShapeNative> Function(
    ffi.Pointer<ffi.NativeType>, ffi.Pointer<SdkImage>);
typedef _ProcessFrame = ffi.Pointer<_ShapeNative> Function(
    ffi.Pointer<ffi.NativeType>, ffi.Pointer<SdkImage>);

final _processFrameWithRoi =
    sdkNative.lookupFunction<_ProcessFrameWithRoiNative, _ProcessFrameWithRoi>(
        'processFrameWithRoi');

typedef _ProcessFrameWithRoiNative = ffi.Pointer<_ShapeNative> Function(
  ffi.Pointer<ffi.NativeType>,
  ffi.Pointer<SdkImage>,
  ffi.Int32,
  ffi.Int32,
  ffi.Int32,
  ffi.Int32,
);
typedef _ProcessFrameWithRoi = ffi.Pointer<_ShapeNative> Function(
    ffi.Pointer<ffi.NativeType>, ffi.Pointer<SdkImage>, int, int, int, int);

final _init = sdkNative
    .lookupFunction<_InitDetectorNative, _InitDetector>('initDetector');

typedef _InitDetectorNative = ffi.Pointer<ffi.NativeType> Function();
typedef _InitDetector = ffi.Pointer<ffi.NativeType> Function();

final _deinit = sdkNative
    .lookupFunction<_DeinitDetectorNative, _DeinitDetector>('deinitDetector');

typedef _DeinitDetectorNative = ffi.Void Function(ffi.Pointer<ffi.NativeType>);
typedef _DeinitDetector = void Function(ffi.Pointer<ffi.NativeType>);

/// this is private class that maps into ffi native struct result object
class _PointNative extends ffi.Struct {
  @ffi.Float()
  external double x;
  @ffi.Float()
  external double y;
  external ffi.Pointer<_PointNative> next;
}

/// this is private class that maps into ffi native struct result object
class _ShapeNative extends ffi.Struct {
  @ffi.Int32()
  external int corners; // -1 for circle
  external ffi.Pointer<_PointNative> point;
  external ffi.Pointer<_ShapeNative> next;
}

class Shape {
  int figureType; // -1 for circle
  List<Point<double>> points;

  Shape(this.figureType, this.points);
}

class ProcessingResult {
  List<Shape> shapes;

  ProcessingResult(this.shapes);
}

class OpenCvShapeDetector {
  ffi.Pointer<ffi.NativeType> scanner = ffi.nullptr;

  OpenCvShapeDetector();

  Future<void> init() async {
    dispose(); //dispose if there was any native scanner inited
   scanner = _init();
    return;
  }

  dispose() {
    if (scanner != ffi.nullptr) {
      _deinit(scanner);
      scanner = ffi.nullptr;
    }
  }

  Future<ProcessingResult> processFrame(CameraImage image, int rotation) async {
    //some checks to ignore problems with flutter camera plugin
    if (!image.isEmpty() && scanner != ffi.nullptr) {
      return compute(
          processFrameAsync,
          _FrameData(
            scanner.address,
            image,
            rotation,
          ));
    } else {
      return ProcessingResult([]);
    }
  }

  Future<ProcessingResult> processFrameInRoi(
      CameraImage image, int rotation, Rect roi) async {
    //some checks to ignore problems with flutter camera plugin
    if (!image.isEmpty() && scanner != ffi.nullptr) {
      return compute(processFrameAsync,
          _FrameData(scanner.address, image, rotation, roi: roi));
    } else {
      return ProcessingResult([]);
    }
  }
}

/// We need to pass serializable data to isolate for processing frame in other thread to free UI thread from blocking
class _FrameData {
  CameraImage image;
  int rotation;
  int scanner;
  Rect? roi;

  _FrameData(this.scanner, this.image, this.rotation, {this.roi});
}

Future<ProcessingResult> processFrameAsync(_FrameData detect) async {
  try {
    final stopwatch = Stopwatch()..start();
    ffi.Pointer<SdkImage> image =
        detect.image.toSdkImagePointer(detect.rotation);
    final scanner = ffi.Pointer.fromAddress(detect.scanner);
    ffi.Pointer<_ShapeNative> result;
    var roi = detect.roi;
    if (roi != null) {
      result = _processFrameWithRoi(scanner, image, roi.left.toInt(),
          roi.top.toInt(), roi.right.toInt(), roi.bottom.toInt());
    } else {
      result = _processFrame(scanner, image);
    }
    print('recognise() detect in ${stopwatch.elapsedMilliseconds}');
    stopwatch.stop();
    final shapes = _mapNativeItems(result);
    image.release();
    print("shapes total found ${shapes.length}");
    return ProcessingResult(shapes);
  } catch (e) {
    print(e);
  }

  return ProcessingResult([]);
}

List<Shape> _mapNativeItems(ffi.Pointer<_ShapeNative> result) {
  final shapes = <Shape>[];
  var currentShapeNative = result;
  while (currentShapeNative != ffi.nullptr) {
    try {
      final item = currentShapeNative.ref;
      final points = <Point<double>>[];
      var currentPointNative = item.point;
      _mapNativePoints(currentPointNative, points);
      shapes.add(Shape(item.corners, points));
      final tempItem = currentShapeNative;
      currentShapeNative = item.next;
      malloc.free(tempItem); // need to deallocate pointer to the object
    } catch (e) {
      print(e);
    }
  }
  return shapes;
}

void _mapNativePoints(
    ffi.Pointer<_PointNative> currentPointNative, List<Point<double>> points) {
  while (currentPointNative != ffi.nullptr) {
    points.add(Point(currentPointNative.ref.x, currentPointNative.ref.y));
    final tempItem = currentPointNative;
    currentPointNative = currentPointNative.ref.next;
    malloc.free(tempItem); // need to deallocate pointer to the object
  }
}
