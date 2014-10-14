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
@synthesize singleLineHeight;
@synthesize labelWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dateSequence = [NSMutableArray arrayWithCapacity:0];
        self.axisPoint = CGPointMake(120, 30);
        self.timeLineHeight = self.frame.size.height - self.axisPoint.y * 2;
        self.timeLineWidth = 3;
        self.singleLineHeight = 30;
        self.labelWidth = 120;
        self.radiusS = 3;
        self.radiusL = 7;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)reset
{
    for (UIView *x in self.subviews) {
        [x removeFromSuperview];
    }
    [self addTimeLineBase];
    [self.dateSequence setArray:[self placeDatesInOrder]];
    [self addContentAtStartPoint:self.axisPoint height:self.timeLineHeight];
}

- (void)addTimeLineBase
{
    UIView *base = [[UIView alloc] initWithFrame:CGRectMake(self.axisPoint.x - self.timeLineWidth / 2, self.axisPoint.y, self.timeLineWidth, self.timeLineHeight)];
    [self addSubview:base];
    base.backgroundColor = [UIColor whiteColor];
}

// Use axis point
- (void)addContentAtStartPoint:(CGPoint)p height:(CGFloat)h
{
    NSArray *r = [self allLargePointsRatios];
    NSArray *pp = [self allLargePoints:r startPoint:p height:h];
    CGFloat g = 15;
    if ([self.dateSequence count] == 3) {
        NSInteger i = 0;
        for (NSDate *d in self.dateSequence) {
            NSString *s = [self contentMatch:d];
            [self addOneLargeDotSet:[(NSValue *)pp[i] CGPointValue] lines:1 gap:g text1:s text2:[self displayDateString:[self dateToString:d]]];
            i++;
        }
    } else if ([self.dateSequence count] == 2) {
        if ([self.dateSequence[0] isKindOfClass:[NSDate class]]) {
            // One line
            NSString *s = [self contentMatch:self.dateSequence[0]];
            [self addOneLargeDotSet:[pp[0] CGPointValue] lines:1 gap:g text1:s text2:[self dateToString:self.dateSequence[0]]];
            // Two line
            NSString *ss0 = [self contentMatch:self.dateSequence[1][0]];
            NSString *ss1 = [self contentMatch:self.dateSequence[1][1]];
            NSString *ss = [[ss0 stringByAppendingString:@"\n"] stringByAppendingString:ss1];
            [self addOneLargeDotSet:[pp[1] CGPointValue] lines:2 gap:g text1:ss text2:[self displayDateString:[self dateToString:self.dateSequence[1][0]]]];
        } else {
            // Two line
            NSString *ss0 = [self contentMatch:self.dateSequence[0][0]];
            NSString *ss1 = [self contentMatch:self.dateSequence[0][1]];
            NSString *ss = [[ss0 stringByAppendingString:@"\n"] stringByAppendingString:ss1];
            [self addOneLargeDotSet:[pp[0] CGPointValue] lines:2 gap:g text1:ss text2:[self displayDateString:[self dateToString:self.dateSequence[0][0]]]];
            // One line
            NSString *s = [self contentMatch:self.dateSequence[1]];
            [self addOneLargeDotSet:[pp[1] CGPointValue] lines:1 gap:g text1:s text2:[self displayDateString:[self dateToString:self.dateSequence[1]]]];
        }
    } else if ([self.dateSequence count] == 1) {
        // Three line
        NSString *ss0 = [self contentMatch:self.dateSequence[0][0]];
        NSString *ss1 = [self contentMatch:self.dateSequence[0][1]];
        NSString *ss2 = [self contentMatch:self.dateSequence[0][2]];
        NSString *ss = [[[[ss0 stringByAppendingString:@"\n"] stringByAppendingString:ss1] stringByAppendingString:@"\n"] stringByAppendingString:ss2];
        [self addOneLargeDotSet:[pp[0] CGPointValue] lines:3 gap:g text1:ss text2:[self displayDateString:[self dateToString:self.dateSequence[0][0]]]];
    }
}

- (NSString *)contentMatch:(NSDate *)d
{
    if ([d isEqual:self.dateAdded]) {
        return @"Purchased on";
    } else if ([d isEqual:self.bestBefore]) {
        return @"Best before";
    } else if ([d isEqual:self.today]) {
        return @"Today";
    }
    return nil;
}

// Use axis point
- (void)addOneLargeDotSet:(CGPoint)p lines:(NSInteger)n gap:(CGFloat)g text1:(NSString *)t1 text2:(NSString *)t2
{
    CGPoint a0 = [self getDotOriginX:p.x y:p.y width:self.radiusL * 2];
    UIView *d0 = [self createADot:self.radiusL * 2 at:a0];
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
    d1.text = t1;
    [self addSubview:d1];
    CGPoint a2 = [self getRightLabelOriginX:p.x y:p.y height:h gap:g];
    UILabel *d2 = [self createRightLabel:h at:a2];
    d2.text = t2;
    [self addSubview:d2];
}

- (void)addSmallDots:(NSArray *)a
{
    if ([a count] == 3) {
        CGPoint a00 = [(NSValue *)a[0] CGPointValue];
        CGPoint a0 = [self getDotOriginX:a00.x y:a00.y width:self.radiusS];
        UIView *d0 = [self createADot:self.radiusS at:a0];
        d0.backgroundColor = [UIColor whiteColor];
        [self addSubview:d0];
        CGPoint a01 = [(NSValue *)a[1] CGPointValue];
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
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentRight;
    return l;
}

- (UILabel *)createRightLabel:(CGFloat)height at:(CGPoint)origin
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y, self.labelWidth, height)];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
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
    CGFloat xx = x - w / 2;
    CGFloat yy = y - w / 2;
    return CGPointMake(xx, yy);
}



//// Today is not a fixed point.
//- (NSArray *)getFixedPointsOnBestBefore
//{
//    CGFloat ratio = [self getTimeLineHeightRatioBeforeBestBefore];
//    if (ratio != 0 && ratio != 1) {
//        NSValue *p1 = [NSValue valueWithCGPoint:CGPointMake(self.axisPoint.x, self.axisPoint.y + self.bbBaseView.frame.size.height / 3)];
//        NSValue *p2 = [NSValue valueWithCGPoint:CGPointMake(self.axisPoint.x, self.axisPoint.y + self.bbBaseView.frame.size.height * 2 / 3)];
//        NSValue *p3 = [NSValue valueWithCGPoint:CGPointMake(self.axisPoint.x, self.axisPoint.y + self.bbBaseView.frame.size.height)];
//        return [NSArray arrayWithObjects:p1, p2, p3, nil];
//    }
//    return nil;
//}

- (NSArray *)allLargePoints:(NSArray *)ratioArray startPoint:(CGPoint)p height:(CGFloat)h
{
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (NSNumber *n in ratioArray) {
        [a addObject:[NSValue valueWithCGPoint:CGPointMake(p.x, p.y + h * n.floatValue)]];
    }
    return a;
}

- (NSArray *)allLargePointsRatios
{
    if ([self.dateSequence count] == 3) {
        NSInteger base = [self getDaysLeftFrom:self.dateSequence[0] to:self.dateSequence[2]];
        NSInteger mid = [self getDaysLeftFrom:self.dateSequence[0] to:self.dateSequence[1]];
        CGFloat r = (CGFloat)mid / base;
        return [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:r], [NSNumber numberWithFloat:1], nil];
    } else if ([self.dateSequence count] == 2) {
        return [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:1], nil];
    } else {
        return [NSArray arrayWithObject:[NSNumber numberWithFloat:0]];
    }
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
