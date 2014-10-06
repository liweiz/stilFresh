//
//  SFItem.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-06.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SFItem : NSManagedObject

@property (nonatomic, retain) NSDate * bestBefore;
@property (nonatomic, retain) NSNumber * daysLeft;
@property (nonatomic, retain) NSNumber * freshness;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * hasPic;
@property (nonatomic, retain) NSDate * timeAdded;

@end
