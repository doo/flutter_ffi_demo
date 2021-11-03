import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ffi_demo/shape_detector/shape_detector.dart';

import 'camera_demo.dart';

void main() {
  runApp(
      MaterialApp(
        home: OpenCvCameraDemo(
          faceDetector: OpenCvShapeDetector(),
          detectionResultStreamController: StreamController<ProcessingResult>(),
        )
      )
   );
}
