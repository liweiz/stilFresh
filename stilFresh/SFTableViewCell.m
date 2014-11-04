//
//  SFTableViewCell.m
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFTableViewCell.h"
#import "SFRootViewCtl.h"

@implementation SFTableViewCell

@synthesize pic;
@synthesize statusColor;
@synthesize statusCode;
@synthesize isForCardView;
@synthesize appRect;
@synthesize notes;
@synthesize deleteBase;
@synthesize deleteBtn;
@synthesize deleteTap;
@synthesize itemId;
@synthesize box;
@synthesize bottomLine;
@synthesize number;
@synthesize text;
@synthesize bestBefore;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if ([reuseIdentifier isEqualToString:@"cell"]) {
            self.isForCardView = NO;
        } else {
            self.isForCardView = YES;
        }
        self.appRect = [(SFRootViewCtl *)[UIApplication sharedApplication].keyWindow.rootViewController appRect];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!self.itemId) {
            self.itemId = [[NSMutableString alloc] init];
        }
        if (!self.pic) {
            self.pic = [[UIImageView alloc] init];
            self.pic.backgroundColor = [UIColor clearColor];
            self.pic.contentMode = UIViewContentModeScaleAspectFill;
            self.clipsToBounds = YES;
        }
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)getViewsReady
{
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
    if (self.isForCardView) {
        if (!self.deleteBase) {
            self.deleteBase = [[UIScrollView alloc] initWithFrame:self.box.appRect];
            self.deleteBase.backgroundColor = [UIColor clearColor];
            self.deleteBase.contentSize = CGSizeMake(self.deleteBase.frame.size.width * 2, self.deleteBase.frame.size.height);
            self.deleteBase.pagingEnabled = YES;
            self.deleteBase.bounces = NO;
            self.deleteBase.showsHorizontalScrollIndicator = NO;
            self.deleteBase.showsVerticalScrollIndicator = NO;
            self.deleteBase.delegate = self;
            [self.contentView addSubview:self.deleteBase];
            self.pic.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            [self.deleteBase addSubview:self.pic];
        }
        if (!self.bestBefore) {
            self.bestBefore = [[UILabel alloc] init];
            self.bestBefore.font = self.box.fontL;
            self.bestBefore.textAlignment = NSTextAlignmentLeft;
            self.bestBefore.textColor = [UIColor whiteColor];
            self.bestBefore.numberOfLines = 0;
            [self.deleteBase addSubview:self.bestBefore];
        }
        if (!self.notes) {
            self.notes = [[UILabel alloc] init];
            self.notes.userInteractionEnabled = NO;
            self.notes.font = self.box.fontL;
            self.notes.numberOfLines = 0;
            self.notes.textAlignment = NSTextAlignmentLeft;
            self.notes.textColor = [UIColor whiteColor];
            [self.deleteBase addSubview:self.notes];
        }
    } else {
        if (!self.text) {
            self.text = [[UILabel alloc] init];
            self.text.backgroundColor = [UIColor clearColor];
            self.text.textColor = [UIColor whiteColor];
            self.text.userInteractionEnabled = NO;
            self.text.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:self.box.fontM.pointSize];
            self.text.minimumScaleFactor = 1;
            self.text.lineBreakMode = NSLineBreakByWordWrapping;
            self.text.textAlignment = NSTextAlignmentLeft;
            self.text.numberOfLines = 5;
            self.text.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            [self.contentView addSubview:self.text];
        }
//        if (!self.number) {
//            self.number = [[UILabel alloc] init];
//            self.number.backgroundColor = [UIColor clearColor];
//            self.number.textColor = [UIColor whiteColor];
//            self.number.numberOfLines = 3;
//            self.number.minimumScaleFactor = 1;
//            self.number.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.box.fontL.pointSize];
//            self.number.lineBreakMode = NSLineBreakByWordWrapping;
//            self.number.textAlignment = NSTextAlignmentLeft;
//            [self.contentView addSubview:self.number];
//        }
        if (!self.bottomLine) {
            // 0.5 here is to cover some extra space shown, we have not figured out the reason, but this can fix it anyway.
            self.bottomLine = [[UIView alloc] init];
            self.bottomLine.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:self.bottomLine];
        }
    }
}

- (void)configWithImg:(BOOL)hasImg {
    // In editing mode, contentView's x is 38.0, while in normal mode, it is 0.0. This can be calculated with NSLogging contentView and backgroundView. contentView's width changes to 282.0 as well, while backgroundView's width does not change.
    if (hasImg) {
        if (!self.isForCardView) {
//            CGFloat ww;
//            if (self.text.text.length == 0) {
//                // Not able to use goldenRatio here, greater than cell width
//                ww = self.frame.size.width * 0.95;
//            } else {
//                ww = self.frame.size.width * self.box.goldenRatio / (self.box.goldenRatio + 1);
//            }
            self.pic.frame = CGRectMake(self.box.gapToEdgeM, 0, self.frame.size.width - self.box.gapToEdgeM, self.frame.size.height);
            [self.contentView addSubview:self.pic];
        }
        [self.pic.superview sendSubviewToBack:self.pic];
    } else if (!self.isForCardView) {
        [self.pic removeFromSuperview];
    }
    if (self.isForCardView) {
        self.deleteBase.userInteractionEnabled = YES;
        [self.deleteBase setContentOffset:CGPointZero animated:NO];
        self.bestBefore.frame = CGRectMake(self.box.gapToEdgeL, self.box.gapToEdgeL + 20, self.frame.size.width - self.box.gapToEdgeL * 2, 44);
        [self.bestBefore sizeToFit];
        self.notes.frame = CGRectMake(self.bestBefore.frame.origin.x, self.bestBefore.frame.origin.y + self.bestBefore.frame.size.height + self.box.gapToEdgeL, self.frame.size.width - self.box.gapToEdgeL * 2, 200);
        [self.notes sizeToFit];
    } else {
        self.text.backgroundColor = [UIColor clearColor];
        if (hasImg) {
            self.text.frame = CGRectMake(self.pic.frame.origin.x + self.pic
                                         .frame.size.width / 3 * 2, 0, self.pic
                                         .frame.size.width / 3, self.contentView.frame.size.height);
//            self.text.numberOfLines = 0;
//            self.text.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
//            self.number.frame = CGRectMake(self.pic.frame.origin.x + self.box.gapToEdgeL, self.pic.frame.origin.y, self.pic.frame.size.width - self.box.gapToEdgeL * 2, self.pic.frame.size.height);
//            self.number.numberOfLines = 3;
//            self.number.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        } else {
//            CGFloat g = (self.contentView.frame.size.height - self.number.font.lineHeight - self.text.font.lineHeight) / 2.3;
//            CGFloat h1 = self.number.font.lineHeight + g * 2;
//            CGFloat h2 = self.text.font.lineHeight + g * 2;
//            self.number.frame = CGRectMake(self.box.gapToEdgeL, 0, self.contentView.frame.size.width - self.box.gapToEdgeL * 2, h1);
//            self.number.numberOfLines = 1;
//            self.number.baselineAdjustment = UIBaselineAdjustmentNone;
            self.text.frame = CGRectMake(self.box.gapToEdgeL, 0, self.pic
                                         .frame.size.width / 3, self.contentView.frame.size.height);
//            self.text.numberOfLines = 1;
//            self.text.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        }
    }
    CGFloat h1 = 1;
    self.bottomLine.frame = CGRectMake(0, self.contentView.frame.size.height - h1 + 0.5, self.frame.size.width, h1);
    [self bringSubviewToFront:self.bottomLine];
    // Change color for freshness
    UIColor *c;
    if (self.isForCardView) {
        switch (self.statusCode) {
            case 0:
                c = self.box.sfGreen0;
                break;
            case 1:
                c = self.box.sfGreen1;
                break;
            case 2:
                c = self.box.sfGreen2;
                break;
            case 3:
                c = self.box.sfGray;
                break;
            default:
                c = [UIColor clearColor];
                break;
        }
        if (!hasImg) {
            self.pic.backgroundColor = c;
        } else {
            self.pic.backgroundColor = [UIColor clearColor];
        }
        self.bestBefore.backgroundColor = c;
        self.notes.backgroundColor = c;
    } else {
        switch (self.statusCode) {
            case 0:
                c = self.box.sfGreen0;
                break;
            case 1:
                c = self.box.sfGreen1;
                break;
            case 2:
                c = self.box.sfGreen2;
                break;
            case 3:
                c = self.box.sfGray;
                break;
            default:
                c = [UIColor clearColor];
                break;
        }
        self.contentView.backgroundColor = c;
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.deleteBase.alpha = 1 - scrollView.contentOffset.x / self.deleteBase.frame.size.width;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Delete is triggered only when more than 1/2 of width has been covered.
    if (scrollView.contentOffset.x > self.deleteBase.frame.size.width / 2) {
        if (targetContentOffset->x == scrollView.frame.size.width) {
            scrollView.userInteractionEnabled = NO;
            [self callForDeletion];
        }
    } else {
        // Prevent from unintended swipe. E.g. when scroll up the tableView, the swipe may be triggered. So user has to swipe harder to get through.
        targetContentOffset->x = 0;
    }
}

- (void)callForDeletion
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setValue:self.itemId forKey:@"itemId"];
    NSNotification *n = [[NSNotification alloc] initWithName:@"deleteItem" object:self userInfo:d];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

@end
