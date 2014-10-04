//
//  SFBox.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, SFSort) {
    SFSortCellTextAlphabetA,
    SFSortCellTextAlphabetD,
    SFSortDaysLeftA,
    SFSortDaysLeftD,
    SFSortTimeCreatedA,
    SFSortTimeCreatedD,
    SFSortFreshnessA,
    SFSortFreshnessD
};

@interface SFBox : NSObject <NSFetchedResultsControllerDelegate>

@property (assign, nonatomic) CGRect appRect;
@property (assign, nonatomic) CGFloat originX;
@property (assign, nonatomic) CGFloat originY;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat oneLineHeight;
@property (assign, nonatomic) CGFloat gap;
@property (assign, nonatomic) CGFloat fontSizeL;
@property (assign, nonatomic) CGFloat fontSizeM;
// There are two dimensions of infomation to indicate an item's freshness. 1. number of days left 2. percentage since the day it is purchased. 2 may be more make sense to indicate the freshness, however, days left is a clearer indicator to let us know the specific data to take action on. So we'd better let users have both info to know not only the freshness but also the actual data to act on. My solution is provide 3 scales of green to indicate the freshness and gray for those no longer within bestbefore.
@property (strong, nonatomic) UIColor *SFGreen0;
@property (strong, nonatomic) UIColor *SFGreen1;
@property (strong, nonatomic) UIColor *SFGreen2;
@property (strong, nonatomic) UIColor *SFGray;
@property (strong, nonatomic) NSManagedObjectContext *ctx;
@property (strong, nonatomic) NSFetchRequest *fReq;
@property (strong, nonatomic) NSFetchedResultsController *fResultsCtl;
@property (strong, nonatomic) NSMutableArray *sortSelection;
@property (strong, nonatomic) NSMutableString *warningText;

- (void)prepareDataSource;
- (BOOL)saveToDb;

@end
