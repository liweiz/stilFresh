//
//  SFPopMsg.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-24.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SFPopMsg : NSObject

@property (nonatomic, strong) UIView *base;

@property (nonatomic, strong) UILabel *text;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *okBtn;

@end
