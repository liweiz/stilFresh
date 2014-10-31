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

@property (assign, nonatomic) BOOL hintIsOn;
@property (assign, nonatomic) CGFloat goldenRatio;
@property (assign, nonatomic) CGRect appRect;
@property (assign, nonatomic) CGFloat fontSizeL;
@property (assign, nonatomic) CGFloat fontSizeM;
@property (assign, nonatomic) CGFloat gapToEdgeS;
@property (assign, nonatomic) CGFloat gapToEdgeM;
@property (assign, nonatomic) CGFloat gapToEdgeL;
@property (strong, nonatomic) UIFont *fontM;
@property (strong, nonatomic) UIFont *fontL;
// There are two dimensions of infomation to indicate an item's freshness. 1. number of days left 2. percentage since the day it is purchased. 2 may be more make sense to indicate the freshness, however, days left is a clearer indicator to let us know the specific data to take action on. So we'd better let users have both info to know not only the freshness but also the actual data to act on. My solution is provide 3 scales of green to indicate the freshness and gray for those no longer within bestbefore.
@property (strong, nonatomic) UIColor *placeholderFontColor;
@property (strong, nonatomic) UIColor *sfGreen0Highlighted;
@property (strong, nonatomic) UIColor *sfGreen0;
@property (strong, nonatomic) UIColor *sfGreen1;
@property (strong, nonatomic) UIColor *sfGreen2;
@property (strong, nonatomic) UIColor *sfGray;
@property (strong, nonatomic) NSManagedObjectContext *ctx;
@property (strong, nonatomic) NSFetchRequest *fReq;
@property (strong, nonatomic) NSFetchedResultsController *fResultsCtl;
@property (strong, nonatomic) NSMutableArray *sortSelection;
@property (strong, nonatomic) NSMutableString *warningText;
// When a new image is saving to local, the tableView may already start to update. This leads to no image for the cell that needs the image since the local image has not yet been successfully saved. So we store the image to this property for the cell to use. 
@property (strong, nonatomic) UIImage *imgJustSaved;
@property (strong, nonatomic) NSString *imgNameJustSaved;

- (void)prepareDataSource;
- (BOOL)saveToDb;
- (void)switchHint;

@end
