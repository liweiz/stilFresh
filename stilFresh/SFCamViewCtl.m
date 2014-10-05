//
//  SFCamViewCtl.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-04.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFCamViewCtl.h"

@interface SFCamViewCtl ()

@end

@implementation SFCamViewCtl

@synthesize session;
@synthesize preview;
@synthesize inputDevice;
@synthesize input;
@synthesize box;
@synthesize captureBtn;

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:self.box.appRect];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    
    if (!self.session) {
        self.session = [[AVCaptureSession alloc] init];
    }
    if (!self.preview) {
        self.preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.preview.frame = self.box.appRect;
        [self.view.layer addSublayer:self.preview];
    }
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count==0) {
        NSLog(@"cam error: No devices found (for example: simulator)");
        return;
    }
    if (!self.inputDevice) {
        self.inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    NSError *err = nil;
    if (!self.input) {
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:&err];
        if (err) {
            NSLog(@"cam error: AVCaptureDeviceInput error");
            return;
        }
        [self.session addInput:self.input];
    }
    if (!self.output) {
        self.output = [[AVCaptureStillImageOutput alloc] init];
        self.output.outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.session addOutput:self.output];
    }
    if (!self.captureBtn) {
        self.captureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat gapToBottom = 20.0f;
        CGFloat side = 80.0f;
        self.captureBtn.frame = CGRectMake((self.view.frame.size.width - side) / 2.0f, self.view.frame.size.height -gapToBottom - side, side, side);
        NSLog(@"btn: %f, %f, %f, %f", self.captureBtn.frame.origin.x, self.captureBtn.frame.origin.y, self.captureBtn.frame.size.height, self.captureBtn.frame.size.width);
        self.captureBtn.backgroundColor = self.box.sfGreen0;
        [self.view addSubview:self.captureBtn];
        [self.view bringSubviewToFront:self.captureBtn];
    }
    [self.session startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
