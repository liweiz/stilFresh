//
//  SFCellCover.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-13.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFCellCover.h"

@implementation SFCellCover

@synthesize box;
@synthesize timeLine;
@synthesize dateAddedTL;
@synthesize bestBeforeTL;
@synthesize todayTL;
@synthesize daysLeftIndicator;
@synthesize stringDaysLeft;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)addContent
{
    if (!self.timeLine) {
        self.timeLine = [[SFTimeLineH alloc] initWithFrame:CGRectMake(0, self.frame.size.height - self.box.gapToEdge - 50, self.frame.size.width, 50)];
        self.timeLine.box = self.box;
        [self addSubview:self.timeLine];
    }
    self.timeLine.dateAdded = self.dateAddedTL;
    self.timeLine.bestBefore = self.bestBeforeTL;
    self.timeLine.today = self.todayTL;
    [self.timeLine reset];
    if (!self.daysLeftIndicator) {
        CGFloat gap1 = 15;
        CGFloat h1 = self.frame.size.height / (1 + self.box.goldenRatio) * self.box.goldenRatio;
        self.daysLeftIndicator = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - h1, self.frame.size.width, self.timeLine.frame.origin.y - gap1 - h1)];
        self.daysLeftIndicator.textAlignment = NSTextAlignmentCenter;
        self.daysLeftIndicator.backgroundColor = [UIColor clearColor];
        self.daysLeftIndicator.textColor = [UIColor whiteColor];
        self.daysLeftIndicator.font = [UIFont boldSystemFontOfSize:90];
        self.daysLeftIndicator.adjustsFontSizeToFitWidth = YES;
        self.daysLeftIndicator.minimumScaleFactor = 1;
        [self addSubview:self.daysLeftIndicator];
    }
    self.daysLeftIndicator.text = self.stringDaysLeft;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
