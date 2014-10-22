//
//  SFHintView.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-22.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFHintView.h"

@implementation SFHintView

- (instancetype)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor grayColor];
    }
    return self;
}

- (void)setupWithImageName:(NSString *)name superView:(UIView *)view
{
    UIImage *i = [UIImage imageNamed:@"SwipeToCreate"];
    self.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    self.image = [UIImage imageNamed:@"SwipeToCreate"];
    [view addSubview:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
