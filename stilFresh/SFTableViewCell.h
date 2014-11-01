//
//  SFTableViewCell.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SFBox.h"
#import "SFTimeLine.h"

@interface SFTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (assign, nonatomic) BOOL isForCardView;
@property (assign, nonatomic) CGRect appRect;
@property (strong, nonatomic) SFBox *box;

// Shared view
@property (strong, nonatomic) UIImageView *pic;

// For list
@property (assign, nonatomic) NSInteger statusCode;
@property (strong, nonatomic) UIColor *statusColor;
@property (strong, nonatomic) UIView *bottomLine;
@property (strong, nonatomic) UILabel *number;
@property (strong, nonatomic) UILabel *text;
// For item detail
@property (strong, nonatomic) UILabel *notes;
@property (strong, nonatomic) UILabel *bestBefore;
@property (strong, nonatomic) UIView *deleteBtn;
@property (strong, nonatomic) UITapGestureRecognizer *deleteTap;
@property (strong, nonatomic) UIScrollView *deleteBase;
@property (strong, nonatomic) NSMutableString *itemId;

- (void)getViewsReady;
- (void)configWithImg:(BOOL)hasImg;

@end
