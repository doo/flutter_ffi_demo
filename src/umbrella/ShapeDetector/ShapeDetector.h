//
// Created by Serhii Chaban on 29.10.21.
//

#ifndef ANDROID_SHAPEDETECTOR_H
#define ANDROID_SHAPEDETECTOR_H

#include "opencv2/core.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"

class ShapeDetector {


public:
    struct Point {
        float x;
        float y;

        Point(float x, float y) {
            this->x = x;
            this->y = y;
        }
    };

    struct Shape {
        int figureType;
        std::vector<Point> points;

        Shape(int figureType, std::vector<Point> points) {
            this->figureType = figureType;
            this->points = points;
        }
    };

    ShapeDetector();

    std::vector<ShapeDetector::Shape> detectShapes(const cv::Mat &frame);

private:
    static void detectCircles(const cv::Mat &src, std::vector<Shape> *shapes);

   // void detectRectangles(const cv::Mat &src,const std::vector<ShapeDetector::Shape> &dst);

   // void detectPolyShape(const cv::Mat &src,const std::vector<ShapeDetector::Shape> &dst);
};

#endif //ANDROID_SHAPEDETECTOR_H
