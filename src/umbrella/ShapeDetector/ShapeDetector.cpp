//
// Created by Serhii Chaban on 29.10.21.
//

#include "ShapeDetector/ShapeDetector.h"

#include <utility>


ShapeDetector::ShapeDetector() {

}

std::vector<ShapeDetector::Shape> ShapeDetector::detectShapes(const cv::Mat &frame) {
    std::vector<Shape> shapes = std::vector<Shape>();
    detectCircles(frame, &shapes);
    return shapes;
}

void ShapeDetector::detectCircles(const cv::Mat &src, std::vector<Shape> *shapes) {
    std::vector<cv::Vec3f> circles;
    cv::Mat imgGray;
    cv::cvtColor(src, imgGray, cv::COLOR_RGBA2GRAY);
    if (!src.empty()) {
        cv::medianBlur(imgGray, imgGray, 5);
        //cv::Canny(src, src, 150, 200);
        // cv::threshold(src,src,150,255,cv::THRESH_BINARY);
        cv::HoughCircles(imgGray, circles, cv::HOUGH_GRADIENT, 1, 100, 100, 100, 100);

        for (auto circle : circles) {
            std::vector<Point> points = std::vector<Point>();

            float &x = circle[0];
            float &y = circle[1];
            float &radius = circle[2];

            int imageWidth = src.cols;
            int imageHeight = src.rows;
            // get normalised values
            float xn = x / imageWidth;
            float yn = y / imageHeight;
            float rn = (x + radius) / imageWidth;
            cv::circle(src, {(int) circle[0], (int) circle[1]}, circle[2], {0, 0, 0,});
            auto centreXY = new ShapeDetector::Point(xn, yn);
            auto outerXY = new ShapeDetector::Point(rn, yn);
            points.push_back(*centreXY);
            points.push_back(*outerXY);
            auto pShape = new ShapeDetector::Shape(-1, points);
            shapes->push_back(*pShape);
        }
        //cv::imwrite("/data/data/scanbot.sdk.flutter_ffi_demo/files/debug_circles.jpeg", src);

    }
}


