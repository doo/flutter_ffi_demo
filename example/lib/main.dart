import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ffi_demo/image_processor/processor.dart';

import 'live_processing.dart';

void main() {
  runApp(
      MaterialApp(
        home: OpenCvCameraDemo(
          frameProcessor: OpenCvFrameProcessor(),
          detectionResultStreamController: StreamController<ProcessingResult>(),
        )
      )
   );
}
