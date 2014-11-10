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
            _text = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            _text.backgroundColor = [UIColor clearColor];
            _text.textAlignment = NSTextAlignmentCenter;
            _text.lineBreakMode = NSLineBreakByWordWrapping;
            _text.textColor = [UIColor lightGrayColor];
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
    self.text.font = [SFBox sharedBox].fontM;
}

@end
