//
//  SFHintBase.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-23.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFHintBase.h"

@implementation SFHintBase

- (instancetype)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.alpha = 0.8;
        CGFloat gap = 20;
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(gap, aRect.size.height - gap - 44, aRect.size.width - gap * 2, 44)];
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor whiteColor];
        l.textAlignment = NSTextAlignmentCenter;
        l.text = @"Tap anywhere to dismiss";
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tap];
        [self addSubview:l];
    }
    return self;
}

- (void)dismiss
{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
