//
//  SFCamViewCtl.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-04.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFCamViewCtl.h"
#import "SFBox.h"

@interface SFCamViewCtl ()

@end

@implementation SFCamViewCtl


- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[SFBox sharedBox].appRect];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    
    if (!self.session) {
        self.session = [[AVCaptureSession alloc] init];
    }
    if (!self.streamView) {
        self.streamView = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.streamView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.streamView.frame = [SFBox sharedBox].appRect;
        [self.view.layer addSublayer:self.streamView];
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
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    } else {
        NSLog(@"cam error: AVCaptureDeviceInput error");
        return;
    }
    if (!self.output) {
        self.output = [[AVCaptureStillImageOutput alloc] init];
        self.output.outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    } else {
        NSLog(@"cam error: AVCaptureSession output error");
        return;
    }
    if (!self.captureBtn) {
        self.captureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat gapToBottom = 20.0f;
        CGFloat side = 80.0f;
        self.captureBtn.frame = CGRectMake((self.view.frame.size.width - side) / 2.0f, self.view.frame.size.height -gapToBottom - side, side, side);
        NSLog(@"btn: %f, %f, %f, %f", self.captureBtn.frame.origin.x, self.captureBtn.frame.origin.y, self.captureBtn.frame.size.height, self.captureBtn.frame.size.width);
        self.captureBtn.backgroundColor = [SFBox sharedBox].sfGreen0;
        self.captureBtn.layer.cornerRadius = side / 2.0f;
        [self.view addSubview:self.captureBtn];
        [self showCaptureBtn];
        [self.captureBtn addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.session startRunning];
}

- (void)capture
{
    if (self.isCapturing) {
        return;
    }
    self.isCapturing = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.output.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }

    [self.output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         self.img = [[UIImage alloc] initWithData:imageData scale:1];
         self.isCapturing = NO;
        [self loadPreview:self.img];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showPicDisposeHint" object:self];
     }];
}

- (void)loadPreview:(UIImage *)image
{
    self.captureBtn.hidden = YES;
    UIScrollView *base = [[UIScrollView alloc] initWithFrame:self.streamView.frame];
    base.tag = 555;
    base.contentSize = CGSizeMake(base.frame.size.width, base.frame.size.height * 2);
    base.backgroundColor = [UIColor clearColor];
    base.pagingEnabled = YES;
    base.bounces = YES;
    base.showsHorizontalScrollIndicator = NO;
    base.showsVerticalScrollIndicator = NO;
    base.delegate = self;
    UIImageView *picTaken = [[UIImageView alloc] initWithFrame:self.streamView.frame];
    picTaken.contentMode = UIViewContentModeScaleAspectFill;
    picTaken.image = image;
    [base addSubview:picTaken];
    [self.view addSubview:base];
}




//- (void) photoCaptured {
//    [_delegate simpleCam:self didFinishWithImage:_capturedImageV.image];
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.alpha = 1 - scrollView.contentOffset.y / scrollView.frame.size.height;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (targetContentOffset->y == scrollView.frame.size.height) {
        scrollView.userInteractionEnabled = NO;
        self.captureBtn.hidden = NO;
        [self showCaptureBtn];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == scrollView.frame.size.height) {
        [scrollView removeFromSuperview];
    }
}

- (void)showCaptureBtn
{
    self.img = nil;
    CABasicAnimation *show = [CABasicAnimation animationWithKeyPath:@"opacity"];
    show.fromValue = [NSNumber numberWithFloat:0];
    show.toValue = [NSNumber numberWithFloat:1];
    show.duration = 0.6;
    show.delegate = self;
    show.removedOnCompletion = YES;
    [self.captureBtn.layer addAnimation:show forKey:nil];
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
