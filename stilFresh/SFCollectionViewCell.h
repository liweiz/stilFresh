//
//  SFCollectionViewCell.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-05.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *text;
@property (strong, nonatomic) UIImageView *pic;

@property (assign, nonatomic) NSInteger statusCode;
@property (strong, nonatomic) UIColor *statusColor;

@end
