//
// Created by Serhii Chaban on 13.10.21.
//

#ifndef FLUTTER_FFI_DEMO_PLUGIN_OPENCVFFI_H
#define FLUTTER_FFI_DEMO_PLUGIN_OPENCVFFI_H
namespace flutter {

struct FaceRect {
    int left;
    int top;
    int right;
    int bottom;
    FaceRect *next = nullptr;
};

}
#endif //FLUTTER_FFI_DEMO_PLUGIN_OPENCVFFI_H
