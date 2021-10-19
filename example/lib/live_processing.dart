import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ffi_demo/image_processor/processor.dart';
import 'package:flutter_ffi_demo/live_detect/live_detect.dart';

class OpenCvCameraDemo extends StatefulWidget {
  OpenCvFrameProcessor frameProcessor;
  StreamController<ProcessingResult> detectionResultStreamController;
  bool autoCloseStream;

  OpenCvCameraDemo(
      {Key? key,
      required this.frameProcessor,
      required this.detectionResultStreamController,
      this.autoCloseStream = true})
      : super(key: key);

  @override
  _OpenCvCameraDemoState createState() => _OpenCvCameraDemoState(
      frameProcessor, detectionResultStreamController, autoCloseStream);
}

class _OpenCvCameraDemoState extends State<OpenCvCameraDemo> {
  OpenCvFrameProcessor frameProcessor;
  StreamController<ProcessingResult> detectionResultStreamController;
  bool autoCloseStream = true;

  _OpenCvCameraDemoState(this.frameProcessor,
      this.detectionResultStreamController, this.autoCloseStream);

  @override
  Widget build(BuildContext context) {
    var barcodeResultOverlay =
        BarcodeResultOverlay(detectionResultStreamController.stream);
    return Scaffold(
        appBar: AppBar(
          title: const Text("OpenCv Demo"),
        ),
        body: Stack(
          children: [
            Stack(
              children: [
                FrameLiveProcessing<ProcessingResult>(
                  handler: OpenCvFramesHandler(
                      frameProcessor, detectionResultStreamController),
                ),
                barcodeResultOverlay
              ],
            )
          ],
        ));
  }

  @override
  void dispose() {
    if (autoCloseStream) {
      detectionResultStreamController.close();
    }
    super.dispose();
  }
}

class BarcodeResultOverlay extends ResultOverlay {
  @override
  Stream<ProcessingResult> _stream;

  BarcodeResultOverlay(this._stream);

  @override
  _BarcodeResultOverlayState createState() =>
      _BarcodeResultOverlayState(_stream);
}

class _BarcodeResultOverlayState extends State<ResultOverlay> {
  final Stream<ProcessingResult> _stream;

  _BarcodeResultOverlayState(this._stream);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProcessingResult>(
        stream: _stream,
        builder:
            (BuildContext context, AsyncSnapshot<ProcessingResult> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return Container();
            default:
              return Container();
          }
        });
  }
}
