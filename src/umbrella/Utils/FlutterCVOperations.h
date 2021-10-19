#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/imgproc/types_c.h"

#ifndef ANDROID_CVOPERATIONS_HPP
#define ANDROID_CVOPERATIONS_HPP

using namespace cv;

namespace flutter {

    /**
     * Same as above but does resizing inplace, to save memory.
     */
    static void resizeImage(cv::Mat const &img, cv::Mat &out, int dstSize) {
        Size size = img.size();
        int dstheight = dstSize;
        int dstwidth = dstSize;
        size.height > size.width
        ? dstwidth = (int) (dstSize * ((double) size.width / (double) size.height))
        : dstheight = (int) (dstSize * ((double) size.height / (double) size.width));

        Size dstsize(dstwidth, dstheight);//the dst image size,e.g.100x100

        resize(img, out, dstsize);
    }

    /**
     * Rotates matrix counter clockwise
     */
    static Mat rotateMatrixCCW(Mat const &img, unsigned int times) {
        Mat dst;
        times = times % 4;
        switch (times) {
            case 0:
                return img;
                break;
            case 1:
                cv::transpose(img, dst);
                cv::flip(dst, dst, 0);
                break;
            case 2:
                cv::flip(img, dst, 1);
                cv::flip(dst, dst, 0);
                break;
            case 3:
                cv::transpose(img, dst);
                cv::flip(dst, dst, 1);
            default:
                break;
        }
        return dst;
    }

}


#endif //ANDROID_CVOPERATIONS_HPP
