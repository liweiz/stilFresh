//
//  SFHeader.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-06.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFHeader.h"
#import "SFBox.h"

@implementation SFHeader


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        if (!self.text) {
            self.text = [[UILabel alloc] init];
            self.text.backgroundColor = [UIColor clearColor];
            
            self.text.textAlignment = NSTextAlignmentLeft;
            self.text.lineBreakMode = NSLineBreakByWordWrapping;
            self.text.textColor = [UIColor whiteColor];
            self.text.numberOfLines = 1;
            [self addSubview:self.text];
        }
        [self setup];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    //    self.contentView.backgroundColor = [UIColor clearColor];
    [self setup];
    self.text.text = nil;
    self.text.attributedText = nil;
}

- (void)setup {
    self.text.frame = self.frame;
    self.text.font = [SFBox sharedBox].fontM;
}

@end
