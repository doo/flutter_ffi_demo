//#include "../Utils/MatUtils.h"
#include <Utils/MatUtils.h>
#include "OpenCvFFI.h"
#include "opencv2/face.hpp"
#include "ShapeDetector/ShapeDetector.h"

#define EXPORTED __attribute__((visibility("default"))) __attribute__((used))

static flutter::Shape *mapShapesFFiResultStruct(const std::vector<ShapeDetector::Shape> &shapes);

static flutter::Point *mapPointsFFiResultStruct(const std::vector<ShapeDetector::Point> &points);

#ifdef __cplusplus

static flutter::Shape *mapShapesFFiResultStruct(const std::vector<ShapeDetector::Shape> &shapes) {
    flutter::Shape *first = nullptr;
    flutter::Shape *previous = nullptr;
    int size = shapes.size();
    for (int i = size - 1; i >= 0; --i) {
        auto shape = shapes[i];
        auto *ffiAllocated = (struct flutter::Shape *) malloc(
                sizeof(struct flutter::Shape));

        ffiAllocated->figureType = shape.figureType;
        ffiAllocated->point = mapPointsFFiResultStruct(shape.points);
        ffiAllocated->next = previous;
        if (i == 0) {
            first = ffiAllocated;
        }
        previous = ffiAllocated;
    }
    return first;
}

static flutter::Point *mapPointsFFiResultStruct(const std::vector<ShapeDetector::Point> &points) {
    flutter::Point *first = nullptr;
    flutter::Point *previous = nullptr;
    int size = points.size();
    for (int i = size - 1; i >= 0; --i) {
        auto point = points[i];
        auto *ffiAllocated = (struct flutter::Point *) malloc(
                sizeof(struct flutter::Point));

        ffiAllocated->x = point.x;
        ffiAllocated->y = point.y;
        ffiAllocated->next = previous;
        if (i == 0) {
            first = ffiAllocated;
        }
        previous = ffiAllocated;
    }
    return first;
}

extern "C" {
#endif

flutter::Shape *processFrame(ShapeDetector *scanner, flutter::ImageForDetect *image) {
    auto img = flutter::prepareMat(image);
    auto shapes = scanner->detectShapes(img);
    //we need to map result as a linked list of items to return multiple result
    flutter::Shape *first = mapShapesFFiResultStruct(shapes);
    return first;
}

flutter::Shape *processFrameWithRoi(ShapeDetector *scanner, flutter::ImageForDetect *image, int areaLeft,
                    int areaTop, int areaRight, int areaBottom) {
    auto areaWidth = areaRight - areaLeft;
    auto areaHeight = areaBottom - areaTop;
    auto img = flutter::prepareMat(image);
    if (areaLeft >= 0 && areaTop >= 0 && areaWidth > 0 && areaHeight > 0) {
        cv::Rect mrzRoi(areaLeft, areaTop, areaWidth, areaHeight);
        img = img(mrzRoi);
    }
    auto shapes = scanner->detectShapes(img);
    //we need to map result as a linked list of items to return multiple result
    flutter::Shape *first = mapShapesFFiResultStruct(shapes);
    return first;
}

ShapeDetector *initDetector() {
    auto *scanner = new ShapeDetector();
    return scanner;
}

void deinitDetector(void *scanner) {
    delete (ShapeDetector *) scanner;
}

#ifdef __cplusplus
}
#endif
