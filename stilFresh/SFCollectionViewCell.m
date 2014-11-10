//
//  SFCollectionViewCell.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-05.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFCollectionViewCell.h"
#import "SFBox.h"

@implementation SFCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!_pic) {
            _pic = [[UIImageView alloc] init];
            _pic.backgroundColor = [UIColor clearColor];
            _pic.contentMode = UIViewContentModeScaleAspectFill;
            _pic.clipsToBounds = YES;
            [self.contentView addSubview:_pic];
        }
        if (!_text) {
            _text = [[UILabel alloc] init];
            _text.backgroundColor = [UIColor clearColor];
            _text.font = [SFBox sharedBox].fontM;
            _text.textAlignment = NSTextAlignmentLeft;
            _text.lineBreakMode = NSLineBreakByWordWrapping;
            _text.textColor = [UIColor whiteColor];
            _text.numberOfLines = 3;
            [self.contentView addSubview:_text];
        }
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.contentView.layer.borderWidth = 1.5;
        [self setup];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
//    self.contentView.backgroundColor = [UIColor clearColor];
    [self setup];
    [self bringSubviewToFront:self.text];
    self.pic.image = nil;
    self.text.text = nil;
    self.text.attributedText = nil;
}

- (void)setup {
    self.pic.frame = CGRectMake(gapToEdgeS, gapToEdgeS, self.frame.size.width - gapToEdgeS * 2, self.frame.size.height - gapToEdgeS * 2);
    self.text.frame = self.pic.frame;
}

@end