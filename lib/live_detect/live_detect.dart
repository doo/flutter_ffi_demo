import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../camera_preview.dart';

class ScanbotLiveDetection<T> extends StatefulWidget {
  final FrameHandler<T> handler;
  final AspectRatioFinderConfig? aspectRatioFinderConfig;
  final Widget? overlay;

  const ScanbotLiveDetection(
      {Key? key,
      required this.handler,
      this.aspectRatioFinderConfig,
      this.overlay})
      : super(key: key);

  @override
  _ScanbotLiveDetectionState createState() =>
      _ScanbotLiveDetectionState(handler, aspectRatioFinderConfig, overlay);
}

class _ScanbotLiveDetectionState<T> extends State<ScanbotLiveDetection> {
  final FrameHandler<T> handler;
  bool permissionGranted = false;
  CameraController? controller;
  AspectRatioFinderConfig? aspectRatioFinderConfig;
  final Widget? overlay;

  _ScanbotLiveDetectionState(
      this.handler, this.aspectRatioFinderConfig, this.overlay);

  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  void checkPermission() async {
    final permissionResult = await [Permission.camera].request();
    setState(() {
      permissionGranted =
          permissionResult[Permission.camera]?.isGranted ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget cameraPlaceholder;
    if (permissionGranted) {
      cameraPlaceholder = FutureBuilder(
        future: availableCameras(),
        builder: (BuildContext context,
            AsyncSnapshot<List<CameraDescription>> snapshot) {
          final data = snapshot.data;
          if (data != null) {
            final cameraData = data[0];
            if (cameraData != null) {
              var resolutionPreset = ResolutionPreset.max;
              if (Platform.isIOS) {
                resolutionPreset = ResolutionPreset.medium;
              }
              controller ??= CameraController(cameraData, resolutionPreset,
                  imageFormatGroup: ImageFormatGroup.yuv420);

              return ScanbotCameraWidget(
                const Key('Camera'),
                controller!,
                finderConfig: aspectRatioFinderConfig,
                detectHandler: handler,
                overlay: overlay,
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        },
      );
    } else {
      cameraPlaceholder = Container();
    }

    return cameraPlaceholder;
  }
}

abstract class ResultOverlay<T> extends StatefulWidget {
  abstract final Stream<T> _stream;

  const ResultOverlay({Key? key}) : super(key: key);
}
