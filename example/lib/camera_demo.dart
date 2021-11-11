import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ffi_demo/live_detect/live_detect.dart';
import 'package:flutter_ffi_demo/shape_detector/opencv_shape_datector_frame_handler.dart';
import 'package:flutter_ffi_demo/shape_detector/shape_detector.dart';

class OpenCvCameraDemo extends StatefulWidget {
  OpenCvShapeDetector faceDetector;
  StreamController<ProcessingResult> detectionResultStreamController;
  bool autoCloseStream;

  OpenCvCameraDemo(
      {Key? key,
      required this.faceDetector,
      required this.detectionResultStreamController,
      this.autoCloseStream = true})
      : super(key: key);

  @override
  _OpenCvCameraDemoState createState() => _OpenCvCameraDemoState(
      faceDetector, detectionResultStreamController, autoCloseStream);
}

class _OpenCvCameraDemoState extends State<OpenCvCameraDemo> {
  OpenCvShapeDetector faceDetector;
  StreamController<ProcessingResult> detectionResultStreamController;
  bool autoCloseStream = true;
  bool scannerIsInited = false;

  _OpenCvCameraDemoState(this.faceDetector,
      this.detectionResultStreamController, this.autoCloseStream);

  @override
  void initState() {
    faceDetector.init().then((value) {
      setState(() {
        scannerIsInited = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var resultOverlay =
        ShapesResultOverlay(detectionResultStreamController.stream);
    Widget body = Container();
    if (scannerIsInited) {
      body = Stack(
        children: [
          FrameLiveProcessing<ProcessingResult>(
            overlay: resultOverlay,
            handler: OpenCvFramesHandler(
              faceDetector,
              detectionResultStreamController,
            ),
            aspectRatioFinderConfig: null,
            //  AspectRatioFinderConfig(width: 1, height: 1, debug: true),
          ),
        ],
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("OpenCv Demo"),
        ),
        body: body);
  }

  @override
  void dispose() {
    if (autoCloseStream) {
      detectionResultStreamController.close();
    }
    super.dispose();
  }
}

class ShapesResultOverlay extends ResultOverlay {
  @override
  final Stream<ProcessingResult> _stream;

  ShapesResultOverlay(this._stream);

  @override
  _ResultOverlayState createState() => _ResultOverlayState(_stream);
}

class _ResultOverlayState extends State<ResultOverlay> {
  final Stream<ProcessingResult> _stream;

  _ResultOverlayState(this._stream);

  ValueNotifier<List<Shape>>? notifier;

  @override
  void initState() {
    notifier = ValueNotifier([]);
    startListenStream(_stream);
    super.initState();
  }

  void startListenStream(Stream<ProcessingResult> stream) async {
    await for (final result in stream) {
      notifier!.value = result.shapes;
    }
  }

  @override
  Widget build(BuildContext context) {
    var shapesPainter = ShapesPainter(notifier!);
    final size = MediaQuery.of(context).size;
    return Container(
      child: CustomPaint(
        size: size,
        painter: shapesPainter,
      ),
    );
  }
}

class ShapesPainter extends CustomPainter {
  ValueNotifier<List<Shape>> notifier;
  Paint circlePaint = Paint()
    ..strokeWidth = 3
    ..color = Colors.lightBlue.withAlpha(155);

  ShapesPainter(this.notifier) : super(repaint: notifier);

  @override
  void paint(Canvas canvas, Size size) {
   // canvas.drawPaint(Paint()..color = Colors.green.withAlpha(50));
    var _shapes = notifier.value;
    for (var element in _shapes) {
      switch (element.figureType) {
        case -1:
          var pointCenterN = element.points[0];
          var pointOuterN = element.points[1];
          var pointCenter = Point<double>(
              pointCenterN.x * size.width, pointCenterN.y * size.height);
          var pointOuter = Point<double>(
              pointOuterN.x * size.width, pointOuterN.y * size.height);

          canvas.drawCircle(Offset(pointCenter.x, pointCenter.y),
              pointCenter.distanceTo(pointOuter), circlePaint);
          break;
        default:
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
