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

@property (assign, nonatomic) BOOL isForCard;

@end
