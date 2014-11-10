//
//  SFCollectionViewController.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-04.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface SFCollectionViewController : UICollectionViewController <NSFetchedResultsSectionInfo>

@property (strong, nonatomic) UIView *dynamicDaysLeftDisplayBase;

@end
