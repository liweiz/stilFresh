//
//  SFRootViewCtl.m
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFRootViewCtl.h"
#import "SFItem.h"
#import "NSObject+SFExtra.h"
#import "SFHintView.h"
#import "SFHintBase.h"
#import "SFBox.h"


@interface SFRootViewCtl ()

@end

@implementation SFRootViewCtl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
    self.view = [[UIView alloc] initWithFrame:[SFBox sharedBox].appRect];
    self.view.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interfaceBase = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [SFBox sharedBox].appRect.size.width + gapToEdgeS, [SFBox sharedBox].appRect.size.height)];
    // Four views, from left to right: 1. cam 2. input 3. list 4. menu/card 5. swipe-to-left-to-delete
    CGSize theContentSize = CGSizeMake(([SFBox sharedBox].appRect.size.width + gapToEdgeS) * 4 , [SFBox sharedBox].appRect.size.height);
    self.interfaceBase.contentSize = theContentSize;
    self.interfaceBase.contentOffset = CGPointMake(([SFBox sharedBox].appRect.size.width + gapToEdgeS) * 2, 0);
    self.interfaceBase.bounces = NO;
    self.interfaceBase.showsVerticalScrollIndicator = NO;
    self.interfaceBase.showsHorizontalScrollIndicator = NO;
    self.interfaceBase.pagingEnabled = YES;
    self.interfaceBase.backgroundColor = [UIColor clearColor];
    self.interfaceBase.delegate = self;
    [self.view addSubview:self.interfaceBase];
    
    self.camViewCtl = [[SFCamViewCtl alloc] init];
    [self addChildViewController:self.camViewCtl];
    [self.interfaceBase addSubview:self.camViewCtl.view];
    [self.camViewCtl didMoveToParentViewController:self];
    
    UIColor *gapColor = [UIColor blackColor];
    // add black gap
    UIView *g0 = [[UIView alloc] initWithFrame:CGRectMake(self.camViewCtl.view.frame.size.width, 0, gapToEdgeS, [SFBox sharedBox].appRect.size.height)];
    g0.backgroundColor = gapColor;
    [self.interfaceBase addSubview:g0];
    
    // InputView
    self.inputView = [[SFView alloc] initWithFrame:CGRectMake([SFBox sharedBox].appRect.size.width + gapToEdgeS, 0, [SFBox sharedBox].appRect.size.width, [SFBox sharedBox].appRect.size.height)];
    self.inputView.touchToDismissKeyboardIsOn = YES;
    self.inputView.touchToDismissViewIsOn = YES;
    self.inputView.backgroundColor = [UIColor clearColor];
    [self.interfaceBase addSubview:self.inputView];
    // add black gap
    UIView *g1 = [[UIView alloc] initWithFrame:CGRectMake(self.inputView.frame.origin.x + self.inputView.frame.size.width, 0, gapToEdgeS, [SFBox sharedBox].appRect.size.height)];
    g1.backgroundColor = gapColor;
    [self.interfaceBase addSubview:g1];
    // BestBefore
    self.bestBefore = [[UILabel alloc] initWithFrame:CGRectMake(gapToEdgeL, gapToEdgeL + 20, [SFBox sharedBox].appRect.size.width - gapToEdgeL * 2 - gapToEdgeS - 54, 44)];
    UITapGestureRecognizer *bbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBestBefore)];
    [self.bestBefore addGestureRecognizer:bbTap];
    self.bestBefore.userInteractionEnabled = YES;
    [self checkPlaceHolder];
    self.bestBefore.backgroundColor = [UIColor clearColor];
    
    self.bestBefore.font = [SFBox sharedBox].fontM;
    [self configLayer:self.bestBefore.layer box:[SFBox sharedBox] isClear:YES];
    [self.inputView addSubview:self.bestBefore];
    // AddBtn
    self.addBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.addBtn.frame = CGRectMake(self.bestBefore.frame.origin.x + self.bestBefore.frame.size.width + gapToEdgeS, self.bestBefore.frame.origin.y, 54, self.bestBefore.frame.size.height);
    NSMutableAttributedString *btnString = [[NSMutableAttributedString alloc] initWithString:@"Done"];
    [btnString addAttribute:NSFontAttributeName value:[SFBox sharedBox].fontX range:NSMakeRange(0, btnString.length)];
    [btnString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, btnString.length)];
    [self.addBtn setAttributedTitle:btnString forState:UIControlStateNormal];
    [self.addBtn setAttributedTitle:btnString forState:UIControlStateHighlighted];
    [self.addBtn setAttributedTitle:btnString forState:UIControlStateSelected];
    self.addBtn.showsTouchWhenHighlighted = YES;
    [self configLayer:self.addBtn.layer box:[SFBox sharedBox] isClear:NO];
    self.addBtn.backgroundColor = [SFBox sharedBox].sfGreen0;
    [self.addBtn addTarget:self action:@selector(saveItem) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView addSubview:self.addBtn];
    // Notes, UIKeyboard w/ bar height: 264, UIKeyboard alone: 216
    self.notes = [[UITextView alloc] initWithFrame:CGRectMake(self.bestBefore.frame.origin.x, self.bestBefore.frame.origin.y + self.bestBefore.frame.size.height + gapToEdgeS, [SFBox sharedBox].appRect.size.width - gapToEdgeL * 2, [SFBox sharedBox].appRect.size.height - 264 - (self.bestBefore.frame.origin.y + self.bestBefore.frame.size.height + gapToEdgeS) - gapToEdgeS - self.bestBefore.frame.size.height)];
    self.notes.backgroundColor = [UIColor clearColor];
    self.notes.delegate = self;
    self.notes.font = self.bestBefore.font;
    self.notes.text = @"";
    [self.inputView addSubview:self.notes];
    UIView *fakeNotes = [[UIView alloc] initWithFrame:self.notes.frame];
    fakeNotes.backgroundColor = [UIColor clearColor];
    [self configLayer:fakeNotes.layer box:[SFBox sharedBox] isClear:YES];
    [self.inputView insertSubview:fakeNotes belowSubview:self.notes];
    self.notesPlaceHolder = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.notes.frame.size.width, [SFBox sharedBox].fontM.lineHeight)];
    self.notesPlaceHolder.backgroundColor = [UIColor clearColor];
    self.notesPlaceHolder.placeholder = @"Info for this item";
    self.notesPlaceHolder.userInteractionEnabled = NO;
    self.notesPlaceHolder.font = self.bestBefore.font;
    [self.notes addSubview:self.notesPlaceHolder];
    CGFloat th = 44;
    CGFloat tw = 100;
    self.textCount = [[UILabel alloc] initWithFrame:CGRectMake(self.notes.frame.size.width - tw, self.notes.frame.size.height - (th - self.notes.font.lineHeight) / 2 - self.notes.font.lineHeight - 2, tw, th)];
    self.textCount.backgroundColor = [UIColor clearColor];
    self.textCount.textColor = [UIColor lightGrayColor];
    self.textCount.font = self.notes.font;
    self.textCount.textAlignment = NSTextAlignmentRight;
    [fakeNotes addSubview:self.textCount];
    // DayAdded
    self.dateAddedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.notes.frame.origin.x, self.notes.frame.origin.y + self.notes.frame.size.height + gapToEdgeS, self.bestBefore.frame.size.width, self.bestBefore.frame.size.height)];
    [self configLayer:self.dateAddedLabel.layer box:[SFBox sharedBox] isClear:NO];
    self.dateAddedLabel.text = @"Purchased today";
    self.dateAddedLabel.font = self.bestBefore.font;
    [self.inputView addSubview:self.dateAddedLabel];
    self.dateAddedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.addBtn.frame.origin.x, self.dateAddedLabel.frame.origin.y + 7, self.addBtn.frame.size.width, self.addBtn.frame.size.height)];
    self.dateAddedSwitch.on = YES;
    
    [self.dateAddedSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.inputView addSubview:self.dateAddedSwitch];
    self.dateAddedSwitch.onTintColor = [SFBox sharedBox].sfGreen0;
    self.dateAdded = [[UILabel alloc] initWithFrame:CGRectMake(self.notes.frame.origin.x, gapToEdgeS + self.notes.frame.origin.y + self.notes.frame.size.height, self.bestBefore.frame.size.width, self.bestBefore.frame.size.height)];
    UITapGestureRecognizer *daTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDateAdded)];
    [self.dateAdded addGestureRecognizer:daTap];
    self.dateAdded.userInteractionEnabled = YES;
    [self configLayer:self.dateAdded.layer box:[SFBox sharedBox] isClear:YES];
    self.dateAdded.backgroundColor = [UIColor clearColor];

    self.dateAdded.font = self.bestBefore.font;
    [self.inputView addSubview:self.dateAdded];
    self.dateAdded.hidden = YES;
    
    [[SFBox sharedBox] prepareDataSource];
    
    // ListViewCtl
    self.listViewBase = [[UIView alloc] initWithFrame:CGRectMake(([SFBox sharedBox].appRect.size.width + gapToEdgeS) * 2, 0, [SFBox sharedBox].appRect.size.width, [SFBox sharedBox].appRect.size.height)];
    self.listViewBase.backgroundColor = [UIColor clearColor];
    [self.interfaceBase addSubview:self.listViewBase];
    self.listViewCtl = [[SFCollectionViewController alloc] initWithCollectionViewLayout:[self getLayout]];
    [self addChildViewController:self.listViewCtl];
    [self.listViewBase addSubview:self.listViewCtl.collectionView];
    [self.listViewCtl didMoveToParentViewController:self];
    
    // add black gap
    UIView *g2 = [[UIView alloc] initWithFrame:CGRectMake(self.listViewBase.frame.origin.x + self.listViewBase.frame.size.width, 0, gapToEdgeS, [SFBox sharedBox].appRect.size.height)];
    g2.backgroundColor = [UIColor blackColor];
    [self.interfaceBase addSubview:g2];
    // CardViewCtl
    self.cardViewBase = [[UIView alloc] initWithFrame:CGRectMake(([SFBox sharedBox].appRect.size.width + gapToEdgeS) * 3, 0, [SFBox sharedBox].appRect.size.width, [SFBox sharedBox].appRect.size.height)];
    self.cardViewBase.backgroundColor = [UIColor clearColor];
    [self.interfaceBase addSubview:self.cardViewBase];
    self.cardViewCtl = [[SFTableViewController alloc] init];
    self.cardViewCtl.isForCard = YES;
    [self addChildViewController:self.cardViewCtl];
    [self.cardViewBase addSubview:self.cardViewCtl.tableView];
    [self.cardViewCtl didMoveToParentViewController:self];
    self.cardViewBase.hidden = YES;
    // add black gap
    UIView *g3 = [[UIView alloc] initWithFrame:CGRectMake(self.cardViewBase.frame.origin.x + self.cardViewBase.frame.size.width, 0, gapToEdgeS, [SFBox sharedBox].appRect.size.height)];
    g3.backgroundColor = [UIColor blackColor];
    [self.interfaceBase addSubview:g3];
    
    // Menu
    self.menu = [[SFMenu alloc] initWithFrame:self.cardViewBase.frame];
    [self.menu setup];
    [self.interfaceBase addSubview:self.menu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCard) name:@"rowSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataForTables) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarning:) name:@"generalError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTableChange) name:@"startTableChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runTableChange:) name:@"runTableChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endTableChange) name:@"endTableChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionViewChanges:) name:@"collectionViewChanges" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name:@"deleteItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDatePicker) name:@"dismiss" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPicDisposeHint) name:@"showPicDisposeHint" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOffHint) name:@"turnOffHint" object:nil];
    
    // Create a CSV file in NSLibraryDirectory to store all the deleted items' itemIds to locate and delete their corresponding image files.
    [self setupCSVForDeletedItem];
    
    if ([SFBox sharedBox].hintIsOn) {
        [self processHints:[NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    }
}

- (void)turnOffHint
{
    [[SFBox sharedBox] switchHint];
    self.menu.hintSwitch.on = NO;
}

- (void)switchMenuToCard
{
    self.menu.hidden = YES;
    self.cardViewBase.hidden = NO;
}

#pragma mark - hightlight input
// To know which to hightlight, we get that from the tap selection action.
// To know which to dehighlight, we get that from state change of input pad(keyboard/datePicker)
- (void)hightlightView:(UIView *)v
{
    v.backgroundColor = [SFBox sharedBox].sfGreen0Highlighted;
    NSSet *s = [NSSet setWithObjects:self.bestBefore, self.notes, self.dateAdded, nil];
    for (UIView *u in s) {
        // Clear rest views to non-highlighted.
        if (![u isEqual:v]) {
            u.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)dehighlightAllView
{
    NSSet *s = [NSSet setWithObjects:self.bestBefore, self.notes, self.dateAdded, nil];
    for (UIView *u in s) {
        u.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - tap on date input
// Start to edit bestBefore
- (void)tapOnBestBefore
{
    if ([self.bestBefore.text isEqualToString:@"Best before"]) {
        NSDateComponents *c = [[NSDateComponents alloc] init];
        c.day = 5;
        NSDate *dayAfter5 = [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:[NSDate date] options:0];
        
        self.bestBeforeDate = dayAfter5;
        self.bestBefore.textColor = [UIColor blackColor];
    }
    [self hightlightView:self.bestBefore];
    [self showDatePicker:self.bestBefore date:self.bestBeforeDate];
}

// Start to edit dateAdded
- (void)changeSwitch:(UISwitch *)sender
{
    if(sender.on){
        self.dateAdded.hidden = YES;
        self.dateAddedLabel.hidden = NO;
        [self hideDatePicker];
    } else{
        self.dateAdded.hidden = NO;
        self.dateAddedLabel.hidden = YES;
        NSDateComponents *c = [[NSDateComponents alloc] init];
        c.day = -5;
        NSDate *dayBefore5 = [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:[NSDate date] options:0];
        self.dateAddedDate = dayBefore5;
        [self tapOnDateAdded];
    }
}

- (void)tapOnDateAdded
{
    [self hightlightView:self.dateAdded];
    [self showDatePicker:self.dateAdded date:self.dateAddedDate];
}

- (void)checkPlaceHolder
{
    if (self.bestBefore.text.length == 0) {
        self.bestBefore.text = @"Best before";
        self.bestBefore.textColor = [SFBox sharedBox].placeholderFontColor;
    } else {
        self.bestBefore.textColor = [UIColor blackColor];
    }
}

- (void)resetInput
{
    self.bestBefore.text = nil;
    [self checkPlaceHolder];
    self.bestBeforeDate = nil;
    self.notes.text = @"";
    self.dateAddedSwitch.on = YES;
    [self changeSwitch:self.dateAddedSwitch];
}

#pragma mark - datePicker
- (void)showDatePicker:(UILabel *)l date:(NSDate *)d
{
    UIScrollView *base = (UIScrollView *)[self.interfaceBase viewWithTag:999];
    if (!base) {
        // http://stackoverflow.com/questions/18970679/ios-7-uidatepicker-height-inconsistency
        CGFloat h = 216;
        base = [[UIScrollView alloc] initWithFrame:CGRectMake(self.inputView.frame.origin.x, [SFBox sharedBox].appRect.size.height - h, [SFBox sharedBox].appRect.size.width, h)];
        base.tag = 999;
        base.backgroundColor = [UIColor clearColor];
        base.contentSize = CGSizeMake(base.frame.size.width, base.frame.size.height * 2);
        base.userInteractionEnabled = YES;
        base.delegate = self;
        UIDatePicker *p = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, base.frame.size.height, base.frame.size.width, base.frame.size.height)];
        p.tag = 998;
        [p addTarget:self action:@selector(dateUpdated:) forControlEvents:UIControlEventValueChanged];
        p.datePickerMode = UIDatePickerModeDate;
        [base addSubview:p];
        [self.interfaceBase addSubview:base];
    } else {// This happens when existing datePicker is scrolling back, but new request comes in to demand a datePicker.
    }
    [base setContentOffset:CGPointMake(0, base.frame.size.height) animated:YES];
    if ([l isEqual:self.bestBefore]) {
        self.isForBestBefore = YES;
    } else if ([l isEqual:self.dateAdded]) {
        self.isForBestBefore = NO;
    }
    UIDatePicker *x = (UIDatePicker *)[self.interfaceBase viewWithTag:998];
    if ([x isKindOfClass:[UIDatePicker class]]) {
        [x setDate:d animated:YES];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, YYYY"];
    l.text = [formatter stringFromDate:d];
}

- (void)dateUpdated:(UIDatePicker *)datePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, YYYY"];
    if (self.isForBestBefore) {
        self.bestBefore.text = [formatter stringFromDate:datePicker.date];
        self.bestBeforeDate = datePicker.date;
    } else {
        self.dateAdded.text = [formatter stringFromDate:datePicker.date];
        self.dateAddedDate = datePicker.date;
    }
}

- (void)hideDatePicker
{
    UIScrollView *v = (UIScrollView *)[self.interfaceBase viewWithTag:999];
    if (v) {
        [v setContentOffset:CGPointZero animated:YES];
        [self dehighlightAllView];
    }
}

- (void)reloadDataForTables
{
    [self.listViewCtl.collectionView reloadData];
    [self.cardViewCtl.tableView reloadData];
    [SFBox sharedBox].oldRowIndexPathPairs = nil;
    [SFBox sharedBox].oldRowIndexPathPairs = [[SFBox sharedBox] generateAllRowsIndexPathPairs];
}

- (void)showCard
{
    self.cardViewCtl.isTransitingFromList = YES;
    SFItem *i = [[SFBox sharedBox].fResultsCtl objectAtIndexPath:self.listViewCtl.collectionView.indexPathsForSelectedItems[0]];
    if (i) {
        NSIndexPath *p = [NSIndexPath indexPathForRow:[[SFBox sharedBox].fResultsCtl.fetchedObjects indexOfObject:i] inSection:0];
        [self.cardViewCtl.tableView scrollToRowAtIndexPath:p atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.cardViewCtl.isTransitingFromList = NO;
        self.cardViewCtl.tableView.hidden = NO;
        [self.cardViewCtl.tableView.superview sendSubviewToBack:self.cardViewCtl.tableView];
        [self.cardViewCtl refreshZViews];
        [self.cardViewCtl resetZViews:p.row];
        [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 3 / 4, 0) animated:YES];
        [self switchMenuToCard];
    }
}

#pragma mark <UITextViewDelegate>

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.notes]) {
        if (!self.notesPlaceHolder.hidden) {
            self.notesPlaceHolder.hidden = YES;
        }
        if (self.textCount.hidden) {
            self.textCount.hidden = NO;
        }
        [self hightlightView:textView];
        [self showCountTextResult];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView isEqual:self.notes]) {
        [self showCountTextResult];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView isEqual:self.notes]) {
        if (self.notes.text.length == 0) {
            self.notesPlaceHolder.hidden = NO;
        }
        if (!self.textCount.hidden) {
            self.textCount.hidden = YES;
        }
        [self dehighlightAllView];
    }
}

- (void)showCountTextResult
{
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:self.notes.text];
    if (self.notes.text.length > 70) {
        [s addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(70, self.notes.text.length - 70)];
        [s addAttribute:NSFontAttributeName value:self.notes.font range:NSMakeRange(0, self.notes.text.length)];
        self.notes.attributedText = s;
        self.textCount.textColor = [UIColor grayColor];
        self.textCount.font = [self boldFontWithFont:self.notes.font];
    } else {
        self.textCount.textColor = [UIColor lightGrayColor];
        self.textCount.font = self.notes.font;
    }
    self.textCount.text = [NSString stringWithFormat:@"%ld/70", (unsigned long)self.notes.text.length];
}

// http://stackoverflow.com/questions/18862868/setting-bold-font-on-ios-uilabel
- (UIFont *)boldFontWithFont:(UIFont *)font
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

#pragma mark - warning display

- (void)showWarning:(NSNotification *)note
{
    [self showWarningWithName:note.name];
}

- (void)showWarningWithName:(NSString *)notificationName
{
    // Clear the item inserted but not saved yet
    for (SFItem *i in [SFBox sharedBox].ctx.insertedObjects) {
        [[SFBox sharedBox].ctx deleteObject:i];
    }
    if (!self.warning) {
        self.warning = [[UILabel alloc] init];
        [self.view addSubview:self.warning];
        self.warning.font = self.bestBefore.font;
        self.warning.textColor = [UIColor whiteColor];
        self.warning.textAlignment = NSTextAlignmentCenter;
        self.warning.lineBreakMode = NSLineBreakByWordWrapping;
        self.warning.numberOfLines = 0;
        self.warning.backgroundColor = [SFBox sharedBox].sfGray;
    }
    CGFloat w = 220;
    CGFloat h = 120;
    self.warning.frame = CGRectMake((self.view.frame.size.width - w) * 0.5, (self.view.frame.size.height - h) * 0.5 - 30, w, h);
    if ([notificationName isEqualToString:@"generalError"]) {
        self.warning.text = @"Something went wrong, please try later.";
    } else {
        self.warning.text = [SFBox sharedBox].warningText;
    }
    self.warning.alpha = 1;
    [self.view bringSubviewToFront:self.warning];
    [UIView animateWithDuration:6 animations:^{
        self.warning.alpha = 0;
    } completion:^(BOOL finished){
//        self.warning.text = nil;
    }];
}

- (void)hideWarning
{
//    self.warning.text = nil;
    if (self.warning.alpha == 1) {
        self.warning.alpha = 0;
    }
}


#pragma mark - List/cards Update Animation

- (void)startTableChange
{
    [self.cardViewCtl.tableView beginUpdates];
}

- (void)runTableChange:(NSNotification *)n
{
    NSFetchedResultsChangeType type = [(NSNumber *)[n.userInfo valueForKey:@"type"] unsignedIntegerValue];
    NSNumber *nu = [n.userInfo valueForKey:@"rowNo"];
    NSUInteger nuv = 99999;
    if (nu) {
        nuv = nu.unsignedIntegerValue;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nuv inSection:0];
    NSNumber *nnu = [n.userInfo valueForKey:@"newRowNo"];
    NSUInteger nnuv = 99999;
    if (nnu) {
        nnuv = nnu.unsignedIntegerValue;
    }
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:nnuv inSection:0];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            // Insertion needs to find the indexPath in the new dataSource
            [self.cardViewCtl.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            // Removing and updating use the indexPath for existing dataSource
            // Updating and insertion do not happen at the same loop in this app. So no need to update the dataSource here.
            [self.cardViewCtl.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            // this is from http://oleb.net/blog/2013/02/nsfetchedresultscontroller-documentation-bug/
            [self.cardViewCtl.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)endTableChange
{
    [self.cardViewCtl.tableView endUpdates];
    // Current new is the new old. Refresh them here after the changes are made.
    [SFBox sharedBox].oldRowIndexPathPairs = nil;
    [SFBox sharedBox].oldRowIndexPathPairs = [[SFBox sharedBox] generateAllRowsIndexPathPairs];
}

- (void)collectionViewChanges:(NSNotification *)n {
    NSFetchedResultsChangeType itemType = [(NSNumber *)[n.userInfo objectForKey:@"itemChangeType"] unsignedIntegerValue];
    NSIndexPath *itemIndexPath = [n.userInfo objectForKey:@"itemChangeIndexPath"];
    NSIndexPath *itemNewIndexPath = [n.userInfo objectForKey:@"itemChangeNewIndexPath"];
    NSFetchedResultsChangeType sectionType = [(NSNumber *)[n.userInfo objectForKey:@"sectionChangeType"] unsignedIntegerValue];
    NSNumber *sectionIndex = [n.userInfo objectForKey:@"sectionChangeIndex"];
    [self.listViewCtl.collectionView performBatchUpdates:^{
        switch(sectionType) {
            case NSFetchedResultsChangeInsert:
                // Insertion needs to find the indexPath in the new dataSource
                [self.listViewCtl.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex.unsignedIntegerValue]];
                break;
            case NSFetchedResultsChangeDelete:
                [self.listViewCtl.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex.unsignedIntegerValue]];
                break;
        }
        switch(itemType) {
            case NSFetchedResultsChangeInsert:
                // Insertion needs to find the indexPath in the new dataSource
                [self.listViewCtl.collectionView insertItemsAtIndexPaths:@[itemNewIndexPath]];
                break;
            case NSFetchedResultsChangeDelete:
                // Removing and updating use the indexPath for existing dataSource
                // Updating and insertion do not happen at the same loop in this app. So no need to update the dataSource here.
                [self.listViewCtl.collectionView deleteItemsAtIndexPaths:@[itemIndexPath]];
                break;
            case NSFetchedResultsChangeUpdate:
                // this is from http://oleb.net/blog/2013/02/nsfetchedresultscontroller-documentation-bug/
                [self.listViewCtl.collectionView reloadItemsAtIndexPaths:@[itemIndexPath]];
                break;
            case NSFetchedResultsChangeMove:
                break;
        }
    } completion:^(BOOL done) {
        if (done) {
            [SFBox sharedBox].oldRowIndexPathPairs = nil;
            [SFBox sharedBox].oldRowIndexPathPairs = [[SFBox sharedBox] generateAllRowsIndexPathPairs];
            // When sections change, the section order changes as well. We need to refresh all the pairs so that we can build the new ones later.
            if (sectionType == NSFetchedResultsChangeInsert || sectionType == NSFetchedResultsChangeDelete) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"rebuildDynamicDisplays" object:self];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDynamicDisplays" object:self];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Save / Delete Record

// Save calendar date as a string. Reason:http://stackoverflow.com/questions/7054411/determining-day-components-of-an-nsdate-object-time-zone-issues
- (void)saveItem
{
    BOOL errOccured = NO;
    SFItem *i = [NSEntityDescription insertNewObjectForEntityForName:@"SFItem" inManagedObjectContext:[SFBox sharedBox].ctx];
    
    if (!self.camViewCtl.img && self.notes.text.length == 0) {
        // words or pic is a must.
        errOccured = YES;
        [[SFBox sharedBox].warningText setString:@"A picture or a few words is helpful to remember what the item is."];
    } else {
        // valid dayAdded is needed.
        if (!self.dateAddedSwitch.on) {
            [i setValue:[self dateToString:self.dateAddedDate] forKey:@"dateAdded"];
        } else {
            [i setValue:[self dateToString:[NSDate date]] forKey:@"dateAdded"];
        }
        if (!errOccured) {
            // valid bestBefore
            if (!self.bestBeforeDate) {
                errOccured = YES;
                [[SFBox sharedBox].warningText setString:@"Please select date for best before."];
            } else {
                [i setValue:[self dateToString:self.bestBeforeDate] forKey:@"bestBefore"];
            }
            if (!errOccured) {
                if ([self validateNotesInput:self.notes.text]) {
                    [i setValue:self.notes.text forKey:@"notes"];
                    [i setValue:[[NSUUID UUID] UUIDString] forKey:@"itemId"];
                    [self resetDaysLeft:i];
                    [self resetFreshness:i];
                    if (self.camViewCtl.img) {
                        [i setValue:[NSNumber numberWithBool:YES] forKey:@"hasPic"];
                        [SFBox sharedBox].imgJustSaved = nil;
                        [SFBox sharedBox].imgNameJustSaved = nil;
//                        [SFBox sharedBox].imgJustSaved = [self convertImageToGrayscale:self.camViewCtl.img];
                        [SFBox sharedBox].imgJustSaved = self.camViewCtl.img;
                        [SFBox sharedBox].imgNameJustSaved = [i valueForKey:@"itemId"];
                    } else {
                        [i setValue:[NSNumber numberWithBool:NO] forKey:@"hasPic"];
                    }
                    NSLog(@"obj to save: %@", i);
                    if (!errOccured) {
                        [i setValue:[NSDate date] forKey:@"timeStamp"];
                        if ([[SFBox sharedBox] saveToDb]) {
                            if (self.camViewCtl.img) {
                                if ([self saveImage:self.camViewCtl.img fileName:[i valueForKey:@"itemId"]]) {
                                    [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 2 / 4, 0) animated:YES];
                                    self.camViewCtl.img = nil;
                                    [[self.camViewCtl.view viewWithTag:555] removeFromSuperview];
                                    self.camViewCtl.captureBtn.hidden = NO;
                                } else {
                                    errOccured = YES;
                                    [[SFBox sharedBox].warningText setString:@"Item added without picture. Not able to save picture this time, please try later."];
                                }
                            } else {
                                [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 2 / 4, 0) animated:YES];
                            }
                            // Keep input info till fully successful submit.
                            [self resetInput];
                        } else {
                            errOccured = YES;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"generalError" object:self];
                        }
                    }
                } else {
                    errOccured = YES;
                    [[SFBox sharedBox].warningText setString:@"Max: 144 characters"];
                }
            }
        }
    }
    if (errOccured) {
        [self showWarningWithName:[SFBox sharedBox].warningText];
    }
}



- (BOOL)saveImage:(UIImage *)img fileName:(NSString *)name
{
    // Save file name to Core Data. Don't store absolute paths.
    NSURL *libraryDirectory = [self getFileBaseUrl];
    NSURL *path = [NSURL URLWithString:name relativeToURL:libraryDirectory];
    // Convert to grayscale image to avoid extra process later.
//    UIImage *img0 = [self convertImageToGrayscale:img];
    // http://stackoverflow.com/questions/22454221/image-orientation-problems-when-reloading-images
    NSData *data = UIImageJPEGRepresentation(img, 0.6);
    NSLog(@"picSize: %f MB", data.length / 1024 / 1024.0);
    return [data writeToURL:path atomically:YES];
}



- (void)deleteItem:(NSNotification *)n
{
    BOOL errOccured = YES;
    for (SFItem *i in [SFBox sharedBox].fResultsCtl.fetchedObjects) {
        if ([[i valueForKey:@"itemId"] isEqualToString:[n.userInfo valueForKey:@"itemId"]] && [[i valueForKey:@"itemId"] length] > 0) {
            NSInteger n = [[SFBox sharedBox].fResultsCtl.fetchedObjects indexOfObject:i];
            NSString *itemIdToDelete = [i valueForKey:@"itemId"];
            [[SFBox sharedBox].ctx deleteObject:i];
            if ([[SFBox sharedBox] saveToDb]) {
                [self.cardViewCtl respondToChangeZViews:n];
                errOccured = NO;
                [self addDeletedItemId:itemIdToDelete];
            }
            break;
        }
    }
    if (errOccured) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"generalError" object:self];
    }
}

- (void)checkAndDeleteImages
{
    NSArray *a = [self readDeletedItemIds];
    NSURL *libraryDirectory = [self getFileBaseUrl];
    for (NSArray *i in a) {
        if (i[0]) {
            NSLog(@"deletedId: %@", i[0]);
            NSURL *path = [NSURL URLWithString:i[0] relativeToURL:libraryDirectory];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path.path]) {
                NSLog(@"1 fileExistsAtPath: %@", path.path);
            } else {
                NSLog(@"1 file NOT existsAtPath: %@", path.path);
            }
            [[NSFileManager defaultManager] removeItemAtURL:path error:nil];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path.path]) {
                NSLog(@"2 fileExistsAtPath: %@", path.path);
            } else {
                NSLog(@"2 file NOT existsAtPath: %@", path.path);
            }
        }
    }
}

#pragma mark - add / read deletedItemId to CSV
- (void)setupCSVForDeletedItem
{
    NSURL *libraryDirectory = [self getFileBaseUrl];
    NSURL *path = [NSURL URLWithString:@"deletedItemIds.csv" relativeToURL:libraryDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path.path]) {
        [[NSFileManager defaultManager] createFileAtPath:path.path contents:nil attributes:nil];
    }
}

- (void)addDeletedItemId:(NSString *)itemId
{
    NSURL *libraryDirectory = [self getFileBaseUrl];
    NSURL *path = [NSURL URLWithString:@"deletedItemIds.csv" relativeToURL:libraryDirectory];
    CHCSVWriter *w;
    if ([[NSFileManager defaultManager] contentsAtPath:path.path].length == 0) {
        w = [[CHCSVWriter alloc] initForWritingToCSVFile:path.path append:NO];
    } else {
        w = [[CHCSVWriter alloc] initForWritingToCSVFile:path.path append:YES];
    }
    [w writeField:itemId];
    [w finishLine];
    [self checkAndDeleteImages];
}

- (NSArray *)readDeletedItemIds
{
    NSURL *libraryDirectory = [self getFileBaseUrl];
    NSURL *path = [NSURL URLWithString:@"deletedItemIds.csv" relativeToURL:libraryDirectory];
    NSLog(@"deletedItemIds.csv path: %@", path.path);
    NSLog(@"file content length: %ld", (unsigned long)[[NSFileManager defaultManager] contentsAtPath:path.path].length);
    return [NSArray arrayWithContentsOfCSVURL:path];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 999) {
        // Remove datePicker.
        if (scrollView.contentOffset.y == 0) {
            [scrollView removeFromSuperview];
        }
    } else if ([scrollView isEqual:self.interfaceBase]) {
        if ([SFBox sharedBox].hintIsOn) {
            NSMutableIndexSet *s;
            if (scrollView.contentOffset.x == 0) {
                // Reach camView
                if (self.camViewCtl.img) {
                    s = [NSMutableIndexSet indexSetWithIndex:5];
                }
            } else if (scrollView.contentOffset.x == scrollView.contentSize.width / 4) {
                // Reach inputView
                s = [NSMutableIndexSet indexSetWithIndex:4];
                [s addIndex:6];
            } else if (scrollView.contentOffset.x == scrollView.contentSize.width / 2) {
                // Reach list
                s = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
            } else if (scrollView.contentOffset.x == scrollView.contentSize.width * 3 / 4) {
                // Reach card/menu
                if (self.menu.hidden) {
                    s = [NSMutableIndexSet indexSetWithIndex:3];
                    s = [NSMutableIndexSet indexSetWithIndex:7];
                }
            }
            if ([s count] > 0) {
                [self processHints:s];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.interfaceBase]) {
        if (scrollView.contentOffset.x == scrollView.contentSize.width / 2) {
            self.menu.hidden = NO;
            self.cardViewBase.hidden = YES;
        }
    }
}

- (void)showPicDisposeHint
{
    if ([SFBox sharedBox].hintIsOn) {
        NSMutableIndexSet *s = [NSMutableIndexSet indexSetWithIndex:5];
        [self processHints:s];
    }
}

#pragma mark - hint display
/*
 Hint display flow:
 A. Intro to create new record:
 1. Show swipeToCreate (if user can figure out how to swipe left to menu, then s/he can easily turn the hint off)
 2. Show swipeToCapture/swipeBack and more info button to show bestBefore/notes/dateAdded
 2.1.1 on Capture, show swipeBack/capture
 2.1.2 after captured, show swipeToDispose/swipeBackToUse
 2.2 show more info for bestBefore/notes/dateAdded
 3. Check every time if mininum requirements for submit has been reached. If yes, show hint for submit.
 B. CardView
 1. Show swipeToDelete and swipeBack
 */

// switches contains the on/off indicators for all the hints on the page in order.
- (void)processHints:(NSIndexSet *)switches
{
    if (!self.hintViews) {
        self.hintViews = [NSMutableSet setWithCapacity:0];
    }
    for (UIView *v in self.view.subviews) {
        if ([v isKindOfClass:[SFHintBase class]]) {
            [v removeFromSuperview];
        };
    }
    [self.hintViews removeAllObjects];
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < 8; i++) {
        [a addObject:[NSNumber numberWithInteger:i]];
    }
    NSArray *r = [a objectsAtIndexes:switches];
    if ([r count] > 0) {
        SFHintBase *base = [[SFHintBase alloc] initWithFrame:self.view.frame];
        [self.view addSubview:base];
        for (NSNumber *y in r) {
            [self addOneHint:y.integerValue onBase:base];
        }
    }
}

- (void)addOneHint:(NSInteger)x onBase:(SFHintBase *)b
{
    UILabel *l;
    NSString *s;
    NSString *t;
    CGRect f;
    CGFloat xToEdge = 20;
    switch (x) {
        case 0:
            if ([self.listViewCtl.collectionView numberOfSections] == 0) {
                f = CGRectMake(xToEdge, 0, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height);
                s = @"SwipeToCreate";
                t = @"Swipe right to add";
            }
            break;
        case 1:
            if ([self.listViewCtl.collectionView numberOfSections] > 0) {
                f = CGRectMake(xToEdge, 0, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height / 2);
                s = @"SwipeToMenu";
                t = @"Swipe left to settings";
            }
            break;
        case 2:
            if ([self.listViewCtl.collectionView numberOfSections] > 0) {
                f = CGRectMake(xToEdge, self.view.frame.size.height / 2, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height / 2);
                s = @"ColorInfo";
            }
            break;
        case 3:
            f = CGRectMake(xToEdge, 0, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height / 2);
            s = @"SwipeBack";
            t = @"Swipe to go back";
            break;
        case 4:
            f = CGRectMake(xToEdge, self.view.frame.size.height / 2, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height / 2);
            s = @"SwipeToCapture";
            t = @"Need a photo? Swipe to take one.";
            break;
        case 5:
            f = CGRectMake(xToEdge, 0, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height);
            s = @"SwipeToDispose";
            t = @"Swipe up to delete. Or swipe back directly, it will be used when you submit.";
            break;
        case 6:
            f = CGRectMake(xToEdge, 0, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height / 2);
            s = @"MoreInputInfo";
            t = @"Pick the best before date and date purchased, if not today. Have a photo/some text. Save. That's it";
            break;
        case 7:
            f = CGRectMake(xToEdge, self.view.frame.size.height / 2, self.view.frame.size.width - xToEdge * 2, self.view.frame.size.height / 2);
            s = @"SwipeToDelete";
            t = @"Swipe left to delete.";
            break;
        default:
            break;
    }
    if (f.size.width > 0) {
        l = [self getHintLabel:f withText:t];
    }
    if (l) {
        [self.hintViews addObject:l];
    }
    if (b) {
        [b addSubview:l];
    }
}

- (UILabel *)getHintLabel:(CGRect)rect withText:(NSString *)t
{
    UILabel *l = [[UILabel alloc] initWithFrame:rect];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentLeft;
    l.text = t;
    l.adjustsFontSizeToFitWidth = YES;
    l.minimumScaleFactor = 1;
    l.numberOfLines = 0;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    l.font = [UIFont fontWithName:@"BradleyHandITCTT-Bold" size:fontSizeM];
    return l;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
