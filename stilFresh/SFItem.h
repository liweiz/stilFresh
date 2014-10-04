//
//  SFItem.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-10-02.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SFItem : NSManagedObject

@property (nonatomic, retain) NSDate * bestBefore;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSData * pic;
@property (nonatomic, retain) NSDate * timeAdded;
@property (nonatomic, retain) NSNumber * daysLeft;
@property (nonatomic, retain) NSNumber * freshness;


@end
