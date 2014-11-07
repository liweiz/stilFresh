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
        if (!_text) {
            _text = [[UILabel alloc] init];
            _text.backgroundColor = [UIColor clearColor];
            _text.textAlignment = NSTextAlignmentLeft;
            _text.lineBreakMode = NSLineBreakByWordWrapping;
            _text.textColor = [UIColor whiteColor];
            _text.numberOfLines = 1;
            [self addSubview:_text];
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
