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
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
        self.backgroundView.backgroundColor = [UIColor clearColor];
    }
    if (!self.pic) {
        self.pic = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height)];
    }
    if (self.pic.image) {
        [self.backgroundView addSubview:self.pic];
    } else {
        [self.pic removeFromSuperview];
    }
    if (!self.status) {
        self.status = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height)];
        [self.contentView addSubview:self.status];
        [self.contentView sendSubviewToBack:self.status];
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
            CGFloat h1 = 0.5f;
            self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.status.frame.size.height - h1, self.status.frame.size.width, h1)];
            self.bottomLine.backgroundColor = [UIColor whiteColor];
            [self.status addSubview:self.bottomLine];
        }
    } else {
        if (!self.notes) {
            self.notes = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, self.appRect.size.width - 20.0f, 80.0f)];
            self.notes.backgroundColor = self.textBackGroundColor;
            self.notes.alpha = self.textBackGroundAlpha;
            self.notes.userInteractionEnabled = NO;
            [self addSubview:self.notes];
        }
        if (!self.dateAdded) {
            self.dateAdded = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 100.0f, self.appRect.size.width - 20.0f, 44.0f)];
            [self setupTextField:self.dateAdded];
            [self.contentView addSubview:self.dateAdded];
        }
        if (!self.bestBefore) {
            self.bestBefore = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, self.dateAdded.frame.origin.y + self.dateAdded.frame.size.height + 10.0f, self.appRect.size.width - 20.0f, 44.0f)];
            [self setupTextField:self.bestBefore];
            [self.contentView addSubview:self.bestBefore];
        }
        
        if (!self.deleteBtn) {
            self.deleteBtn = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 44.0f) / 2, self.frame.size.height - 20.0f - 44.0f, 44.0f, 44.0f)];
            self.deleteBtn.backgroundColor = [UIColor redColor];
            self.deleteBtn.alpha = self.textBackGroundAlpha;
            [self.contentView addSubview:self.deleteBtn];
            self.deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callForDeletion)];
            [self.deleteBtn addGestureRecognizer:self.deleteTap];
        }
        if (!self.daysLeft) {
            self.daysLeft = [[UITextField alloc] initWithFrame:CGRectMake((self.frame.size.width - 70.0f) / 2, self.frame.size.height / 2, 70.0f, self.frame.size.height / 2 - self.deleteBtn.frame.size.height - 20.0f * 2)];
            [self setupTextField:self.daysLeft];
            [self.contentView addSubview:self.daysLeft];
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
    f.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    f.textAlignment = NSTextAlignmentCenter;
    f.textColor = [UIColor whiteColor];
    f.userInteractionEnabled = NO;
}

@end
