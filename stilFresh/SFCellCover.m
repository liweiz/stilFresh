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
        self.timeLine = [[SFTimeLineH alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 100)];
        self.timeLine.box = self.box;
        [self addSubview:self.timeLine];
    }
    self.timeLine.dateAdded = self.dateAddedTL;
    self.timeLine.bestBefore = self.bestBeforeTL;
    self.timeLine.today = self.todayTL;
    [self.timeLine reset];
    if (!self.daysLeftIndicator) {
        CGFloat gap1 = 15;
        CGFloat w1 = 150;
        CGFloat h1 = 90;
        self.daysLeftIndicator = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - gap1 - w1, self.frame.size.height - gap1 - h1, w1, h1)];
        self.daysLeftIndicator.textAlignment = NSTextAlignmentRight;
        self.daysLeftIndicator.backgroundColor = [UIColor clearColor];
        self.daysLeftIndicator.textColor = [UIColor whiteColor];
        self.daysLeftIndicator.font = [UIFont boldSystemFontOfSize:90];
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
