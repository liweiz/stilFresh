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
        self.timeLine = [[SFTimeLine alloc] initWithFrame:CGRectMake(0, 0, 100, self.frame.size.height)];
        self.timeLine.box = self.box;
        [self addSubview:self.timeLine];
    }
    self.timeLine.dateAdded = self.dateAddedTL;
    self.timeLine.bestBefore = self.bestBeforeTL;
    self.timeLine.today = self.todayTL;
    [self.timeLine reset];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
