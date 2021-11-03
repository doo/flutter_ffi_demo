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
    if (roi != null) {
      result = await frameProcessor.processFrameInRoi(image, rotation, roi);
    } else {
      result = await frameProcessor.processFrame(image, rotation);
    }
    detectionResultStreamController.add(result);
  }
}
