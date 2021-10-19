import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../camera_preview.dart';

class FrameLiveProcessing<T> extends StatefulWidget {
  final FrameHandler<T> handler;


  const FrameLiveProcessing({Key? key, required this.handler })
      : super(key: key);

  @override
  _FrameLiveProcessingState createState() =>
      _FrameLiveProcessingState(handler );
}

class _FrameLiveProcessingState<T> extends State<FrameLiveProcessing> {
  final FrameHandler<T> handler;
  bool permissionGranted = false;
  CameraController? controller;

  _FrameLiveProcessingState(this.handler);

  @override
  void initState() {
    if (Platform.isAndroid) {
      checkPermission();
    } else {
      setState(() {
        permissionGranted = true;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
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
              controller ??= CameraController(
                    cameraData, ResolutionPreset.ultraHigh,
                    imageFormatGroup: ImageFormatGroup.yuv420);

              return ScanbotCameraWidget(const Key('Camera'), controller!,
                 // finderConfig:
                 // AspectRatioFinderConfig(width: 8, height: 4, debug: true),
                  detectHandler: handler);
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


