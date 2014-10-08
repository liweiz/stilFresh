//
//  SFTableViewCell.m
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFTableViewCell.h"
#import "SFRootViewCtl.h"
#import "UIImageView+Haneke.h"

@implementation SFTableViewCell

@synthesize pic;
@synthesize status;
@synthesize statusCode;
@synthesize isForCardView;
@synthesize appRect;
@synthesize textBackGroundColor;
@synthesize textBackGroundAlpha;
@synthesize notes;
@synthesize bestBefore;
@synthesize daysLeft;
@synthesize dateAdded;
@synthesize deleteBtn;
@synthesize deleteTap;
@synthesize itemId;
@synthesize box;
@synthesize bottomLine;
@synthesize number;
@synthesize text;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // In editing mode, contentView's x is 38.0, while in normal mode, it is 0.0. This can be calculated with NSLogging contentView and backgroundView. contentView's width changes to 282.0 as well, while backgroundView's width does not change.
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
    if (!self.pic) {
        self.pic = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.pic.clipsToBounds = YES;
        self.pic.contentMode = UIViewContentModeScaleAspectFill;
        self.pic.alpha = 0.75;
    }
    if (!self.status) {
        self.status = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        [self.contentView addSubview:self.status];
    }
    // Change color for freshness
    switch (self.statusCode) {
        case 0:
            self.status.backgroundColor = self.box.sfGreen0;
            break;
        case 1:
            self.status.backgroundColor = self.box.sfGreen1;
            break;
        case 2:
            self.status.backgroundColor = self.box.sfGreen2;
            break;
        case 3:
            self.status.backgroundColor = self.box.sfGray;
            break;
        default:
            self.status.backgroundColor = [UIColor clearColor];
            break;
    }
    if (!self.isForCardView) {
        if (!self.bottomLine) {
            CGFloat h1 = 0.5;
            self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.status.frame.size.height - h1, self.status.frame.size.width, h1)];
            self.bottomLine.backgroundColor = [UIColor whiteColor];
            [self.status addSubview:self.bottomLine];
        }
        if (!self.number) {
            CGFloat gap = 10;
            CGFloat w = 44;
            self.number = [[UILabel alloc] initWithFrame:CGRectMake(gap, gap, w, self.contentView.frame.size.height - gap * 2)];
            self.number.backgroundColor = [UIColor clearColor];
            self.number.textColor = [UIColor whiteColor];
            self.number.textAlignment = NSTextAlignmentRight;
            self.number.font = [UIFont boldSystemFontOfSize:self.box.fontSizeL * 2];
            self.number.lineBreakMode = NSLineBreakByCharWrapping;
            [self.status addSubview:self.number];
        }
        if (!self.text) {
            CGFloat gap = 10;
            self.text = [[UILabel alloc] initWithFrame:CGRectMake(self.number.frame.origin.x + self.number.frame.size.width + gap, gap, self.contentView.frame.size.width - gap * 3 - self.number.frame.size.width, self.number.frame.size.height)];
            self.text.backgroundColor = [UIColor clearColor];
            self.text.textColor = [UIColor whiteColor];
            self.text.textAlignment = NSTextAlignmentLeft;
            self.text.userInteractionEnabled = NO;
            self.text.font = [UIFont systemFontOfSize:self.box.fontSizeM * 2];
            self.text.lineBreakMode = NSLineBreakByCharWrapping;
            self.text.numberOfLines = 2;
            [self.status addSubview:self.text];
        }
    } else {
        CGFloat gap1 = 10;
        if (!self.notes) {
            self.notes = [[UITextView alloc] initWithFrame:CGRectMake(gap1, gap1, self.appRect.size.width - gap1 * 2, 80)];
            self.notes.backgroundColor = self.textBackGroundColor;
            self.notes.alpha = self.textBackGroundAlpha;
            self.notes.userInteractionEnabled = NO;
            self.notes.font = [UIFont systemFontOfSize:self.box.fontSizeM * 2];
            self.notes.textAlignment = NSTextAlignmentCenter;
            self.notes.textColor = [UIColor whiteColor];
            [self.status addSubview:self.notes];
        }
        if (!self.dateAdded) {
            self.dateAdded = [[UITextField alloc] initWithFrame:CGRectMake(self.notes.frame.origin.x, self.notes.frame.origin.y + self.notes.frame.size.height + gap1, self.notes.frame.size.width, 44)];
            [self setupTextField:self.dateAdded];
            
            [self.status addSubview:self.dateAdded];
        }
        if (!self.bestBefore) {
            self.bestBefore = [[UITextField alloc] initWithFrame:CGRectMake(gap1, self.dateAdded.frame.origin.y + self.dateAdded.frame.size.height + gap1, self.dateAdded.frame.size.width, self.dateAdded.frame.size.height)];
            [self setupTextField:self.bestBefore];
            [self.status addSubview:self.bestBefore];
        }
        
        if (!self.deleteBtn) {
            self.deleteBtn = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 44) / 2, self.frame.size.height - 20 - 44, 44, 44)];
            self.deleteBtn.backgroundColor = [UIColor redColor];
            self.deleteBtn.alpha = self.textBackGroundAlpha;
            [self.status addSubview:self.deleteBtn];
            self.deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callForDeletion)];
            [self.deleteBtn addGestureRecognizer:self.deleteTap];
        }
        if (!self.daysLeft) {
            
            self.daysLeft = [[UITextField alloc] initWithFrame:CGRectMake(self.bestBefore.frame.origin.x, self.frame.size.height / 2, self.bestBefore.frame.size.width, self.frame.size.height / 2 - self.deleteBtn.frame.size.height - 20 * 2)];
            [self setupTextField:self.daysLeft];
            self.daysLeft.font = [UIFont boldSystemFontOfSize:90];
            [self.status addSubview:self.daysLeft];
        }
    }
    if (self.pic.image) {
        [self.backgroundView addSubview:self.pic];
    } else {
        [self.pic removeFromSuperview];
    }
}

- (void)callForDeletion
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setValue:self.itemId forKey:@"itemId"];
    NSNotification *n = [[NSNotification alloc] initWithName:@"deleteItem" object:self userInfo:d];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)setupTextField:(UITextField *)f
{
    f.backgroundColor = [UIColor clearColor];
    f.font = [UIFont systemFontOfSize:34];
    f.textAlignment = NSTextAlignmentCenter;
    f.textColor = [UIColor whiteColor];
    f.userInteractionEnabled = NO;
}

@end
