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
    SFSortDaysLeftMsgRankA,
    SFSortCellTextAlphabetA,
    SFSortCellTextAlphabetD,
    SFSortDaysLeftA,
    SFSortDaysLeftD,
    SFSortTimeCreatedA,
    SFSortTimeCreatedD,
    SFSortFreshnessA,
    SFSortFreshnessD
};

extern CGFloat const goldenRatio;
extern CGFloat const fontSizeM;
extern CGFloat const fontSizeL;
extern CGFloat const gapToEdgeS;
extern CGFloat const gapToEdgeM;
extern CGFloat const gapToEdgeL;
extern CGFloat const gapToEdgeXL;

@interface SFBox : NSObject <NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo>

@property (assign, nonatomic) BOOL hintIsOn;
@property (readonly, nonatomic) UIColor *darkText;
@property (readonly, nonatomic) UIColor *milkWhite;
@property (readonly, nonatomic) UIColor *placeholderFontColor;
@property (readonly, nonatomic) UIColor *sfGreen0Highlighted;
@property (readonly, nonatomic) UIColor *sfGreen0Lite;
// There are two dimensions of infomation to indicate an item's freshness. 1. number of days left 2. percentage since the day it is purchased. 2 may be more make sense to indicate the freshness, however, days left is a clearer indicator to let us know the specific data to take action on. So we'd better let users have both info to know not only the freshness but also the actual data to act on. My solution is provide 3 scales of green to indicate the freshness and gray for those no longer within bestbefore.
@property (readonly, nonatomic) UIColor *sfGreen0;
@property (readonly, nonatomic) UIColor *sfGreen1;
@property (readonly, nonatomic) UIColor *sfGreen2;
@property (readonly, nonatomic) UIColor *sfGray;
@property (readonly, nonatomic) UIColor *sfGrayLite;
@property (readonly, nonatomic) UIColor *sfBackWhite;
@property (readonly, nonatomic) UIFont *fontX;
@property (readonly, nonatomic) UIFont *fontY;
@property (readonly, nonatomic) UIFont *fontZ;
@property (readonly, nonatomic) UIFont *fontS;
@property (readonly, nonatomic) UIFont *fontM;
@property (readonly, nonatomic) UIFont *fontL;
@property (readonly, nonatomic) CGRect appRect;
@property (strong, nonatomic) NSManagedObjectContext *ctx;
@property (strong, nonatomic) NSFetchRequest *fReq;
@property (strong, nonatomic) NSFetchedResultsController *fResultsCtl;
@property (strong, nonatomic) NSMutableArray *sortSelection;
@property (strong, nonatomic) NSMutableString *warningText;
// When a new image is saving to local, the tableView may already start to update. This leads to no image for the cell that needs the image since the local image has not yet been successfully saved. So we store the image to this property for the cell to use. 
@property (strong, nonatomic) UIImage *imgJustSaved;
@property (copy, nonatomic) NSString *imgNameJustSaved;
@property (copy, nonatomic) NSDictionary *oldRowIndexPathPairs;

+ (instancetype)sharedBox;

- (void)prepareDataSource;
- (BOOL)saveToDb;
- (void)switchHint;
- (NSDictionary *)generateAllRowsIndexPathPairs;

@end
