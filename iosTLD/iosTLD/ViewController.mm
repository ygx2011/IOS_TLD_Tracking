//
//  ViewController.m
//  iosTLD
//
//  Created by 应高选 on 15/3/6.
//  Copyright (c) 2015年 应高选. All rights reserved.
//

#import "ViewController.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>

#import <opencv2/highgui/cap_ios.h>

#include "tld_utils.h"
#include <iostream>
#include <sstream>
#include "TLD.h"
#include <stdio.h>
using namespace cv;
using namespace std;

@interface ViewController ()
{
    CvVideoCamera* videoCamera;
    
    cv::Rect box;
    bool drawing_box;
    bool gotBB;
    bool tl;
    
    bool video_open;
    bool tracking;
    
    TLD tld;
    Mat last_gray;
    Mat current_gray;
    BoundingBox pbox;
    //vector<Point2f> pts1;
    //vector<Point2f> pts2;
    bool status;
    int frames;
    
    int start_count;
    int changeca_count;
    
    int MinWin;
    
}

@end

@implementation ViewController

@synthesize videoCamera = _videoCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:@"Welcome to iosTLD" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    alert.tag = 0;
    [alert show];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"ygx.jpg"];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    video_open = false;
    start_count = 0;
    changeca_count = 0;
    MinWin = 0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonPressed:(id)sender {
    
    if (MinWin>=15 && MinWin<=30)
    {
        self.field.userInteractionEnabled = NO;
        if (video_open == false)
        {
            start_count++;
            if (start_count == 1)
            {
                [self.videoCamera start];
                video_open = true;
                frames = 0;
                drawing_box = false;
                gotBB = false;
                tl = true;
                tracking = false;
                status = true;
                
                tld.read(MinWin);
            }
            else
            {
                [self.videoCamera start];
                video_open = true;
                frames = 1;
                drawing_box = false;
                gotBB = false;
                tl = true;
                tracking = true;
                status = true;
            }
        }
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Please Input Correct MinWin." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)processImage:(cv::Mat &)image
{
    //////////////////////////TLD//////////////////////////////
    if (drawing_box == true)
    {
        drawbox(image, box);
    }
    if (gotBB == true)
    {
        frames = 1;
        cvtColor(image, last_gray, CV_BGRA2GRAY);
        tld.init(last_gray, box);
        
        gotBB = false;
        tracking = true;
    }
    if (tracking == true)
    {
        frames++;
        if(frames%2==0)
        {
            vector<Point2f> pts1;
            vector<Point2f> pts2;
            cvtColor(image, current_gray, CV_BGRA2GRAY);
            tld.processFrame(last_gray,current_gray,pts1,pts2,pbox,status,tl/*,bb_file*/);
            if (status)
            {
                //drawpts(image,pts1,Scalar(255,255,255,255));
                //drawpts(image,pts2,Scalar(0,255,0,255));
                drawBB(image,pbox);
            }
            swap(last_gray,current_gray);
            //pts1.clear();
            //pts2.clear();
        }
        else
        {
            if (status)
            {
                //drawpts(image,pts1,Scalar(255,255,255,255));
                //drawpts(image,pts2,Scalar(0,255,0,255));
                drawBB(image, pbox);
                //pts1.clear();
                //pts2.clear();
            }
        }
        
        cout<<"start tracking"<<" "<<frames<<" "<<MinWin<<endl;
    }
    //////////////////////////TLD//////////////////////////////
}

void drawbox(cv::Mat& image, cv::Rect box, cv::Scalar color=cvScalar(0,0,255,255), int thick=1){
    rectangle( image, cvPoint(box.x, box.y), cvPoint(box.x+box.width,box.y+box.height),color, thick);
}

void drawBB(cv::Mat& image, cv::Rect box, cv::Scalar color=cvScalar(0,255,0,255), int thick=1){
    rectangle( image, cvPoint(box.x, box.y), cvPoint(box.x+box.width,box.y+box.height),color, thick);
}

void drawpts(cv::Mat& image, vector<Point2f> points,Scalar color){
    for( vector<Point2f>::const_iterator i = points.begin(), ie = points.end(); i != ie; ++i )
    {
        cv::Point center( cvRound(i->x ), cvRound(i->y));
        circle(image,*i,2,color,1);
    }
}

- (IBAction)changeCaButtonPressed:(id)sender {
    
    if (video_open == true)
    {
        changeca_count++;
        [self.videoCamera stop];
        if (changeca_count%2 != 0)
        {
            self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        }
        else
        {
            self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        }
        [self.videoCamera start];
    }
    
}

- (IBAction)stopButtonPressed:(id)sender {
    
    if (video_open == true)
    {
        [self.videoCamera stop];
        video_open = false;
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (tracking == false)
    {
        [self.field resignFirstResponder];
        MinWin = [self.field.text intValue];
        std::cout<<"MinWin:"<<MinWin<<endl;
        //string s = [self.field.text UTF8String];
        //MinWin = atoi(s.c_str());
        if (start_count == 1)
        {
            NSSet *allTouches = [event allTouches];
            UITouch *touch = [allTouches anyObject];
            CGPoint point = [touch locationInView:[touch view]];
            /*
            //4-inch
            if (point.x>=16 && point.y>=108 && point.x<=304 && point.y<= 460)
            {
                box.x=NULL;
                box.y=NULL;
                box.width=NULL;
                box.height=NULL;
                drawing_box = true;
                gotBB = false;
                tracking = false;
                box.x = point.x-16;
                box.y = point.y-108;
            }
            */
            
            //4.7-inch
            if (point.x>=43 && point.y>=158 && point.x<=331 && point.y<= 510)
            {
                box.x=NULL;
                box.y=NULL;
                box.width=NULL;
                box.height=NULL;
                drawing_box = true;
                gotBB = false;
                tracking = false;
                box.x = point.x-43;
                box.y = point.y-158;
            }
            else
            {
                box.x = -1;
                box.y = -1;
            }
        }
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (tracking == false)
    {
    if (start_count == 1)
    {
        NSSet *allTouches = [event allTouches];
        UITouch *touch = [allTouches anyObject];
        CGPoint point = [touch locationInView:[touch view]];
        /*
        //4-inch
        if (point.x>=16 && point.y>=108 && point.x<=304 && point.y<= 460)
        {
            box.width = point.x-16-box.x;
            box.height = point.y-108-box.y;
        }
        */
        //4.7-inch
        if (point.x>=43 && point.y>=158 && point.x<=331 && point.y<= 510)
        {
            box.width = point.x-43-box.x;
            box.height = point.y-158-box.y;
        }
        
    }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (tracking == false)
    {
    if (start_count == 1)
    {
    if (box.x>=0 && box.y>=0 && box.x+box.width<=288 && box.height+box.y<=352 && box.width>=MinWin && box.height>=MinWin)
    {
        gotBB = true;
        drawing_box = false;
    }
    }
    }
}

@end
