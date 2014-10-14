//
//  SFCellCover.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-13.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFBox.h"
#import "SFTimeLine.h"

@interface SFCellCover : UIView

@property (strong, nonatomic) SFBox *box;
@property (strong, nonatomic) SFTimeLine *timeLine;
@property (strong, nonatomic) NSDate *dateAddedTL;
@property (strong, nonatomic) NSDate *bestBeforeTL;
@property (strong, nonatomic) NSDate *todayTL;


- (void)addContent;

@end
