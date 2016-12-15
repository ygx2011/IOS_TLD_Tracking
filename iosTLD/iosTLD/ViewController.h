//
//  ViewController.h
//  iosTLD
//
//  Created by 应高选 on 15/3/6.
//  Copyright (c) 2015年 应高选. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>

@interface ViewController : UIViewController<UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CvVideoCameraDelegate>

- (IBAction)startButtonPressed:(id)sender;
- (IBAction)changeCaButtonPressed:(id)sender;
- (IBAction)stopButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *start;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *changeCa;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *stop;

@property (weak, nonatomic) IBOutlet UITextField *field;

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@end

