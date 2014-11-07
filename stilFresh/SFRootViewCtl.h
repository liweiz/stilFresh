//
//  SFRootViewCtl.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFTableViewController.h"
#import "SFView.h"
#import "SFCamViewCtl.h"
#import "CHCSVParser.h"
#import "SFMenu.h"
#import "SFCollectionViewController.h"

@interface SFRootViewCtl : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) BOOL isForBestBefore;
@property (strong, nonatomic) UIScrollView *interfaceBase;

@property (strong, nonatomic) SFCamViewCtl *camViewCtl;

@property (strong, nonatomic) SFView *inputView;
@property (strong, nonatomic) NSDate *bestBeforeDate;
@property (strong, nonatomic) UILabel *bestBefore;
@property (strong, nonatomic) UITextView *notes;
@property (strong, nonatomic) UITextField *notesPlaceHolder;
@property (strong, nonatomic) UITextField *purchasedOn;
@property (strong, nonatomic) UIButton *addBtn;
@property (strong, nonatomic) UILabel *dateAddedLabel;
@property (strong, nonatomic) UISwitch *dateAddedSwitch;
@property (strong, nonatomic) NSDate *dateAddedDate;
@property (strong, nonatomic) UILabel *dateAdded;
@property (strong, nonatomic) UIView *cardViewBase;
@property (strong, nonatomic) SFCollectionViewController *listViewCtl;
@property (strong, nonatomic) SFTableViewController *cardViewCtl;

@property (strong, nonatomic) UIView *menuView;
@property (strong, nonatomic) UILabel *textCount;

@property (strong, nonatomic) UICollectionViewController *itemViewCtl;

@property (strong, nonatomic) SFMenu *menu;

@property (strong, nonatomic) UILabel *warning;
@property (strong, nonatomic) NSMutableSet *hintViews;

@end
