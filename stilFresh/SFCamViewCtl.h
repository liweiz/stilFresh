//
//  SFCamViewCtl.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-04.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SFBox.h"

@interface SFCamViewCtl : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *streamView;
@property (strong, nonatomic) AVCaptureDevice *inputDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureStillImageOutput *output;
@property (strong, nonatomic) SFBox *box;

@property (strong, nonatomic) UIButton *captureBtn;
@property (assign, nonatomic) BOOL isCapturing;

@property (strong, nonatomic) UIImage *img;

@end
