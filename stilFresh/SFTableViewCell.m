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
@synthesize textBackGroundColor;
@synthesize textBackGroundAlpha;
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
        self.textBackGroundColor = [UIColor clearColor];
        self.textBackGroundAlpha = 0.7f;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!self.itemId) {
            self.itemId = [[NSMutableString alloc] init];
        }
        if (!self.pic) {
            self.pic = [[UIImageView alloc] init];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // In editing mode, contentView's x is 38.0, while in normal mode, it is 0.0. This can be calculated with NSLogging contentView and backgroundView. contentView's width changes to 282.0 as well, while backgroundView's width does not change.
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
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
        self.deleteBase.userInteractionEnabled = YES;
        [self.deleteBase setContentOffset:CGPointZero animated:NO];
    }
    self.pic.backgroundColor = [UIColor clearColor];
    if (self.pic.image) {
        if (!self.isForCardView) {
            self.pic.frame = CGRectMake(0, 0, self.frame.size.width * self.box.goldenRatio / (self.box.goldenRatio + 1), self.frame.size.height);
            [self.contentView addSubview:self.pic];
        }
        self.pic.clipsToBounds = YES;
        self.pic.contentMode = UIViewContentModeScaleAspectFill;
        self.pic.alpha = 1;
        [self.pic.superview sendSubviewToBack:self.pic];
    } else if (!self.isForCardView) {
        self.pic.frame = CGRectMake(0, 0, 0, self.frame.size.height);
        [self.pic removeFromSuperview];
    }
    if (self.isForCardView) {
        CGFloat gap1 = 10;
        if (!self.bestBefore) {
            self.bestBefore = [[UILabel alloc] initWithFrame:CGRectMake(0, self.box.gapToEdge + 20, self.frame.size.width * self.box.goldenRatio / (self.box.goldenRatio + 1), 44)];
            self.bestBefore.backgroundColor = [UIColor clearColor];
            self.bestBefore.font = [UIFont systemFontOfSize:self.box.fontSizeM * 2];
            self.bestBefore.adjustsFontSizeToFitWidth = YES;
            self.bestBefore.textAlignment = NSTextAlignmentLeft;
            self.bestBefore.textColor = [UIColor whiteColor];
            [self.deleteBase addSubview:self.bestBefore];
        }
        if (!self.notes) {
            self.notes = [[UITextView alloc] initWithFrame:CGRectMake(self.bestBefore.frame.origin.x, self.bestBefore.frame.origin.y + self.bestBefore.frame.size.height + gap1 + 20, self.appRect.size.width - gap1 * 2, 80)];
            self.notes.backgroundColor = self.textBackGroundColor;
            self.notes.alpha = self.textBackGroundAlpha;
            self.notes.userInteractionEnabled = NO;
            self.notes.font = [UIFont systemFontOfSize:self.box.fontSizeM * 2];
            self.notes.textAlignment = NSTextAlignmentLeft;
            self.notes.textColor = [UIColor whiteColor];
            [self.deleteBase addSubview:self.notes];
        }
        if (!self.bottomLine) {
            CGFloat h1 = 2;
            self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - h1, self.frame.size.width, h1)];
            self.bottomLine.backgroundColor = [UIColor blackColor];
            [self.contentView addSubview:self.bottomLine];
        }
    } else {
        if (!self.text) {
            self.text = [[UILabel alloc] init];
            self.text.backgroundColor = [UIColor clearColor];
            self.text.textColor = [UIColor whiteColor];
            self.text.userInteractionEnabled = NO;
            self.text.font = [UIFont systemFontOfSize:self.box.fontSizeM * 2];
            self.text.minimumScaleFactor = 1;
            self.text.lineBreakMode = NSLineBreakByWordWrapping;
            self.text.numberOfLines = 5;
            [self.contentView addSubview:self.text];
        }
        self.text.backgroundColor = [UIColor clearColor];
        if (!self.number) {
            self.number = [[UILabel alloc] init];
            self.number.backgroundColor = [UIColor clearColor];
            self.number.textColor = [UIColor whiteColor];
            self.number.numberOfLines = 3;
            self.number.minimumScaleFactor = 1;
            self.number.font = [UIFont boldSystemFontOfSize:self.box.fontSizeL * 2];
            self.number.lineBreakMode = NSLineBreakByWordWrapping;
            [self.contentView addSubview:self.number];
        }
        
        if (self.pic.image) {
            self.text.frame = CGRectMake(self.pic.frame.origin.x + self.pic
                                         .frame.size.width, 0, self.contentView.frame.size.width - self.pic.frame.size.width, self.contentView.frame.size.height);
            self.text.textAlignment = NSTextAlignmentCenter;
            self.number.textAlignment = NSTextAlignmentCenter;
            self.number.frame = self.pic.frame;
        } else {
            self.text.frame = CGRectMake(self.pic.frame.origin.x + self.pic
                                         .frame.size.width, 0, self.contentView.frame.size.width * self.box.goldenRatio / (self.box.goldenRatio + 1), self.contentView.frame.size.height);
            self.text.textAlignment = NSTextAlignmentLeft;
            self.number.textAlignment = NSTextAlignmentRight;
            self.number.frame = CGRectMake(self.text.frame.origin.x + self.text.frame.size.width, 0, self.contentView.frame.size.width - self.text.frame.origin.x - self.text.frame.size.width, self.contentView.frame.size.height);
        }
        if (!self.bottomLine) {
            CGFloat h1 = 0.5;
            self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - h1, self.frame.size.width, h1)];
            self.bottomLine.backgroundColor = [UIColor whiteColor];
            [self.contentView addSubview:self.bottomLine];
        }
    }
    [self bringSubviewToFront:self.bottomLine];
    // Change color for freshness
    if (self.isForCardView) {
        UIView *a;
        if (!self.pic.image) {
            a = self.pic;
        }
        switch (self.statusCode) {
            case 0:
                a.backgroundColor = self.box.sfGreen0;
                break;
            case 1:
                a.backgroundColor = self.box.sfGreen1;
                break;
            case 2:
                a.backgroundColor = self.box.sfGreen2;
                break;
            case 3:
                a.backgroundColor = self.box.sfGray;
                break;
            default:
                a.backgroundColor = [UIColor clearColor];
                break;
        }
    } else {
        switch (self.statusCode) {
            case 0:
                self.contentView.backgroundColor = self.box.sfGreen0;
                break;
            case 1:
                self.contentView.backgroundColor = self.box.sfGreen1;
                break;
            case 2:
                self.contentView.backgroundColor = self.box.sfGreen2;
                break;
            case 3:
                self.contentView.backgroundColor = self.box.sfGray;
                break;
            default:
                self.contentView.backgroundColor = [UIColor clearColor];
                break;
        }
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
