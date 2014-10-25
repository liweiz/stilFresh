//
//  SFMenu.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFBox.h"

@interface SFMenu : UIScrollView

@property (strong, nonatomic) SFBox *box;
@property (strong, nonatomic) UISwitch *hintSwitch;

- (void)setup;

@end
