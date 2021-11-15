import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_ffi_demo/shape_detector/shape_detector.dart';

import '../camera_preview.dart';


class OpenCvFramesHandler extends FrameHandler<ProcessingResult> {
  OpenCvShapeDetector frameProcessor;

  @override
  StreamController<ProcessingResult> detectionResultStreamController;

  OpenCvFramesHandler(
      this.frameProcessor, this.detectionResultStreamController);

  @override
  Future<void> detect(CameraImage image, Rect? roi, int rotation) async {
    final ProcessingResult result;
    print("frame aspect ratio ${image.width/image.height}");
    result = await frameProcessor.processFrame(image, rotation, roi);
    detectionResultStreamController.add(result);
  }
}
