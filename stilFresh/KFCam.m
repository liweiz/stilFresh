//
//  KFCam.m
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

//
//  SimpleCam.m
//  SimpleCam
//
//  Created by Logan Wright on 2/1/14.
//  Copyright (c) 2014 Logan Wright. All rights reserved.
//
//  Mozilla Public License v2.0
//
//  **
//
//  PLEASE FAMILIARIZE YOURSELF WITH THE ----- Mozilla Public License v2.0
//
//  **
//
//  Attribution is satisfied by acknowledging the use of SimpleCam,
//  or its creation by Logan Wright
//
//  **
//
//  You can use, modify and redistribute this code in your product,
//  but to satisfy the requirements of Mozilla Public License v2.0,
//  it is required to provide the source code for any fixes you make to it.
//
//  **
//
//  Covered Software is provided under this License on an “as is” basis, without warranty of any
//  kind, either expressed, implied, or statutory, including, without limitation, warranties that
//  the Covered Software is free of defects, merchantable, fit for a particular purpose or non-
//  infringing. The entire risk as to the quality and performance of the Covered Software is with
//  You. Should any Covered Software prove defective in any respect, You (not any Contributor)
//  assume the cost of any necessary servicing, repair, or correction. This disclaimer of
//  warranty constitutes an essential part of this License. No use of any Covered Software is
//  authorized under this License except under this disclaimer.
//
//  **
//

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#import "KFCam.h"

static CGFloat optionAvailableAlpha = 0.6;

@interface SimpleCam ()
{
    // Measurements
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat topX;
    CGFloat topY;
    
    // Capture Toggle
    BOOL isCapturingImage;
}

// Square Border
@property (strong, nonatomic) UIView * squareV;

// Controls
@property (strong, nonatomic) UIButton * backBtn;
@property (strong, nonatomic) UIButton * captureBtn;
//@property (strong, nonatomic) UIButton * flashBtn;
//@property (strong, nonatomic) UIButton * switchCameraBtn;
@property (strong, nonatomic) UIButton * saveBtn;

// AVFoundation Properties
@property (strong, nonatomic) AVCaptureSession * mySesh;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureDevice * myDevice;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

// View Properties
@property (strong, nonatomic) UIView * imageStreamV;
@property (strong, nonatomic) UIImageView * capturedImageV;

@end

@implementation SimpleCam;

@synthesize hideAllControls = _hideAllControls, hideBackButton = _hideBackButton, hideCaptureButton = _hideCaptureButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        self.controlAnimateDuration = 0.25;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    screenWidth = self.view.bounds.size.width;
    screenHeight = self.view.bounds.size.height;
    
//    if  (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    self.view.frame = CGRectMake(0, 0, screenHeight, screenWidth);
    
    if (_imageStreamV == nil) _imageStreamV = [[UIView alloc]init];
    _imageStreamV.alpha = 0;
    _imageStreamV.frame = self.view.bounds;
    [self.view addSubview:_imageStreamV];
    
    if (_capturedImageV == nil) _capturedImageV = [[UIImageView alloc]init];
    _capturedImageV.frame = _imageStreamV.frame; // just to even it out
    _capturedImageV.backgroundColor = [UIColor clearColor];
    _capturedImageV.userInteractionEnabled = YES;
    _capturedImageV.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:_capturedImageV aboveSubview:_imageStreamV];
    
    // for focus
    UITapGestureRecognizer * focusTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSent:)];
    focusTap.numberOfTapsRequired = 1;
    [_capturedImageV addGestureRecognizer:focusTap];
    
    // SETTING UP CAM
    if (_mySesh == nil) _mySesh = [[AVCaptureSession alloc] init];
    _mySesh.sessionPreset = AVCaptureSessionPresetPhoto;
    
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_mySesh];
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureVideoPreviewLayer.frame = _imageStreamV.layer.bounds; // parent of layer
    
    [_imageStreamV.layer addSublayer:_captureVideoPreviewLayer];
    
    // rear camera: 0 front camera: 1
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count==0) {
        NSLog(@"SC: No devices found (for example: simulator)");
        return;
    }
    _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
    
    if ([_myDevice isFlashAvailable] && _myDevice.flashActive && [_myDevice lockForConfiguration:nil]) {
        //NSLog(@"SC: Turning Flash Off ...");
        _myDevice.flashMode = AVCaptureFlashModeOff;
        [_myDevice unlockForConfiguration];
    }
    
    NSError * error = nil;
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:&error];
    
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"SC: ERROR: trying to open camera: %@", error);
        [_delegate simpleCam:self didFinishWithImage:_capturedImageV.image];
    }
    
    [_mySesh addInput:input];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [_mySesh addOutput:_stillImageOutput];
    
    [_mySesh startRunning];
    
    // -- PREPARE OUR CONTROLS -- //
    [self loadControls];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _imageStreamV.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([(NSObject *)_delegate respondsToSelector:@selector(simpleCamDidLoadCameraIntoView:)]) {
                [_delegate simpleCamDidLoadCameraIntoView:self];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"SC: DID RECIEVE MEMORY WARNING");
    // Dispose of any resources that can be recreated.
}

#pragma mark CAMERA CONTROLS

- (void) loadControls {
    
    // -- LOAD BUTTON IMAGES BEGIN -- //
//    UIImage * previousImg = [UIImage imageNamed:@"Previous.png"];
    // -- LOAD BUTTON IMAGES END -- //
    
    // -- LOAD BUTTONS BEGIN -- //
    _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [_backBtn setImage:previousImg forState:UIControlStateNormal];
    [_backBtn setTintColor:[self redColor]];
    [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(9, 10, 9, 13)];
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [_saveBtn setImage:downloadImg forState:UIControlStateNormal];
    [_saveBtn setTintColor:[self blueColor]];
    [_saveBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 10.5, 7, 10.5)];
    
    _captureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [_captureBtn setTitle:NSLocalizedString(@"C\nA\nP\nT\nU\nR\nE", @"SimpleCam CAPTURE button for horizontal") forState:UIControlStateNormal];
    [_captureBtn setTitleColor:[self darkGreyColor] forState:UIControlStateNormal];
    _captureBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    _captureBtn.titleLabel.numberOfLines = 0;
    _captureBtn.titleLabel.minimumScaleFactor = .5;
    // -- LOAD BUTTONS END -- //
    
    // Stylize buttons
    for (UIButton * btn in @[_backBtn, _captureBtn, _saveBtn])  {
        
        btn.bounds = CGRectMake(0, 0, 40, 40);
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:.96];
        btn.alpha = optionAvailableAlpha;
        btn.hidden = YES;
        
        btn.layer.shouldRasterize = YES;
        btn.layer.rasterizationScale = [UIScreen mainScreen].scale;
        btn.layer.cornerRadius = 4;
        
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 0.5;
        
        [self.view addSubview:btn];
    }
    
    // Draw camera controls
    [self drawControls];
}

- (void) drawControls {
    
    if (self.hideAllControls) {
        
        // In case they want to hide after they've been displayed
        // for (UIButton * btn in @[_backBtn, _captureBtn, _flashBtn, _switchCameraBtn, _saveBtn]) {
        // btn.hidden = YES;
        // }
        return;
    }
    
    static int offsetFromSide = 10;
    static int offsetBetweenButtons = 20;
    
    static CGFloat portraitFontSize = 16.0;
    
    [UIView animateWithDuration:self.controlAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        CGFloat centerY = screenHeight - 8 - 20; // 8 is offset from bottom (portrait), 20 is half btn height
        
        _backBtn.center = CGPointMake(offsetFromSide + (_backBtn.bounds.size.width / 2), centerY);
        
        // offset from backbtn is '20'
        [_captureBtn setTitle:NSLocalizedString(@"CAPTURE", @"SimpleCam CAPTURE button") forState:UIControlStateNormal];
        _captureBtn.titleLabel.font = [UIFont systemFontOfSize:portraitFontSize];
        _captureBtn.bounds = CGRectMake(0, 0, 120, 40);
        _captureBtn.center = CGPointMake(_backBtn.center.x + (_backBtn.bounds.size.width / 2) + offsetBetweenButtons + (_captureBtn.bounds.size.width / 2), centerY);
        
        // just so it's ready when we need it to be.
        _saveBtn.frame = _backBtn.frame;
        
        /*
         Show the proper controls for picture preview and picture stream
         */
        
        // If camera preview -- show preview controls / hide capture controls
        if (_capturedImageV.image) {
            // Hide
            for (UIButton * btn in @[_captureBtn]) btn.hidden = YES;
            // Show
            _saveBtn.hidden = NO;
            
            
            // Force User Preference
            _backBtn.hidden = _hideBackButton;
        }
        // ELSE camera stream -- show capture controls / hide preview controls
        else {
            // Show
            // Hide
            _saveBtn.hidden = YES;
            
            // Force User Preference
            _captureBtn.hidden = _hideCaptureButton;
            _backBtn.hidden = _hideBackButton;
        }
        
    } completion:nil];
}

- (void) capturePhoto {
    if (isCapturingImage) {
        return;
    }
    isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         UIImage * capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
         
         if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
         }
         
         isCapturingImage = NO;
         _capturedImageV.image = capturedImage;
         imageData = nil;
         
         // If we have disabled the photo preview directly fire the delegate callback, otherwise, show user a preview
         _disablePhotoPreview ? [self photoCaptured] : [self drawControls];
     }];
}

- (void) photoCaptured {
    [_delegate simpleCam:self didFinishWithImage:_capturedImageV.image];
}

#pragma mark BUTTON EVENTS

- (void) captureBtnPressed:(id)sender {
    [self capturePhoto];
}

- (void) saveBtnPressed:(id)sender {
    [self photoCaptured];
}

- (void) backBtnPressed:(id)sender {
    if (_capturedImageV.image) {
        _capturedImageV.contentMode = UIViewContentModeScaleAspectFill;
        _capturedImageV.backgroundColor = [UIColor clearColor];
        _capturedImageV.image = nil;
        
        [self drawControls];
    }
    else {
        [_delegate simpleCam:self didFinishWithImage:_capturedImageV.image];
    }
}

#pragma mark TAP TO FOCUS

- (void) tapSent:(UITapGestureRecognizer *)sender {
    
    if (_capturedImageV.image == nil) {
        CGPoint aPoint = [sender locationInView:_imageStreamV];
        if (_myDevice != nil) {
            if([_myDevice isFocusPointOfInterestSupported] &&
               [_myDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                
                // we subtract the point from the width to inverse the focal point
                // focus points of interest represents a CGPoint where
                // {0,0} corresponds to the top left of the picture area, and
                // {1,1} corresponds to the bottom right in landscape mode with the home button on the right—
                // THIS APPLIES EVEN IF THE DEVICE IS IN PORTRAIT MODE
                // (from docs)
                // this is all a touch wonky
                double pX = aPoint.x / _imageStreamV.bounds.size.width;
                double pY = aPoint.y / _imageStreamV.bounds.size.height;
                double focusX = pY;
                // x is equal to y but y is equal to inverse x ?
                double focusY = 1 - pX;
                
                //NSLog(@"SC: about to focus at x: %f, y: %f", focusX, focusY);
                if([_myDevice isFocusPointOfInterestSupported] && [_myDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    
                    if([_myDevice lockForConfiguration:nil]) {
                        [_myDevice setFocusPointOfInterest:CGPointMake(focusX, focusY)];
                        [_myDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                        [_myDevice setExposurePointOfInterest:CGPointMake(focusX, focusY)];
                        [_myDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                        //NSLog(@"SC: Done Focusing");
                    }
                    [_myDevice unlockForConfiguration];
                }
            }
        }
    }
}


#pragma mark CLOSE

- (void) closeWithCompletion:(void (^)(void))completion {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        completion();
        
        // Clean Up
        
        [_mySesh stopRunning];
        _mySesh = nil;
        
        _capturedImageV.image = nil;
        [_capturedImageV removeFromSuperview];
        _capturedImageV = nil;
        
        [_imageStreamV removeFromSuperview];
        _imageStreamV = nil;
        
        
        _stillImageOutput = nil;
        _myDevice = nil;
        
        self.view = nil;
        _delegate = nil;
        [self removeFromParentViewController];
        
    }];
}

#pragma mark COLORS

- (UIColor *) darkGreyColor {
    return [UIColor colorWithRed:0.226082 green:0.244034 blue:0.297891 alpha:1];
}
- (UIColor *) redColor {
    return [UIColor colorWithRed:1 green:0 blue:0.105670 alpha:.6];
}
- (UIColor *) greenColor {
    return [UIColor colorWithRed:0.128085 green:.749103 blue:0.004684 alpha:0.6];
}
- (UIColor *) blueColor {
    return [UIColor colorWithRed:0 green:.478431 blue:1 alpha:1];
}

#pragma mark STATUS BAR

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark GETTERS | SETTERS

- (void) setHideAllControls:(BOOL)hideAllControls {
    _hideAllControls = hideAllControls;
    
    // This way, hideAllControls can be used as a toggle.
    [self drawControls];
}
- (BOOL) hideAllControls {
    return _hideAllControls;
}
- (void) setHideBackButton:(BOOL)hideBackButton {
    _hideBackButton = hideBackButton;
    _backBtn.hidden = _hideBackButton;
}
- (BOOL) hideBackButton {
    return _hideBackButton;
}
- (void) setHideCaptureButton:(BOOL)hideCaptureButton {
    _hideCaptureButton = hideCaptureButton;
    _captureBtn.hidden = YES;
}
- (BOOL) hideCaptureButton {
    return _hideCaptureButton;
}

@end