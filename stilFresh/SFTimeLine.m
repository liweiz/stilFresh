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
@synthesize gapX;
@synthesize gapY;
@synthesize border;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dateSequence = [NSMutableArray arrayWithCapacity:0];
        self.gapX = 0;
        self.gapY = 0;
        self.timeLineWidth = frame.size.width - 2;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)reset
{
    if (!self.border) {
        self.border = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - 2, 0, 2, self.frame.size.height)];
        CGFloat x;
        if ([self.box.sfGreen0 getRed:nil green:nil blue:nil alpha:&x]) {
            self.border.backgroundColor = [UIColor whiteColor];
            self.border.alpha = x;
        }
        [self addSubview:self.border];
    }
    for (UIView *x in self.subviews) {
        if (![x isEqual:self.border]) {
            [x removeFromSuperview];
        }
    }
    [self.dateSequence setArray:[self placeDatesInOrder]];
    [self addTimeLineBase];
    if (self.bbBaseView) {
        [self addColorToTimeLineBeforeBb];
    }
}


- (void)addTimeLineBase
{
    CGFloat h1 = [self getTimeLineHeightRatioBeforeBestBefore];
    CGFloat height = self.frame.size.height - self.gapY * 2;
    if (h1 == 0) {
        // Only timeLine after bestBefore needed.
        self.afterBbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY, self.timeLineWidth, height)];
        self.afterBbBaseView.backgroundColor = self.box.sfGray;
        [self addSubview:self.afterBbBaseView];
    } else if (h1 < 1) {
        CGFloat h2 = 1 - h1;
        self.bbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY, self.timeLineWidth, height * h1)];
        [self addSubview:self.bbBaseView];
        self.afterBbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY + self.bbBaseView.frame.size.height, self.timeLineWidth, height * h2)];
        self.afterBbBaseView.backgroundColor = self.box.sfGray;
        [self addSubview:self.afterBbBaseView];
    } else {
        // No timeLine after bestBefore needed.
        self.bbBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.gapX, self.gapY, self.timeLineWidth, height * h1)];
        [self addSubview:self.bbBaseView];
    }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
