#ifndef SCANBOTSDKANDROID_MATUTILS_H
#define SCANBOTSDKANDROID_MATUTILS_H

#include "FlutterCVOperations.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <iostream>
#include "opencv2/opencv.hpp"

namespace flutter {

    struct Plane {
        uint8_t *planeData;
        int length;
        int bytesPerRow;
        Plane *nextPlane = nullptr;
    };

    struct ImageForDetect {
        Plane *plane;
        int platform; // 0 ios, 1 android*
        int width;
        int height;
        int orientation;
    };

    static void fixMatOrientation(int orientation, cv::Mat &img) {
        if (orientation != 0) {
            switch (orientation) {
                case 90:
                    img = rotateMatrixCCW(img, 3);
                    break;
                case 180:
                    img = rotateMatrixCCW(img, 2);
                    break;
                case 270:
                    img = rotateMatrixCCW(img, 1);
                    break;
                default:
                    break;
            }
        }
    }

    cv::Mat prepareJpegMat(unsigned char *bytes, int length, int orientation, int maxImageSize);

    static cv::Mat prepareMatAndroid(
            uint8_t *plane0,
            int bytesPerRow0,
            uint8_t *plane1,
            int lenght1,
            int bytesPerRow1,
            uint8_t *plane2,
            int lenght2,
            int bytesPerRow2,
            int width,
            int height,
            int orientation) {
        uint8_t *yPixel = plane0;
        uint8_t *uPixel = plane1;
        uint8_t *vPixel = plane2;

        int32_t uLen = lenght1;
        int32_t vLen = lenght2;

        cv::Mat _yuv_rgb_img;
        assert(bytesPerRow0 == bytesPerRow1 && bytesPerRow1 == bytesPerRow2);
        uint8_t *uv = new uint8_t[uLen + vLen];
        memcpy(uv, uPixel, vLen);
        memcpy(uv + uLen, vPixel, vLen);
        cv::Mat mYUV = cv::Mat(height, width, CV_8UC1, yPixel, bytesPerRow0);
        cv::copyMakeBorder(mYUV, mYUV, 0, height >> 1, 0, 0, BORDER_CONSTANT, 0);

        cv::Mat mUV = cv::Mat((height >> 1), width, CV_8UC1, uv, bytesPerRow0);
        cv:Mat dst_roi = mYUV(Rect(0, height, width, height >> 1));
        mUV.copyTo(dst_roi);
        //cv::imwrite("/data/data/scanbot.sdk.flutter_ffi_demo/files/debug_yuv_concat.jpeg", mYUV);

        cv::cvtColor(mYUV, _yuv_rgb_img, COLOR_YUV2RGBA_NV21, 3);
        //cv::imwrite("/data/data/scanbot.sdk.flutter_ffi_demo/files/debug_yuv_result.jpeg",
         //           _yuv_rgb_img);

        fixMatOrientation(orientation, _yuv_rgb_img);

        return _yuv_rgb_img;
    }

    static cv::Mat prepareMatIos(uint8_t *plane,
                                 int bytesPerRow,
                                 int width,
                                 int height,
                                 int orientation) {
        uint8_t *yPixel = plane;

        cv::Mat mYUV = cv::Mat(height, width, CV_8UC4, yPixel, bytesPerRow);

        fixMatOrientation(orientation, mYUV);

        return mYUV;

    }

    static cv::Mat prepareMat(flutter::ImageForDetect *image) {
        if (image->platform == 0) {
            auto *plane = image->plane;
            return flutter::prepareMatIos(plane->planeData,
                                          plane->bytesPerRow,
                                          image->width,
                                          image->height,
                                          image->orientation);
        }
        if (image->platform == 1) {
            auto *plane0 = image->plane;
            auto *plane1 = plane0->nextPlane;
            auto *plane2 = plane1->nextPlane;
            return flutter::prepareMatAndroid(plane0->planeData,
                                              plane0->bytesPerRow,
                                              plane1->planeData,
                                              plane1->length,
                                              plane1->bytesPerRow,
                                              plane2->planeData,
                                              plane2->length,
                                              plane2->bytesPerRow,
                                              image->width,
                                              image->height,
                                              image->orientation);
        }
        throw "Can't parse image data due to the unknown platform";
    }

}

#ifdef __cplusplus
extern "C" {
#endif

flutter::Plane *MathUtils_createPlane() {
    return (struct flutter::Plane *) malloc(sizeof(struct flutter::Plane));
}

flutter::ImageForDetect *MathUtils_createImageFrame() {
    return (struct flutter::ImageForDetect *) malloc(sizeof(struct flutter::ImageForDetect));
}

#ifdef __cplusplus
}
#endif

#endif //SCANBOTSDKANDROID_MATUTILS_H
