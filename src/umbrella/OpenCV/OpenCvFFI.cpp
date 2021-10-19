//#include "../Utils/MatUtils.h"
#include <Utils/MatUtils.h>
#include "OpenCvFFI.h"
#include "opencv2/face.hpp"
#include "FaceDetector/FaceDetector.h"

#define EXPORTED __attribute__((visibility("default"))) __attribute__((used))

static flutter::FaceRect *mapFaceRectFFiResultStruct(const std::vector<cv::Rect> &faceRectandles);

#ifdef __cplusplus

static flutter::FaceRect *mapFaceRectFFiResultStruct(const std::vector<cv::Rect> &faceRectandles) {
    flutter::FaceRect *first = nullptr;
    flutter::FaceRect *previous = nullptr;
    int size = faceRectandles.size();
    for (int i = size - 1; i >= 0; --i) {
        auto face = faceRectandles[i];
        auto *ffiAllocated = (struct flutter::FaceRect *) malloc(
                sizeof(struct flutter::FaceRect));
        ffiAllocated->left = face.x;
        ffiAllocated->top = face.y;
        ffiAllocated->right = face.x + face.width;
        ffiAllocated->bottom = face.y + face.height;
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

flutter::FaceRect *processFrame(void *scanner, cv::Mat *image) {
    auto faceRectandles = ((FaceDetector *) scanner)->detect_face_rectangles(*image);
    //todo we need to map result as a linked list of items to return multiple result
    flutter::FaceRect *first = mapFaceRectFFiResultStruct(faceRectandles);
    return first;
}
void *initDetector(const char *faceDetectionConfiguration,
                   const char *faceDetectionWeights) {
    auto *scanner = new FaceDetector(faceDetectionConfiguration, faceDetectionWeights);
    return scanner;
}

void deinitDetector(void *scanner) {
    delete (FaceDetector *) scanner;
}

#ifdef __cplusplus
}
#endif
