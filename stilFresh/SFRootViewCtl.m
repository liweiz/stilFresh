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


@interface SFRootViewCtl ()

@end

@implementation SFRootViewCtl

@synthesize appRect;
@synthesize box;
@synthesize interfaceBase;
@synthesize inputView;
@synthesize bestBefore;
@synthesize addBtn;
@synthesize addTap;
@synthesize notes;
@synthesize notesPlaceHolder;
@synthesize purchasedOn;
@synthesize camViewCtl;
@synthesize listViewCtl;
@synthesize cardViewCtl;
@synthesize cardViewBase;
@synthesize menuView;
@synthesize itemViewCtl;
@synthesize warning;
@synthesize dateAddedLabel;
@synthesize dateAddedSwitch;
@synthesize dateAdded;
@synthesize isForBestBefore;
@synthesize bestBeforeDate;
@synthesize dateAddedDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.box = [[SFBox alloc] init];
    }
    return self;
}

- (void)loadView
{
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
    self.view = [[UIView alloc] initWithFrame:self.appRect];
    self.view.backgroundColor = [UIColor whiteColor];
    self.box.appRect = self.appRect;
    self.box.width = self.appRect.size.width - self.box.originX * 2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interfaceBase = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.box.appRect.size.width + self.box.gap, self.box.appRect.size.height)];
    // Four views, from left to right: 1. cam 2. input 3. list 4. menu/card 5. swipe-to-left-to-delete
    CGSize theContentSize = CGSizeMake((self.box.appRect.size.width + self.box.gap) * 4 , self.box.appRect.size.height);
    self.interfaceBase.contentSize = theContentSize;
    self.interfaceBase.contentOffset = CGPointMake((self.appRect.size.width + self.box.gap) * 2, 0);
    self.interfaceBase.bounces = NO;
    self.interfaceBase.showsVerticalScrollIndicator = NO;
    self.interfaceBase.showsHorizontalScrollIndicator = NO;
    self.interfaceBase.pagingEnabled = YES;
    self.interfaceBase.backgroundColor = [UIColor clearColor];
    self.interfaceBase.delegate = self;
    [self.view addSubview:self.interfaceBase];
    
    self.camViewCtl = [[SFCamViewCtl alloc] init];
    self.camViewCtl.box = self.box;
    [self addChildViewController:self.camViewCtl];
    [self.interfaceBase addSubview:self.camViewCtl.view];
    [self.camViewCtl didMoveToParentViewController:self];
    
    // add black gap
    UIView *g0 = [[UIView alloc] initWithFrame:CGRectMake(self.camViewCtl.view.frame.size.width, 0, self.box.gap, self.appRect.size.height)];
    g0.backgroundColor = [UIColor blackColor];
    [self.interfaceBase addSubview:g0];
    
    // InputView
    self.inputView = [[SFView alloc] initWithFrame:CGRectMake(self.appRect.size.width + self.box.gap, 0, self.appRect.size.width, self.appRect.size.height)];
    self.inputView.touchToDismissKeyboardIsOn = YES;
    self.inputView.touchToDismissViewIsOn = YES;
    self.inputView.backgroundColor = [UIColor clearColor];
    [self.interfaceBase addSubview:self.inputView];
    // add black gap
    UIView *g1 = [[UIView alloc] initWithFrame:CGRectMake(self.inputView.frame.origin.x + self.inputView.frame.size.width, 0, self.box.gap, self.appRect.size.height)];
    g1.backgroundColor = [UIColor blackColor];
    [self.interfaceBase addSubview:g1];
    // BestBefore
    self.bestBefore = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.box.originY + 20, self.box.width - self.box.gap - 54, 44)];
    UITapGestureRecognizer *bbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBestBefore)];
    [self.bestBefore addGestureRecognizer:bbTap];
    self.bestBefore.userInteractionEnabled = YES;
    [self checkPlaceHolder];
    self.bestBefore.backgroundColor = [UIColor clearColor];
    
    self.bestBefore.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    [self configLayer:self.bestBefore.layer box:self.box isClear:YES];
    [self.inputView addSubview:self.bestBefore];
    // AddBtn
    self.addBtn = [[UIView alloc] initWithFrame:CGRectMake(self.bestBefore.frame.origin.x + self.bestBefore.frame.size.width + self.box.gap, self.bestBefore.frame.origin.y, 54, self.bestBefore.frame.size.height)];
    [self configLayer:self.addBtn.layer box:self.box isClear:NO];
    self.addBtn.backgroundColor = self.box.sfGreen0;
    self.addTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveItem)];
    [self.addBtn addGestureRecognizer:self.addTap];
    [self.inputView addSubview:self.addBtn];
    // Notes
    self.notes = [[UITextView alloc] initWithFrame:CGRectMake(self.bestBefore.frame.origin.x, self.bestBefore.frame.origin.y + self.bestBefore.frame.size.height + self.box.gap, self.box.width, self.box.oneLineHeight * 2)];
    [self configLayer:self.notes.layer box:self.box isClear:YES];
    self.notes.backgroundColor = [UIColor clearColor];
    self.notes.delegate = self;
    self.notes.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    self.notes.text = @"";
    [self.inputView addSubview:self.notes];
    self.notesPlaceHolder = [[UITextField alloc] initWithFrame:CGRectMake(0, -4, self.box.width - self.box.gap - 54, 44)];
    self.notesPlaceHolder.backgroundColor = [UIColor clearColor];
    self.notesPlaceHolder.placeholder = @"Info for this item";
    self.notesPlaceHolder.userInteractionEnabled = NO;
    self.notesPlaceHolder.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    [self.notes addSubview:self.notesPlaceHolder];
    // DayAdded
    self.dateAddedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.notes.frame.origin.y + self.notes.frame.size.height + self.box.gap, self.bestBefore.frame.size.width, self.bestBefore.frame.size.height)];
    [self configLayer:self.dateAddedLabel.layer box:self.box isClear:NO];
    self.dateAddedLabel.text = @"Purchased today";
    self.dateAddedLabel.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    [self.inputView addSubview:self.dateAddedLabel];
    self.dateAddedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.addBtn.frame.origin.x, self.dateAddedLabel.frame.origin.y + 7, self.addBtn.frame.size.width, self.addBtn.frame.size.height)];
    self.dateAddedSwitch.on = YES;
    
    [self.dateAddedSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.inputView addSubview:self.dateAddedSwitch];
    self.dateAddedSwitch.onTintColor = self.box.sfGreen0;
    self.dateAdded = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gap + self.notes.frame.origin.y + self.notes.frame.size.height, self.box.width - self.box.gap - 54, 44)];
    UITapGestureRecognizer *daTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDateAdded)];
    [self.dateAdded addGestureRecognizer:daTap];
    self.dateAdded.userInteractionEnabled = YES;
    [self configLayer:self.dateAdded.layer box:self.box isClear:YES];
    self.dateAdded.backgroundColor = [UIColor clearColor];

    self.dateAdded.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    [self.inputView addSubview:self.dateAdded];
    self.dateAdded.hidden = YES;
    
    [self.box prepareDataSource];
    
    // ListViewCtl
    self.listViewCtl = [[SFTableViewController alloc] init];
    self.listViewCtl.box = self.box;
    self.listViewCtl.isForCard = NO;
    [self addChildViewController:self.listViewCtl];
    [self.interfaceBase addSubview:self.listViewCtl.tableView];
    [self.listViewCtl didMoveToParentViewController:self];
    // add black gap
    UIView *g2 = [[UIView alloc] initWithFrame:CGRectMake(self.listViewCtl.tableView.frame.origin.x + self.listViewCtl.tableView.frame.size.width, 0, self.box.gap, self.appRect.size.height)];
    g2.backgroundColor = [UIColor blackColor];
    [self.interfaceBase addSubview:g2];
    
    // CardViewCtl
    self.cardViewBase = [[UIView alloc] initWithFrame:CGRectMake((self.box.appRect.size.width + self.box.gap) * 3, 0, self.box.appRect.size.width, self.box.appRect.size.height)];
    self.cardViewBase.backgroundColor = [UIColor clearColor];
    [self.interfaceBase addSubview:self.cardViewBase];
    self.cardViewCtl = [[SFTableViewController alloc] init];
    self.cardViewCtl.box = self.box;
    self.cardViewCtl.isForCard = YES;
    [self addChildViewController:self.cardViewCtl];
    [self.cardViewBase addSubview:self.cardViewCtl.tableView];
    [self.cardViewCtl didMoveToParentViewController:self];
//    self.cardViewCtl.tableView.hidden = YES;
    // add black gap
    UIView *g3 = [[UIView alloc] initWithFrame:CGRectMake(self.cardViewBase.frame.origin.x + self.cardViewBase.frame.size.width, 0, self.box.gap, self.appRect.size.height)];
    g3.backgroundColor = [UIColor blackColor];
    [self.interfaceBase addSubview:g3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCard) name:@"rowSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataForTables) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarning:) name:@"generalError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTableChange) name:@"startTableChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runTableChange:) name:@"runTableChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endTableChange) name:@"endTableChange" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name:@"deleteItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDatePicker) name:@"dismiss" object:nil];
    // Create a CSV file in NSLibraryDirectory to store all the deleted items' itemIds to locate and delete their corresponding image files.
    [self setupCSVForDeletedItem];
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
    [self showDatePicker:self.bestBefore date:self.bestBeforeDate];
}

// Start to edit dateAdded
- (void)changeSwitch:(UISwitch *)sender
{
    if(sender.on){
        NSLog(@"Switch is ON");
        self.dateAdded.hidden = YES;
        self.dateAddedLabel.hidden = NO;
        [self hideDatePicker];
    } else{
        NSLog(@"Switch is OFF");
        self.dateAdded.hidden = NO;
        self.dateAddedLabel.hidden = YES;
        NSDateComponents *c = [[NSDateComponents alloc] init];
        c.day = -5;
        NSDate *dayBefore5 = [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:[NSDate date] options:0];
        self.dateAddedDate = dayBefore5;
        [self showDatePicker:self.dateAdded date:self.dateAddedDate];
    }
}

- (void)tapOnDateAdded
{
    [self showDatePicker:self.dateAdded date:self.dateAddedDate];
}

- (void)checkPlaceHolder
{
    if (self.bestBefore.text.length == 0) {
        self.bestBefore.text = @"Best before";
        self.bestBefore.textColor = self.box.placeholderFontColor;
    } else {
        self.bestBefore.textColor = [UIColor blackColor];
    }
}

- (void)resetInput
{
    self.bestBefore.text = @"Best before";
    self.bestBeforeDate = nil;
    self.bestBefore.textColor = self.box.placeholderFontColor;
    self.notes.text = @"";
    self.dateAddedSwitch.on = YES;
    [self changeSwitch:self.dateAddedSwitch];
}

#pragma mark - datePicker
- (void)showDatePicker:(UILabel *)l date:(NSDate *)d
{
    if (![self.interfaceBase viewWithTag:999]) {
        // http://stackoverflow.com/questions/18970679/ios-7-uidatepicker-height-inconsistency
        CGFloat h = 216;
        UIScrollView *base = [[UIScrollView alloc] initWithFrame:CGRectMake(self.inputView.frame.origin.x, self.appRect.size.height - h, self.appRect.size.width, h)];
        base.tag = 999;
        base.backgroundColor = [UIColor clearColor];
        base.contentSize = CGSizeMake(base.frame.size.width, base.frame.size.height * 2);
        base.userInteractionEnabled = YES;
        base.delegate = self;
        UIDatePicker *p = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, base.frame.size.height, base
                                                                         .frame.size.width, base.frame.size.height)];
        p.tag = 998;
        [p addTarget:self action:@selector(dateUpdated:) forControlEvents:UIControlEventValueChanged];
        p.datePickerMode = UIDatePickerModeDate;
        [base addSubview:p];
        [self.interfaceBase addSubview:base];
        [base setContentOffset:CGPointMake(0, base.frame.size.height) animated:YES];
    }
    if ([l isEqual:self.bestBefore]) {
        self.isForBestBefore = YES;
    } else if ([l isEqual:self.dateAdded]) {
        self.isForBestBefore = NO;
    }
    UIDatePicker *x = (UIDatePicker *)[self.interfaceBase viewWithTag:998];
    if ([x isKindOfClass:[UIDatePicker class]]) {
        [x setDate:d animated:NO];
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
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.tag == 999) {
        if (scrollView.contentOffset.y == 0) {
            [scrollView removeFromSuperview];
        }
    }
}

- (void)reloadDataForTables
{
    [self.listViewCtl.tableView reloadData];
    [self.cardViewCtl.tableView reloadData];
}

- (void)showCard
{
    self.cardViewCtl.isTransitingFromList = YES;
    [self.cardViewCtl.tableView scrollToRowAtIndexPath:self.listViewCtl.tableView.indexPathForSelectedRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.cardViewCtl.isTransitingFromList = NO;
    self.cardViewCtl.tableView.hidden = NO;
    [self.cardViewCtl.tableView.superview sendSubviewToBack:self.cardViewCtl.tableView];
    [self.cardViewCtl refreshZViews];
    [self.cardViewCtl resetZViews:self.listViewCtl.tableView.indexPathForSelectedRow.row];
    [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 3 / 4, 0) animated:YES];
}

#pragma mark - text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.notes]) {
        if (!self.notesPlaceHolder.hidden) {
            self.notesPlaceHolder.hidden = YES;
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView isEqual:self.notes]) {
        if (self.notes.text.length == 0) {
            self.notesPlaceHolder.hidden = NO;
        }
    }
}

#pragma mark - warning display

- (void)showWarning:(NSNotification *)note
{
    [self showWarningWithName:note.name];
}

- (void)showWarningWithName:(NSString *)notificationName
{
    // Clear the item inserted but not saved yet
    for (SFItem *i in self.box.ctx.insertedObjects) {
        [self.box.ctx deleteObject:i];
    }
    if (!self.warning) {
        CGFloat w = 220;
        CGFloat h = 75;
        self.warning = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - w) * 0.5, (self.view.frame.size.height - h) * 0.5 - 30, w, h)];
        [self.view addSubview:self.warning];
        self.warning.font = [self.warning.font fontWithSize:self.box.fontSizeM];
        self.warning.textColor = [UIColor whiteColor];
        self.warning.textAlignment = NSTextAlignmentCenter;
        self.warning.lineBreakMode = NSLineBreakByWordWrapping;
        self.warning.numberOfLines = 0;
        self.warning.backgroundColor = self.box.sfGray;
    }
    if ([notificationName isEqualToString:@"generalError"]) {
        self.warning.text = @"Something went wrong, please try later.";
    } else {
        self.warning.text = self.box.warningText;
    }
    self.warning.alpha = 1;
    [self.view bringSubviewToFront:self.warning];
    [UIView animateWithDuration:4 animations:^{
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


#pragma mark - change tables

- (void)startTableChange
{
    [self.listViewCtl.tableView beginUpdates];
    [self.cardViewCtl.tableView beginUpdates];
}

- (void)runTableChange:(NSNotification *)n
{
    NSFetchedResultsChangeType type = [(NSNumber *)[n.userInfo valueForKey:@"type"] unsignedIntegerValue];
    NSIndexPath *indexPath = [n.userInfo valueForKey:@"indexPath"];
    NSIndexPath *newIndexPath = [n.userInfo valueForKey:@"newIndexPath"];
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            // Insertion needs to find the indexPath in the new dataSource
            [self.listViewCtl.tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [self.cardViewCtl.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                              withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            // Removing and updating use the indexPath for existing dataSource
            // Updating and insertion do not happen at the same loop in this app. So no need to update the dataSource here.
            [self.listViewCtl.tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [self.cardViewCtl.tableView deleteRowsAtIndexPaths:@[indexPath]
                                              withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            // this is from http://oleb.net/blog/2013/02/nsfetchedresultscontroller-documentation-bug/
            [self.listViewCtl.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.cardViewCtl.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
            //atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            //                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
            //                                 withRowAnimation:UITableViewRowAnimationFade];
            //                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
            //                                 withRowAnimation:UITableViewRowAnimationFade];
            break;
    }

}

- (void)endTableChange
{
    [self.listViewCtl.tableView endUpdates];
    [self.cardViewCtl.tableView endUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - save / delete record

// Save calendar date as a string. Reason:http://stackoverflow.com/questions/7054411/determining-day-components-of-an-nsdate-object-time-zone-issues
- (void)saveItem
{
    BOOL errOccured = NO;
    SFItem *i = [NSEntityDescription insertNewObjectForEntityForName:@"SFItem" inManagedObjectContext:self.box.ctx];
    
    if (!self.camViewCtl.img && self.notes.text.length == 0) {
        // words or pic is a must.
        errOccured = YES;
        [self.box.warningText setString:@"A picture or a few words is helpful to remember what the item is."];
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
                [self.box.warningText setString:@"Please select date for best before."];
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
                        self.box.imgJustSaved = nil;
                        self.box.imgNameJustSaved = nil;
                        self.box.imgJustSaved = [self convertImageToGrayscale:self.camViewCtl.img];
                        self.box.imgNameJustSaved = [i valueForKey:@"itemId"];
                    } else {
                        [i setValue:[NSNumber numberWithBool:NO] forKey:@"hasPic"];
                    }
                    NSLog(@"obj to save: %@", i);
                    if (!errOccured) {
                        if ([self.box saveToDb]) {
                            if (self.camViewCtl.img) {
                                if ([self saveImage:self.camViewCtl.img fileName:[i valueForKey:@"itemId"]]) {
                                    [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 2 / 4, 0) animated:YES];
                                    self.camViewCtl.img = nil;
                                    [[self.camViewCtl.view viewWithTag:555] removeFromSuperview];
                                    self.camViewCtl.captureBtn.hidden = NO;
                                } else {
                                    errOccured = YES;
                                    [self.box.warningText setString:@"Item added without picture. Not able to save picture this time, please try later."];
                                }
                            } else {
                                [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 2 / 4, 0) animated:YES];
                                // Keep input info till fully successful submit.
                                [self resetInput];
                            }
                        } else {
                            errOccured = YES;
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"generalError" object:self];
                        }
                    }
                } else {
                    errOccured = YES;
                    [self.box.warningText setString:@"Max: 144 characters"];
                }
            }
        }
    }
    if (errOccured) {
        [self showWarningWithName:self.box.warningText];
    }
}



- (BOOL)saveImage:(UIImage *)img fileName:(NSString *)name
{
    // Save file name to Core Data. Don't store absolute paths.
    NSURL *libraryDirectory = [self getFileBaseUrl];
    NSURL *path = [NSURL URLWithString:name relativeToURL:libraryDirectory];
    // Convert to grayscale image to avoid extra process later.
    UIImage *img0 = [self convertImageToGrayscale:img];
    // http://stackoverflow.com/questions/22454221/image-orientation-problems-when-reloading-images
    NSData *data = UIImageJPEGRepresentation(img0, 0.6);
    NSLog(@"picSize: %f MB", data.length / 1024 / 1024.0);
    return [data writeToURL:path atomically:YES];
}



- (void)deleteItem:(NSNotification *)n
{
    BOOL errOccured = YES;
    for (SFItem *i in self.box.fResultsCtl.fetchedObjects) {
        if ([[i valueForKey:@"itemId"] isEqualToString:[n.userInfo valueForKey:@"itemId"]] && [[i valueForKey:@"itemId"] length] > 0) {
            NSInteger n = [self.box.fResultsCtl.fetchedObjects indexOfObject:i];
            NSString *itemIdToDelete = [i valueForKey:@"itemId"];
            [self.box.ctx deleteObject:i];
            if ([self.box saveToDb]) {
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

#pragma mark - timeLine




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
