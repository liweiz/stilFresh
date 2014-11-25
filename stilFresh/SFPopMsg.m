//
//  SFPopMsg.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-24.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFPopMsg.h"
#import "SFBox.h"

@implementation SFPopMsg

- (instancetype)init {
    self = [super init];
    if (self) {
        _base = [[UIView alloc] init];
        _base.backgroundColor = [SFBox sharedBox].sfGray;
        _base.layer.cornerRadius = 3;
        _text = [[UILabel alloc] init];
        _text.numberOfLines = 0;
        _text.backgroundColor = [UIColor clearColor];
        _text.textColor = [UIColor whiteColor];
        _text.textAlignment = NSTextAlignmentCenter;
        _text.lineBreakMode = NSLineBreakByWordWrapping;
        _text.font = [SFBox sharedBox].fontM;
        [_base addSubview:_text];
        _cancelBtn = [[UIButton alloc] init];
        _cancelBtn.backgroundColor = [UIColor clearColor];
        [_cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"Cancel" forState:UIControlStateSelected];
        [_base addSubview:_cancelBtn];
        _okBtn = [[UIButton alloc] init];
        _okBtn.backgroundColor = [UIColor clearColor];
        [_okBtn setTitle:@"Buy" forState:UIControlStateNormal];
        [_okBtn setTitle:@"Buy" forState:UIControlStateSelected];
        [_base addSubview:_okBtn];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarning:) name:@"generalError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarning:) name:@"detailedError" object:nil];
    return self;
}

- (void)setupWithBaseFrame:(CGRect)f textOnly:(BOOL)textOnly {
    self.base.frame = f;
    if (textOnly) {
        self.text.frame = CGRectMake(gapToEdgeM, gapToEdgeM, f.size.width - gapToEdgeM * 2, f.size.height - gapToEdgeM * 2);
        self.cancelBtn.hidden = YES;
        self.okBtn.hidden = YES;
    } else {
        CGFloat h = 44;
        self.text.frame = CGRectMake(gapToEdgeS, gapToEdgeS, f.size.width - gapToEdgeS * 2, f.size.height - gapToEdgeS * 2 - h);
        self.cancelBtn.frame = CGRectMake(0, f.size.height - gapToEdgeS - self.text.frame.size.height, f.size.width / 2, h);
        self.okBtn.frame = CGRectMake(f.size.width / 2, f.size.height - gapToEdgeS - self.text.frame.size.height, f.size.width / 2, h);
        self.cancelBtn.hidden = NO;
        self.okBtn.hidden = NO;
    }
    self.text.text = nil;
}

- (CGRect)getBaseFrameW:(CGFloat)w h:(CGFloat)h {
    return CGRectMake(([SFBox sharedBox].appRect.size.width - w) / 2, ([SFBox sharedBox].appRect.size.height - h) / 2, w, h);
}

- (void)showNoBtnMsg:(NSString *)msg {
    [self setupWithBaseFrame:[self getBaseFrameW:220 h:120] textOnly:YES];
    self.text.text = msg;
    self.base.alpha = 1;
    [self.base.superview bringSubviewToFront:self.base];
    if (!self.base.superview) {
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_base];
    }
    [UIView animateWithDuration:6 animations:^{
        self.base.alpha = 0;
    } completion:^(BOOL finished){
        //        self.warning.text = nil;
    }];
}

- (void)showWithBtnMsg:(NSString *)msg {
    [self setupWithBaseFrame:[self getBaseFrameW:220 h:120] textOnly:NO];
    self.text.text = msg;
    self.base.alpha = 1;
    [self.base.superview bringSubviewToFront:self.base];
    
}

- (void)showWarning:(NSNotification *)note
{
    // Clear the item inserted but not saved yet
    for (NSManagedObject *i in [SFBox sharedBox].ctx.insertedObjects) {
        [[SFBox sharedBox].ctx deleteObject:i];
    }
    NSString *msg;
    if ([note.name isEqualToString:@"generalError"]) {
        msg = @"Something went wrong, please try later.";
    } else {
        msg = [SFBox sharedBox].warningText;
    }
    [self showNoBtnMsg:msg];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
