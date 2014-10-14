//
//  SFTableViewController.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SFBox.h"



@interface SFTableViewController : UITableViewController

@property (strong, nonatomic) SFBox *box;
@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) BOOL isForCard;
@property (strong, nonatomic) NSMutableArray *zViews;

- (void)respondToChangeZViews:(NSInteger)rowNo;
- (void)resetZViews:(NSInteger)rowNo;
- (void)alphaChangeOnZViews:(CGFloat)scrollViewOffsetY cellHeight:(CGFloat)h;

@end
