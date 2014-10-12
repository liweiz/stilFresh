//
//  SFTimeLine.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-10.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFTimeLine.h"
#import "NSObject+SFExtra.h"

@implementation SFTimeLine

@synthesize box;
@synthesize dateAdded;
@synthesize bestBefore;
@synthesize today;
@synthesize dateSequence;
@synthesize bbBaseView;
@synthesize afterBbBaseView;
@synthesize timeLineWidth;
@synthesize axisPoint;
@synthesize timeLineHeight;
@synthesize bestBeforeIntro;
@synthesize bestBeforeL;
@synthesize dateAddedIntro;
@synthesize dateAddedL;
@synthesize todayIntro;
@synthesize todayL;
@synthesize singleLineHeight;
@synthesize labelWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dateSequence = [NSMutableArray arrayWithCapacity:0];
        self.axisPoint = CGPointMake(30, 30);
        self.timeLineWidth = 5;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)reset
{
    for (UIView *x in self.subviews) {
        [x removeFromSuperview];
    }
    [self.dateSequence setArray:[self placeDatesInOrder]];
    [self addTimeLineBase];
    if (self.bbBaseView) {
//        [self addColorToTimeLineBeforeBb];
        
    }
}




- (void)addTimeLineBase
{
    CGFloat h1 = [self getTimeLineHeightRatioBeforeBestBefore];
    CGFloat height = self.frame.size.height - self.gapY * 2;
    if (h1 == 0) {
        // Only timeLine after bestBefore needed.
        self.afterBbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY, self.timeLineWidth, height)];
        self.afterBbBaseView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.afterBbBaseView];
    } else if (h1 < 1) {
        CGFloat h2 = 1 - h1;
        self.bbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY, self.timeLineWidth, height * h1)];
        self.bbBaseView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bbBaseView];
        self.afterBbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY + self.bbBaseView.frame.size.height, self.timeLineWidth, height * h2)];
        self.afterBbBaseView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.afterBbBaseView];
    } else {
        // No timeLine after bestBefore needed.
        self.bbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY, self.timeLineWidth, height * h1)];
        self.bbBaseView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bbBaseView];
    }
    [self addDots:h1];
}

- (void)addDots:(CGFloat)bbBaseViewHeightRatio
{
    CGFloat w = 15;
    CGPoint p0 = CGPointMake(self.gapX + self.timeLineWidth / 2 - w / 2, self.gapY - w / 2);
    CGFloat x1 = p0.x + w / 2 / 2;
    CGFloat h = self.frame.size.height - self.gapY * 2;
    NSArray *a;
    if (bbBaseViewHeightRatio == 0) {
        UIView *d0 = [self createADot:w at:p0];
        UIView *d1 = [self createADot:w at:CGPointMake(p0.x, p0.y + h)];
        a = [NSArray arrayWithObjects:d0, d1, nil];
    } else if (bbBaseViewHeightRatio == 1) {
        UIView *d0 = [self createADot:w at:p0];
        UIView *d1 = [self createADot:w / 2 at:CGPointMake(x1, p0.y + h * bbBaseViewHeightRatio / 3)];
        UIView *d2 = [self createADot:w / 2 at:CGPointMake(x1, p0.y + h * bbBaseViewHeightRatio * 2 / 3)];
        UIView *d3 = [self createADot:w at:CGPointMake(p0.x, p0.y + h * bbBaseViewHeightRatio)];
        UIView *d4 = [self createADot:w at:CGPointMake(p0.x, p0.y + h)];
        a = [NSArray arrayWithObjects:d0, d1, d2, d3, d4, nil];
    } else {
        UIView *d0 = [self createADot:w at:p0];
        UIView *d1 = [self createADot:w / 2 at:CGPointMake(x1, p0.y + h / 3)];
        UIView *d2 = [self createADot:w / 2 at:CGPointMake(x1, p0.y + h * 2 / 3)];
        UIView *d3 = [self createADot:w at:CGPointMake(p0.x, p0.y + h)];
        a = [NSArray arrayWithObjects:d0, d1, d2, d3, nil];
    }
    for (UIView *i in a) {
        [self addSubview:i];
    }
}



- (void)addLabels
{
    CGFloat w = 15;
    CGPoint p0 = CGPointMake(self.gapX + self.timeLineWidth / 2 - w / 2, self.gapY - w / 2);
    CGFloat x1 = p0.x + w / 2 / 2;
    CGFloat h = self.frame.size.height - self.gapY * 2;
    NSArray *a;
    if ([self.dateSequence count] == 3) {
        self.dateAddedIntro = [UILabel alloc] initWithFrame:<#(CGRect)#>
    }
}

- (void)addOneLargeDotSet:(CGPoint)p lines:(NSInteger)n gap:(CGFloat)g text1:(NSString *)t1 text2:(NSString *)t2
{
    CGPoint a0 = [self getDotOriginX:p.x y:p.y width:self.radiusL];
    UIView *d0 = [self createADot:self.radiusS at:a0];
    [self addSubview:d0];
    CGFloat h;
    if (n == 1) {
        h = self.singleLineHeight;
    } else if (n == 2) {
        h = self.singleLineHeight * 2;
    } else if (n == 3) {
        h = self.singleLineHeight * 3;
    }
    CGPoint a1 = [self getLeftLabelOriginX:p.x y:p.y height:h gap:g];
    UILabel *d1 = [self createLeftLabel:h at:a1];
    d1.backgroundColor = [UIColor clearColor];
    d1.text = t1;
    [self addSubview:d1];
    CGPoint a2 = [self getRightLabelOriginX:p.x y:p.y height:h gap:g];
    UILabel *d2 = [self createRightLabel:h at:a2];
    d2.backgroundColor = [UIColor clearColor];
    d2.text = t2;
    [self addSubview:d2];
}

- (void)addSmallDots:(NSArray *)a
{
    if ([a count] == 3) {
        CGPoint a00 = (CGPoint)a[0];
        CGPoint a0 = [self getDotOriginX:a00.x y:a00.y width:self.radiusS];
        UIView *d0 = [self createADot:self.radiusS at:a0];
        d0.backgroundColor = [UIColor whiteColor];
        [self addSubview:d0];
        CGPoint a01 = (CGPoint)a[1];
        CGPoint a1 = [self getDotOriginX:a01.x y:a01.y width:self.radiusS];
        UIView *d1 = [self createADot:self.radiusS at:a1];
        d1.backgroundColor = [UIColor whiteColor];
        [self addSubview:d1];
    }
}

- (UILabel *)createLeftLabel:(CGFloat)height at:(CGPoint)origin
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, self.labelWidth, height)];
    l.backgroundColor = [UIColor clearColor];
    l.textAlignment = NSTextAlignmentRight;
    return l;
}

- (UILabel *)createRightLabel:(CGFloat)height at:(CGPoint)origin
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, self.labelWidth, height)];
    l.backgroundColor = [UIColor clearColor];
    l.textAlignment = NSTextAlignmentLeft;
    return l;
}

- (UIView *)createADot:(CGFloat)width at:(CGPoint)origin
{
    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, width)];
    dot.layer.cornerRadius = dot.frame.size.width / 2;
    dot.backgroundColor = [UIColor whiteColor];
    return dot;
}

- (CGPoint)getLeftLabelOriginX:(CGFloat)x y:(CGFloat)y height:(CGFloat)h gap:(CGFloat)g
{
    CGFloat xx = x - g - self.labelWidth;
    CGFloat yy = y - h / 2;
    return CGPointMake(xx, yy);
}

- (CGPoint)getRightLabelOriginX:(CGFloat)x y:(CGFloat)y height:(CGFloat)h gap:(CGFloat)g
{
    CGFloat xx = x + g;
    CGFloat yy = y - h / 2;
    return CGPointMake(xx, yy);
}

- (CGPoint)getDotOriginX:(CGFloat)x y:(CGFloat)y width:(CGFloat)w
{
    CGFloat xx = x - w;
    CGFloat yy = y - w;
    return CGPointMake(xx, yy);
}

- (CGPoint)getTodayPoint
{
    if ([self.dateSequence count] == 3) {
        if ([self.dateSequence[0] isEqual:self.today]) {
            return self.axisPoint;
        } else if ([self.dateSequence[2] isEqual:self.today]) {
            return CGPointMake(self.axisPoint.x, self.axisPoint.y + self.timeLineHeight);
        } else {
            CGFloat r = [self getTodayRatio];
            return CGPointMake(self.axisPoint.x, self.axisPoint.y + self.timeLineHeight * r);
        }
    }
}

// Today is not a fixed point.
- (NSArray *)getFixedPointsOnBestBefore
{
    CGFloat ratio = [self getTimeLineHeightRatioBeforeBestBefore];
    if (ratio != 0 && ratio != 1) {
        CGPoint p1 = CGPointMake(self.axisPoint.x, self.axisPoint.y + self.bbBaseView.frame.size.height / 3);
        CGPoint p2 = CGPointMake(self.axisPoint.x, self.axisPoint.y + self.bbBaseView.frame.size.height * 2 / 3);
        CGPoint p3 = CGPointMake(self.axisPoint.x, self.axisPoint.y + self.bbBaseView.frame.size.height);
        return NSArray arrayWithObjects:p1, p2, p3, nil];
    }
    return nil;
}

// This only happens when today is between the other two.
- (CGFloat)getTodayRatio
{
    if ([self.dateSequence count] == 3 && [self.dateSequence[1] isEqual:self.today]) {
        NSInteger base = [self getDaysLeftFrom:self.dateSequence[0] to:self.dateSequence[2]];
        NSInteger mid = [self getDaysLeftFrom:self.dateSequence[0] to:self.dateSequence[1]];
        return (CGFloat)mid / base;
    }
    return 0;
}

- (CGFloat)getTimeLineHeightRatioBeforeBestBefore
{
    // Proceed only when bestBefore is not the earliest time.
    if ([self.dateSequence count] > 1 && ![self.dateSequence[0] isEqual:self.bestBefore]) {
        if ([self.dateSequence count] == 3) {
            if ([self.dateSequence[2] isEqual:self.bestBefore]) {
                return 1;
            } else {
                NSInteger base = [self getDaysLeftFrom:self.dateSequence[0] to:self.dateSequence[2]];
                NSInteger mid = [self getDaysLeftFrom:self.dateSequence[0] to:self.dateSequence[1]];
                return (CGFloat)mid / base;
            }
        } else if ([self.dateSequence[0] isKindOfClass:[NSArray class]]) {
            // Implicitly means: [self.dateSequence count] == 2 here
            if ([(NSArray *)self.dateSequence[1] containsObject:self.bestBefore]) {
                return 1;
            }
        }
    }
    return 0;
}

// Find out the sequence of all dates.
- (NSArray *)placeDatesInOrder
{
    NSArray *a = [@[self.dateAdded, self.today, self.bestBefore] sortedArrayUsingComparator:^(NSDate *obj1, NSDate *obj2) {
        return [obj1 compare:obj2];
    }];
    NSDate *a0 = a[0];
    NSDate *a1 = a[1];
    NSDate *a2 = a[2];
    NSMutableArray *ma = [NSMutableArray arrayWithCapacity:0];
    if ([a0 compare:a1] == NSOrderedSame) {
        if ([a1 compare:a2] == NSOrderedSame) {
            [ma addObject:a];
        } else {
            NSArray *s = [NSArray arrayWithObjects:a0, a1, nil];
            [ma addObject:s];
            [ma addObject:a2];
        }
    } else if ([a1 compare:a2] == NSOrderedSame) {
        NSArray *s = [NSArray arrayWithObjects:a1, a2, nil];
        [ma addObject:a0];
        [ma addObject:s];
    } else {
        [ma setArray:a];
    }
    return ma;
}

- (void)addColorToTimeLineBeforeBb
{
    UIView *v0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bbBaseView.frame.size.width, self.bbBaseView.frame.size.height / 3)];
    v0.backgroundColor = self.box.sfGreen0;
    [self.bbBaseView addSubview:v0];
    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(0, self.bbBaseView.frame.size.height / 3, self.bbBaseView.frame.size.width, self.bbBaseView.frame.size.height / 3)];
    v1.backgroundColor = self.box.sfGreen1;
    [self.bbBaseView addSubview:v1];
    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.bbBaseView.frame.size.height * 2 / 3, self.bbBaseView.frame.size.width, self.bbBaseView.frame.size.height / 3)];
    v2.backgroundColor = self.box.sfGreen2;
    [self.bbBaseView addSubview:v2];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
