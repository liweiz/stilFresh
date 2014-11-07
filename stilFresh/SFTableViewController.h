//
//  SFTableViewController.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



@interface SFTableViewController : UITableViewController <NSFetchedResultsSectionInfo>

@property (assign, nonatomic) BOOL isForCard;
@property (assign, nonatomic) BOOL isTransitingFromList;
@property (strong, nonatomic) NSMutableArray *zViews;
@property (strong, nonatomic) NSMutableArray *sections;
@property (strong, nonatomic) UIImageView *fakeDeleteBtn;

- (void)respondToChangeZViews:(NSInteger)rowNo;
- (void)refreshZViews;
- (void)resetZViews:(NSInteger)rowNo;
- (void)alphaChangeOnZViews:(CGFloat)scrollViewOffsetY cellHeight:(CGFloat)h;

- (void)getFakeDeleteBtn:(CGRect)frame;

@end
