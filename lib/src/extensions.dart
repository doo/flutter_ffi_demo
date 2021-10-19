import 'dart:ffi';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'ffi/ffi_lookup.dart';
import 'models/image.dart';

extension Allocation on Iterable<int> {
  Pointer<Int32> toNativeArray() {
    final ptr = malloc.allocate<Int32>(length * 4);
    final list = ptr.asTypedList(length);
    var i = 0;
    forEach((element) {
      list[i] = element;
      i++;
    });
    return ptr;
  }
}

extension BoolExtentions on bool {
  int toInt() => this ? 1 : 0;
}

extension CameraImageExtention on CameraImage {
  bool isEmpty() => planes.any((element) => element.bytes.isEmpty);

  Pointer<SdkImage> toSdkImagePointer(int rotation) {
    var pointer = createImageFrame();
    final image = pointer
        .ref;
    image.width = width;
    image.height = height;
    image.rotation = rotation;

    if (Platform.isIOS) {
      image.platform = 0;
      final plane = planes[0];
      final bytesPerRow = planes[0].bytesPerRow;
      final pLength = plane.bytes.length;
      final p = malloc.allocate<Uint8>(pLength);
      // Assign the planes data to the pointers of the image
      final pointerList0 = p.asTypedList(pLength);
      pointerList0.setRange(0, pLength, plane.bytes);
      final sdkPlanePointer = createImagePlane();
      final sdkPlane = sdkPlanePointer.ref;
      sdkPlane.bytesPerRow = bytesPerRow;
      sdkPlane.length = pLength;
      sdkPlane.planeData = p;
      sdkPlane.nextPlane = nullptr;
      image.plane = sdkPlanePointer;
    }

    if (Platform.isAndroid) {
      image.platform = 1;
      final plane0 = planes[0];
      final pLength0 = plane0.bytes.length;
      final plane1 = planes[1];
      final pLength1 = plane1.bytes.length;
      final plane2 = planes[2];
      final pLength2 = plane2.bytes.length;
      final bytesPerRow0 = planes[0].bytesPerRow;
      final bytesPerRow1 = planes[1].bytesPerRow;
      final bytesPerRow2 = planes[2].bytesPerRow;

      final p0 = malloc.allocate<Uint8>(pLength0);
      final p1 = malloc.allocate<Uint8>(pLength1);
      final p2 = malloc.allocate<Uint8>(pLength2);

      // Assign the planes data to the pointers of the image
      final pointerList0 = p0.asTypedList(pLength0);
      final pointerList1 = p1.asTypedList(pLength1);
      final pointerList2 = p2.asTypedList(pLength2);
      pointerList0.setRange(0, pLength0, plane0.bytes);
      pointerList1.setRange(0, pLength1, plane1.bytes);
      pointerList2.setRange(0, pLength2, plane2.bytes);

      //final allocate = malloc.allocate<SdkImagePlane>(0);
      final sdkPlanePointer0 = createImagePlane();
      final sdkPlanePointer1 = createImagePlane();
      final sdkPlanePointer2 = createImagePlane();
      final sdkPlane0 = sdkPlanePointer0.ref;
      final sdkPlane1 = sdkPlanePointer1.ref;
      final sdkPlane2 = sdkPlanePointer2.ref;

      sdkPlane2.bytesPerRow = bytesPerRow2;
      sdkPlane2.nextPlane = nullptr;
      sdkPlane2.length = pLength2;
      sdkPlane2.planeData = p2;
      sdkPlane1.nextPlane = sdkPlanePointer2;

      sdkPlane1.bytesPerRow = bytesPerRow1;
      sdkPlane1.length = pLength1;
      sdkPlane1.planeData = p1;
      sdkPlane0.nextPlane = sdkPlanePointer1;

      sdkPlane0.bytesPerRow = bytesPerRow0;
      sdkPlane0.length = pLength0;
      sdkPlane0.planeData = p0;
      image.plane = sdkPlanePointer0;

    }
    return pointer;
  }
}

extension SdkImagePoinerExtention on Pointer<SdkImage> {
  void release() {
    var plane = ref.plane;
    while (plane != nullptr) {
      if (plane.ref.planeData != nullptr) {
        malloc.free(plane.ref.planeData);
      }
      final tmpPlane = plane;
      plane = plane.ref.nextPlane;
      malloc.free(tmpPlane);
    }
    malloc.free(this);
  }
}
