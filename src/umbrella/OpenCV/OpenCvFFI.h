//
// Created by Serhii Chaban on 13.10.21.
//

#ifndef FLUTTER_FFI_DEMO_PLUGIN_OPENCVFFI_H
#define FLUTTER_FFI_DEMO_PLUGIN_OPENCVFFI_H
namespace flutter {

    struct Point {
        float x;
        float y;
        Point *next = nullptr;
    };
    struct Shape {
        int figureType;
        Point *point = nullptr;
        Shape *next = nullptr;
    };
}
#endif //FLUTTER_FFI_DEMO_PLUGIN_OPENCVFFI_H
