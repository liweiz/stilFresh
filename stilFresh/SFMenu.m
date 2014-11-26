//
//  SFMenu.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFMenu.h"
#import "SFBox.h"
#import <Foundation/Foundation.h>

@implementation SFMenu

- (instancetype)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self) {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 2);
        self.pagingEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1;
    }
    return self;
}

- (void)setup
{
    [self getHintSwitch];
    [self getColorIntro:CGRectMake(0, CGRectGetMaxY(self.hintSwitch.frame) + gapToEdgeL * 2, self.frame.size.width, 400)];
}

- (void)getHintSwitch {
    CGFloat g = 40;
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(gapToEdgeM, g, 90, 44)];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [SFBox sharedBox].darkText;
    l.textAlignment = NSTextAlignmentLeft;
    l.adjustsFontSizeToFitWidth = YES;
    l.text = @"Show hints";
    [self addSubview:l];
    self.hintSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - g - 60, l.frame.origin.y, 60, l.frame.size.height + 16)];
    self.hintSwitch.frame = CGRectMake(self.frame.size.width - gapToEdgeL - self.hintSwitch.frame.size.width, l.frame.origin.y + l.frame.size.height / 2 - self.hintSwitch.frame.size.height / 2, self.hintSwitch.frame.size.width, self.hintSwitch.frame.size.height);
    self.hintSwitch.on = [SFBox sharedBox].hintIsOn;
    [self.hintSwitch addTarget:self action:@selector(switchHint:) forControlEvents:UIControlEventValueChanged];
    self.hintSwitch.onTintColor = [SFBox sharedBox].sfGreen0;
    [self addSubview:self.hintSwitch];
}

- (void)getColorIntro:(CGRect)baseFrame {
    UIView *base = [[UIView alloc] initWithFrame:baseFrame];
    base.backgroundColor = [UIColor clearColor];
    [self addSubview:base];
    UILabel *introTitle = [[UILabel alloc] initWithFrame:CGRectMake(gapToEdgeM, 0, base.frame.size.width, 44)];
    introTitle.backgroundColor = [UIColor clearColor];
    introTitle.textColor = [SFBox sharedBox].darkText;
    introTitle.text = @"What do the colors indicate?";
    [base addSubview:introTitle];
    
    // Point with intro
    CGFloat h0 = 30;
    CGFloat h1 = h0 * 6;
    CGFloat w = 200;
    
    UIView *datePoint0 = [[UIView alloc] initWithFrame:CGRectMake(gapToEdgeL, introTitle.frame.size.height, h0, h0)];
    datePoint0.layer.cornerRadius = datePoint0.frame.size.height / 2;
    datePoint0.backgroundColor = [UIColor whiteColor];
    [base addSubview:datePoint0];
    
    UILabel *datePoint0Intro = [[UILabel alloc] initWithFrame:CGRectMake(baseFrame.size.width - gapToEdgeL - w, datePoint0.frame.origin.y, w, h0)];
    datePoint0Intro.backgroundColor = [UIColor clearColor];
    datePoint0Intro.textColor = [SFBox sharedBox].darkText;
    datePoint0Intro.textAlignment = NSTextAlignmentRight;
    datePoint0Intro.text = @"Date purchased";
    [base addSubview:datePoint0Intro];
    
    UIView *datePoint1 = [[UIView alloc] initWithFrame:CGRectMake(datePoint0.frame.origin.x, CGRectGetMaxY(datePoint0.frame) + h1, h0, h0)];
    datePoint1.layer.cornerRadius = datePoint1.frame.size.height / 2;
    datePoint1.backgroundColor = [UIColor whiteColor];
    [base addSubview:datePoint1];
    
    UILabel *datePoint1Intro = [[UILabel alloc] initWithFrame:CGRectMake(datePoint0Intro.frame.origin.x, datePoint1.frame.origin.y, w, h0)];
    datePoint1Intro.backgroundColor = [UIColor clearColor];
    datePoint1Intro.textColor = [SFBox sharedBox].darkText;
    datePoint1Intro.textAlignment = NSTextAlignmentRight;
    datePoint1Intro.text = @"Best before date";
    [base addSubview:datePoint1Intro];
    
    // colorRect with intro
    CGFloat vw = 20;
    
    UIView *v0 = [[UIView alloc] initWithFrame:CGRectMake(datePoint0.frame.origin.x + CGRectGetWidth(datePoint0.frame) / 2 - vw / 2, datePoint0.frame.origin.y + CGRectGetHeight(datePoint0.frame) / 2, vw, h1 / 3 + datePoint0.frame.size.height / 2)];
    v0.backgroundColor = [SFBox sharedBox].sfGreen0;
    [base insertSubview:v0 belowSubview:datePoint0];
    
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(v0.frame.origin.x, CGRectGetMaxY(v0.frame), vw, h1 / 3)];
    v1.backgroundColor = [SFBox sharedBox].sfGreen1;
    [base addSubview:v1];
    
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(v0.frame.origin.x, CGRectGetMaxY(v1.frame), vw, h1 / 3 + datePoint0.frame.size.height / 2)];
    v2.backgroundColor = [SFBox sharedBox].sfGreen2;
    [base insertSubview:v2 belowSubview:datePoint1];
    
    base.frame = CGRectMake(base.frame.origin.x, base.frame.origin.y, base.frame.size.width, CGRectGetMaxY(datePoint1.frame) + gapToEdgeL);
    
    self.contentSize = CGSizeMake(self.contentSize.width, CGRectGetMaxY(base.frame));
}

// Switch hint
- (void)switchHint:(UISwitch *)sender
{
    [[SFBox sharedBox] switchHint]; 
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
