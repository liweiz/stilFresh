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
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 2);
        self.delegate = self;
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor lightGrayColor];
        self.alpha = 0.8;
        CGFloat gap = 20;
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(gap, aRect.size.height - gap - 70, aRect.size.width - gap * 2, 70)];
        l.numberOfLines = 2;
        l.backgroundColor = [UIColor clearColor];
        l.textColor = [UIColor whiteColor];
        l.textAlignment = NSTextAlignmentCenter;
        l.adjustsFontSizeToFitWidth = YES;
        l.text = @"Tap anywhere to dismiss\nSwipe up to turn off all hints";
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

- (void)turnOffHint
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"turnOffHint" object:self];
    self.userInteractionEnabled = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.alpha = 0.8 * (1 - scrollView.contentOffset.y / scrollView.frame.size.height);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (targetContentOffset->y == scrollView.frame.size.height) {
        [self turnOffHint];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.userInteractionEnabled == NO && scrollView.contentOffset.y == scrollView.frame.size.height) {
        [self dismiss];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
