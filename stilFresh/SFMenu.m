//
//  SFMenu.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-10-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFMenu.h"
#import "SFBox.h"

@implementation SFMenu

- (instancetype)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self) {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 1;
        
        
    }
    return self;
}

- (void)setup
{
    CGFloat g = 40;
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(g, g, 90, 44)];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor grayColor];
    l.textAlignment = NSTextAlignmentLeft;
    l.adjustsFontSizeToFitWidth = YES;
    l.text = @"Show hints";
    [self addSubview:l];
    self.hintSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - g - 60, l.frame.origin.y, 60, l.frame.size.height + 16)];
    self.hintSwitch.on = [SFBox sharedBox].hintIsOn;
    [self.hintSwitch addTarget:self action:@selector(switchHint:) forControlEvents:UIControlEventValueChanged];
    self.hintSwitch.onTintColor = [SFBox sharedBox].sfGreen0;
    [self addSubview:self.hintSwitch];
}

// Switch hint
- (void)switchHint:(UISwitch *)sender
{
    [[SFBox sharedBox] switchHint];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
