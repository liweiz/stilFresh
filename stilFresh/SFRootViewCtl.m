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
@synthesize menuView;
@synthesize itemViewCtl;
@synthesize warning;
@synthesize dayAddedLabel;
@synthesize dayAddedSwitch;
@synthesize dayAdded;

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
    self.view = [[UIView alloc] initWithFrame:self.appRect];
    self.view.backgroundColor = [UIColor clearColor];
    self.box.appRect = self.appRect;
    self.box.width = self.appRect.size.width - self.box.originX * 2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interfaceBase = [[UIScrollView alloc] initWithFrame:self.box.appRect];
    // Four views, from left to right: 1. cam 2. input 3. list 4. menu/card
    CGSize theContentSize = CGSizeMake(self.box.appRect.size.width * 4, self.box.appRect.size.height);
    self.interfaceBase.contentSize = theContentSize;
    self.interfaceBase.contentOffset = CGPointMake(self.appRect.size.width * 2, 0);
    self.interfaceBase.bounces = NO;
    self.interfaceBase.showsVerticalScrollIndicator = NO;
    self.interfaceBase.showsHorizontalScrollIndicator = NO;
    self.interfaceBase.pagingEnabled = YES;
    self.interfaceBase.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.interfaceBase];
    
    self.camViewCtl = [[SFCamViewCtl alloc] init];
    self.camViewCtl.box = self.box;
    [self addChildViewController:self.camViewCtl];
    [self.interfaceBase addSubview:self.camViewCtl.view];
    [self.camViewCtl didMoveToParentViewController:self];
    
    // InputView
    self.inputView = [[SFView alloc] initWithFrame:CGRectMake(self.appRect.size.width, 0, self.appRect.size.width, self.appRect.size.height)];
    self.inputView.touchToDismissKeyboardIsOn = YES;
    self.inputView.backgroundColor = [UIColor clearColor];
    [self.interfaceBase addSubview:self.inputView];
    // BestBefore
    self.bestBefore = [[UITextField alloc] initWithFrame:CGRectMake(self.box.originX, self.box.originY, self.box.width - self.box.gap - 54, 44)];
    
    self.bestBefore.backgroundColor = [UIColor clearColor];
    self.bestBefore.placeholder = @"Best before: YYYYMMDD";
    self.bestBefore.delegate = self;
    self.bestBefore.keyboardType = UIKeyboardTypeNumberPad;
    self.bestBefore.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    [self configLayer:self.bestBefore.layer box:self.box isClear:YES];
    [self.inputView addSubview:self.bestBefore];
    // AddBtn
    self.addBtn = [[UIView alloc] initWithFrame:CGRectMake(self.bestBefore.frame.origin.x + self.bestBefore.frame.size.width + self.box.gap, self.box.originY, 54, self.bestBefore.frame.size.height)];
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
    self.dayAddedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.box.originX, self.notes.frame.origin.y + self.notes.frame.size.height + self.box.gap, self.bestBefore.frame.size.width, self.bestBefore.frame.size.height)];
    [self configLayer:self.dayAddedLabel.layer box:self.box isClear:NO];
    self.dayAddedLabel.text = @"Purchased today";
    self.dayAddedLabel.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    [self.inputView addSubview:self.dayAddedLabel];
    self.dayAddedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.addBtn.frame.origin.x, self.dayAddedLabel.frame.origin.y + 7, self.addBtn.frame.size.width, self.addBtn.frame.size.height)];
    self.dayAddedSwitch.on = YES;
    
    [self.dayAddedSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.inputView addSubview:self.dayAddedSwitch];
    self.dayAddedSwitch.onTintColor = self.box.sfGreen0;
    self.dayAdded = [[UITextField alloc] initWithFrame:CGRectMake(self.box.originX, self.box.gap + self.notes.frame.origin.y + self.notes.frame.size.height, self.box.width - self.box.gap - 54, 44)];
    [self configLayer:self.dayAdded.layer box:self.box isClear:YES];
    self.dayAdded.backgroundColor = [UIColor clearColor];
    self.dayAdded.placeholder = @"Date purchased: YYYYMMDD";
    self.dayAdded.delegate = self;
    self.dayAdded.keyboardType = UIKeyboardTypeNumberPad;
    self.dayAdded.font = [UIFont systemFontOfSize:self.box.fontSizeL];
    [self.inputView addSubview:self.dayAdded];
    self.dayAdded.hidden = YES;
    
    [self.box prepareDataSource];
    
    // ListViewCtl
    self.listViewCtl = [[SFTableViewController alloc] init];
    self.listViewCtl.box = self.box;
    self.listViewCtl.isForCard = NO;
    [self addChildViewController:self.listViewCtl];
    [self.interfaceBase addSubview:self.listViewCtl.tableView];
    [self.listViewCtl didMoveToParentViewController:self];
    
    // CardViewCtl
    self.cardViewCtl = [[SFTableViewController alloc] init];
    self.cardViewCtl.box = self.box;
    self.cardViewCtl.isForCard = YES;
    [self addChildViewController:self.cardViewCtl];
    [self.interfaceBase addSubview:self.cardViewCtl.tableView];
    [self.cardViewCtl didMoveToParentViewController:self];
//    self.cardViewCtl.tableView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCard) name:@"rowSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataForTables) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWarning:) name:@"generalError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTableChange) name:@"startTableChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runTableChange:) name:@"runTableChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endTableChange) name:@"endTableChange" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name:@"deleteItem" object:nil];
}

- (void)saveItem
{
    BOOL errOccured = NO;
    if (!self.dayAddedSwitch.isOn) {
        NSDate *p = [self stringToDate:self.dayAdded.text];
        if (!p) {
            errOccured = YES;
            [self.box.warningText setString:@"Please enter date info: YYYY-MM-DD."];
        }
    }
    if (!errOccured) {
        NSDate *d = [self stringToDate:self.bestBefore.text];
        if (d) {
            if ([self validateNotesInput:self.notes.text]) {
                SFItem *i = [NSEntityDescription insertNewObjectForEntityForName:@"SFItem" inManagedObjectContext:self.box.ctx];
                [i setValue:self.notes.text forKey:@"notes"];
                [i setValue:d forKey:@"bestBefore"];
                if (self.dayAddedSwitch.on) {
                    [i setValue:[NSDate date] forKey:@"timeAdded"];
                    [i setValue:[[NSUUID UUID] UUIDString] forKey:@"itemId"];
                } else {
                    NSDate *d1 = [self stringToDate:self.dayAdded.text];
                    if (d1) {
                        [i setValue:d1 forKey:@"timeAdded"];
                        [self resetDaysLeft:i];
                        [self resetFreshness:i];
                        [i setValue:[[NSUUID UUID] UUIDString] forKey:@"itemId"];
                    } else {
                        errOccured = YES;
                        [self.box.warningText setString:@"Please enter date info: YYYY-MM-DD."];
                    }
                }
                if (!errOccured) {
                    if ([self.box saveToDb]) {
                        [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 2 / 4, 0) animated:YES];
                    } else {
                        errOccured = YES;
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"generalError" object:self];
                    }
                }
            } else {
                errOccured = YES;
                [self.box.warningText setString:@"Max: 144 characters"];
            }
        } else {
            errOccured = YES;
            [self.box.warningText setString:@"Please enter date info: YYYY-MM-DD."];
        }
    }
    if (errOccured) {
        [self showWarningWithName:self.box.warningText];
    }
}


- (void)deleteItem:(NSNotification *)n
{
    BOOL errOccured = YES;
    for (SFItem *i in self.box.fResultsCtl.fetchedObjects) {
        if ([[i valueForKey:@"itemId"] isEqualToString:[n.userInfo valueForKey:@"itemId"]] && [[i valueForKey:@"itemId"] length] > 0) {
            [self.box.ctx deleteObject:i];
            if ([self.box saveToDb]) {
                errOccured = NO;
            }
            break;
        }
    }
    if (errOccured) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"generalError" object:self];
    }
}

- (void)reloadDataForTables
{
    [self.listViewCtl.tableView reloadData];
    [self.cardViewCtl.tableView reloadData];
}

- (void)showCard
{
    [self.cardViewCtl.tableView scrollToRowAtIndexPath:self.listViewCtl.tableView.indexPathForSelectedRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
    self.cardViewCtl.tableView.hidden = NO;
    [self.cardViewCtl.tableView.superview bringSubviewToFront:self.cardViewCtl.tableView];
    [self.interfaceBase setContentOffset:CGPointMake(self.interfaceBase.contentSize.width * 3 / 4, 0) animated:YES];
}


- (void)changeSwitch:(UISwitch *)sender
{
    if(sender.on){
        NSLog(@"Switch is ON");
        self.dayAdded.hidden = YES;
        self.dayAddedLabel.hidden = NO;
    } else{
        NSLog(@"Switch is OFF");
        self.dayAdded.hidden = NO;
        self.dayAddedLabel.hidden = YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.bestBefore]) {
        if (textField.text.length == 0) {
            NSDateComponents *c = [[NSDateComponents alloc] init];
            c.day = 5;
            NSDate *dayAfter5 = [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:[NSDate date] options:0];
            self.bestBefore.text = [self dateToString:dayAfter5];
        }
    }
    if ([textField isEqual:self.dayAdded]) {
        if (textField.text.length == 0) {
            NSDateComponents *c = [[NSDateComponents alloc] init];
            c.day = -5;
            NSDate *dayAfter5 = [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:[NSDate date] options:0];
            self.dayAdded.text = [self dateToString:dayAfter5];
        }
    }
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
