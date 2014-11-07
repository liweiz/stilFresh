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
        self.contentView.backgroundColor = [UIColor greenColor];
        if (!self.pic) {
            self.pic = [[UIImageView alloc] init];
            self.pic.backgroundColor = [UIColor yellowColor];
            self.pic.contentMode = UIViewContentModeScaleAspectFill;
            self.clipsToBounds = YES;
            [self.contentView addSubview:self.pic];
        }
        if (!self.text) {
            self.text = [[UILabel alloc] init];
            self.text.backgroundColor = [UIColor clearColor];
            self.text.font = [SFBox sharedBox].fontM;
            self.text.textAlignment = NSTextAlignmentLeft;
            self.text.lineBreakMode = NSLineBreakByWordWrapping;
            self.text.textColor = [UIColor whiteColor];
            self.text.numberOfLines = 3;
            [self.contentView addSubview:self.text];
        }
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
