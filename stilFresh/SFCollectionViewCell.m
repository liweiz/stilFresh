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
        CGSize s = CGSizeMake(15, 15);
        if (!_upperMask) {
            _upperMask = [CAShapeLayer layer];
            _upperMask.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight cornerRadii:s].CGPath;
        }
        if (!_lowerMask) {
            _lowerMask = [CAShapeLayer layer];
            _lowerMask.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:s].CGPath;
        }
        if (!_bothMask) {
            _bothMask = [CAShapeLayer layer];
            _bothMask.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:s].CGPath;
        }
        if (!self.backgroundView) {
            self.backgroundView = [[UIView alloc] init];
            self.backgroundView.alpha = 1;
            self.backgroundView.backgroundColor = [SFBox sharedBox].milkWhite;
        }
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
            _text.font = [SFBox sharedBox].fontY;
            _text.textAlignment = NSTextAlignmentLeft;
            _text.lineBreakMode = NSLineBreakByWordWrapping;
            _text.textColor = [UIColor whiteColor];
            _text.numberOfLines = 2;
            [self.contentView addSubview:_text];
        }
        self.contentView.backgroundColor = [UIColor clearColor]; // [self getStatusColor:cell.statusCode];
        [self setup];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setup];
    [self bringSubviewToFront:self.text];
    self.pic.image = nil;
    self.text.text = nil;
    self.text.attributedText = nil;
}

- (void)setup {
    self.layer.mask = nil;
    self.pic.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.text.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
