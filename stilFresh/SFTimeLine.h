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
@property (strong, nonatomic) UIView *bbBaseView;
@property (strong, nonatomic) UIView *afterBbBaseView;
// This is the start axis point of the timeLine.
@property (assign, nonatomic) CGPoint axisPoint;
@property (assign, nonatomic) CGFloat timeLineHeight;
@property (assign, nonatomic) CGFloat timeLineWidth;
@property (assign, nonatomic) CGFloat singleLineHeight;
@property (assign, nonatomic) CGFloat labelWidth;
@property (strong, nonatomic) UILabel *bestBeforeL;
@property (strong, nonatomic) UILabel *bestBeforeIntro;
@property (strong, nonatomic) UILabel *dateAddedL;
@property (strong, nonatomic) UILabel *dateAddedIntro;
@property (strong, nonatomic) UILabel *todayL;
@property (strong, nonatomic) UILabel *todayIntro;
@property (assign, nonatomic) CGFloat radiusS;
@property (assign, nonatomic) CGFloat radiusL;

- (void)reset;

@end
