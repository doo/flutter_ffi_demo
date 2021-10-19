import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

abstract class FrameHandler<T> {
  abstract StreamController<T> detectionResultStreamController;

  Future<void> detect(CameraImage image, Rect? roi, int rotation);
}

class FinderConfig {
  bool debug;

  FinderConfig(this.debug);
}

class AspectRatioFinderConfig extends FinderConfig {
  double width;
  double height;

  double get aspectRatio {
    return height / width;
  }

  AspectRatioFinderConfig(
      {required this.width, required this.height, bool debug = false})
      : super(debug);
}

class FixedSizeFinderConfig extends FinderConfig {
  double width;
  double height;

  FixedSizeFinderConfig(
      {required this.width, required this.height, bool debug = false})
      : super(debug);
}

class ScanbotCameraWidget extends StatefulWidget {
  CameraController controller;

  FrameHandler? detectHandler;
  FinderConfig? finderConfig;

  ScanbotCameraWidget(Key key, this.controller,
      {this.detectHandler, this.finderConfig})
      : super(key: key);

  @override
  _ScanbotCameraWidgetState createState() =>
      _ScanbotCameraWidgetState(controller, detectHandler, finderConfig);
}

class _ScanbotCameraWidgetState extends State<ScanbotCameraWidget> {
  CameraController controller;
  FrameHandler? detectHandler;
  FinderConfig? finder;

  _ScanbotCameraWidgetState(this.controller, this.detectHandler, this.finder);

  bool _isDetecting = false;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    controller.initialize().then((_) {
      setState(() {
        _initialised = true;
      });
      if (!mounted) {
        return;
      }
      if (detectHandler != null) {
        controller.startImageStream((image) {
          if (!_isDetecting && this.mounted) {
            callFrameDetection(image, finder);
          }
        });
      }
    });
  }

  void callFrameDetection(CameraImage image, FinderConfig? finder) async {
    try {
      _isDetecting = true;
      Rect? roi;
      const rotation = 0;
      if (finder is AspectRatioFinderConfig) {
        roi = calculateRoiFromAspectRatio(image, finder, rotation);
      }
      if (finder is FixedSizeFinderConfig) {}
      await detectHandler?.detect(image, roi, rotation);
    } catch (e) {
      //todo
    } finally {
      _isDetecting = false;
    }
  }

  Rect calculateRoiFromAspectRatio(CameraImage image,
      AspectRatioFinderConfig finder, int rotation) {
    var width = image.width;
    var height = image.height;
    if (rotation == 90 || rotation == 270) {
      width = image.height;
      height = image.width;
    }
    var finderHeight = width * finder.aspectRatio;
    var finderWidth = width;
    var hCenter = height / 2;
    var top = max(hCenter - finderHeight / 2, 0).toDouble();
    var bottom = min(hCenter + finderHeight / 2, height).toDouble();
    var left = 0.0;
    var right = width.toDouble();
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialised) {
      return Container();
    }
    final camera = controller.value;
    // fetch screen size
    final size = MediaQuery
        .of(context)
        .size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;
    Widget overlay = Container();
    final config = finder;
    if (config is AspectRatioFinderConfig && config.debug) {
      overlay = getAspectRatioDebugOverlay(size, config);
    }
    return Stack(
      children: [
        Transform.scale(
          scale: scale,
          child: Center(
            child: CameraPreview(controller),
          ),
        ),
        overlay
      ],
    );
  }

  Widget getAspectRatioDebugOverlay(Size size,
      AspectRatioFinderConfig config,) {
    var height = size.width * config.aspectRatio;
    var width = size.width;
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          color: Colors.black.withAlpha(50),
        ),
      ),
    );
  }
}
