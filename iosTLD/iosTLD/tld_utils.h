#import <opencv2/opencv.hpp>
#pragma once
using namespace cv;


void drawBox(cv::Mat& image, CvRect box, cv::Scalar color = cv::Scalar(255,255,255,255), int thick=3);

void drawPoints(cv::Mat& image, std::vector<cv::Point2f> points,cv::Scalar color=cv::Scalar::all(255));

cv::Mat createMask(const cv::Mat& image, CvRect box);

float median(std::vector<float> v);

std::vector<int> index_shuffle(int begin,int end);

