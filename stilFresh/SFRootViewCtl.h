//
//  SFRootViewCtl.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFBox.h"
#import "SFTableViewController.h"
#import "SFView.h"
#import "SFCamViewCtl.h"
#import "CHCSVParser.h"

@interface SFRootViewCtl : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (assign, nonatomic) CGRect appRect;
@property (strong, nonatomic) SFBox *box;
@property (strong, nonatomic) UIScrollView *interfaceBase;

@property (strong, nonatomic) SFCamViewCtl *camViewCtl;

@property (strong, nonatomic) SFView *inputView;
@property (strong, nonatomic) UITextField *bestBefore;
@property (strong, nonatomic) UITextView *notes;
@property (strong, nonatomic) UITextField *notesPlaceHolder;
@property (strong, nonatomic) UITextField *purchasedOn;
@property (strong, nonatomic) UIView *addBtn;
@property (strong, nonatomic) UITapGestureRecognizer *addTap;
@property (strong, nonatomic) UILabel *dateAddedLabel;
@property (strong, nonatomic) UISwitch *dateAddedSwitch;
@property (strong, nonatomic) UITextField *dateAdded;
@property (strong, nonatomic) UIView *cardViewBase;

@property (strong, nonatomic) SFTableViewController *listViewCtl;
@property (strong, nonatomic) SFTableViewController *cardViewCtl;

@property (strong, nonatomic) UIView *menuView;

@property (strong, nonatomic) UICollectionViewController *itemViewCtl;

@property (strong, nonatomic) UILabel *warning;


@end
