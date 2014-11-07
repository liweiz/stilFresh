//
//  SFCellCover.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-13.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFTimeLineH.h"

@interface SFCellCover : UIView

@property (strong, nonatomic) SFTimeLineH *timeLine;
@property (strong, nonatomic) NSDate *dateAddedTL;
@property (strong, nonatomic) NSDate *bestBeforeTL;
@property (strong, nonatomic) NSDate *todayTL;
@property (strong, nonatomic) UILabel *daysLeftIndicator;
@property (strong, nonatomic) NSString *stringDaysLeft;

- (void)addContent;

@end
