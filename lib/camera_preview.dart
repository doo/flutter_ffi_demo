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

  final FrameHandler? detectHandler;
  final FinderConfig? finderConfig;
  final Widget? overlay;

  ScanbotCameraWidget(Key key, this.controller,
      {this.detectHandler, this.finderConfig, this.overlay})
      : super(key: key);

  @override
  _ScanbotCameraWidgetState createState() => _ScanbotCameraWidgetState(
        controller,
        detectHandler,
        finderConfig,
        overlay,
      );
}

class _ScanbotCameraWidgetState extends State<ScanbotCameraWidget> {
  CameraController controller;
  FrameHandler? detectHandler;
  FinderConfig? finder;
  final Widget? overlay;

  _ScanbotCameraWidgetState(
      this.controller, this.detectHandler, this.finder, this.overlay);

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
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  void callFrameDetection(CameraImage image, FinderConfig? finder) async {
    try {
      _isDetecting = true;
      Rect? roi;
      const rotation =
          90; // here is degrees of how frame that comes from the camera is differs from device rotation clockwise
      // need to be calculated properly, but it doesnt come from camera plugin
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

  Rect calculateRoiFromAspectRatio(
      CameraImage image, AspectRatioFinderConfig finder, int rotation) {
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
  Widget build(BuildContext context) {
    if (!_initialised) {
      return Container();
    }
    final camera = controller.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;
    Widget debugOverlay = Container();
    final config = finder;
    if (config is AspectRatioFinderConfig && config.debug) {
      debugOverlay = getAspectRatioDebugOverlay(size, config);
    }

    var combinedOverlay = Center(
      child: Stack(
        children: [debugOverlay, overlay ?? Container()],
      ),
    );
    return Center(
        child: CameraPreview(
      controller,
      child: combinedOverlay,
    ));
  }

  Widget getAspectRatioDebugOverlay(
    Size size,
    AspectRatioFinderConfig config,
  ) {
    return Center(
      child: AspectRatio(
        aspectRatio: config.aspectRatio,
        child: Container(
          color: Colors.blue.withAlpha(50),
        ),
      ),
    );
  }
}
