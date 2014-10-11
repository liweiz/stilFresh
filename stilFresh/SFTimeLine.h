//
//  SFTimeLine.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-10.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFBox.h"

@interface SFTimeLine : UIView

@property (strong, nonatomic) SFBox *box;
@property (strong, nonatomic) NSDate *dateAdded;
@property (strong, nonatomic) NSDate *bestBefore;
@property (strong, nonatomic) NSDate *today;
// Store dates from ealier to later. If multiple dates are the same, store them in an array and then store here. DO NOT USE NSSET, it only keeps the unique obj. If the same object appears more than once in array, it is represented only once in the returned set. Something strange when I stored two NSDate for the same time. Let's use array to avoid this.
@property (strong, nonatomic) NSMutableArray *dateSequence;
@property (strong, nonatomic) UIView *border;
@property (strong, nonatomic) UIView *bbBaseView;
@property (strong, nonatomic) UIView *afterBbBaseView;
@property (assign, nonatomic) CGFloat gapX;
@property (assign, nonatomic) CGFloat gapY;
@property (assign, nonatomic) CGFloat timeLineWidth;

- (void)reset;

@end
