//
//  SFTableViewController.m
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFTableViewController.h"
#import "SFItem.h"
#import "SFTableViewCell.h"
#import "NSObject+SFExtra.h"
#import "Haneke.h"
#import "HNKCache.h"
#import "SFCellCover.h"

@interface SFTableViewController ()

@end

@implementation SFTableViewController

@synthesize box;
@synthesize isForCard;
@synthesize isTransitingFromList;
@synthesize zViews;

- (void)loadView
{
    CGFloat x;
    if (self.isForCard) {
        x = self.box.appRect.size.width * 3;
    } else {
        x = self.box.appRect.size.width * 2;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, 0, self.box.appRect.size.width, self.box.appRect.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    if (self.isForCard) {
        self.tableView.rowHeight = self.box.appRect.size.height;
        self.tableView.pagingEnabled = YES;
        self.tableView.bounces = YES;
        self.tableView.allowsSelection = NO;
        self.zViews = [NSMutableArray arrayWithCapacity:0];
    } else {
        self.tableView.rowHeight = self.box.appRect.size.height / 5;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - z-axis tableViewCell

- (void)refreshZViews
{
    [self.zViews removeAllObjects];
    for (NSManagedObject *o in self.box.fResultsCtl.fetchedObjects) {
        SFCellCover *c = [[SFCellCover alloc] initWithFrame:self.tableView.frame];
        c.box = self.box;
        c.dateAddedTL = [self stringToDate:[o valueForKey:@"dateAdded"]];
        c.bestBeforeTL = [self stringToDate:[o valueForKey:@"bestBefore"]];
        c.todayTL = [self stringToDate:[self dateToString:[NSDate date]]];
        c.stringDaysLeft = [NSString stringWithFormat:@"%ld", (long)[[o valueForKey:@"daysLeft"] integerValue]];
        [c addContent];
        c.alpha = 0;
        NSLog(@"frame: %f, %f, %f, %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
        if ([self.tableView superview]) {
            NSLog(@"YES");
        }
        [[self.tableView superview] addSubview:c];
        [self.zViews addObject:c];
    }
}

- (void)respondToChangeZViews:(NSInteger)rowNo
{
    [self refreshZViews];
    for (SFCellCover *c in self.zViews) {
        if ([self.zViews indexOfObject:c] == rowNo) {
            c.alpha = 1;
        } else {
            c.alpha = 0;
        }
    }
}

- (void)resetZViews:(NSInteger)rowNo
{
    for (SFCellCover *c in self.zViews) {
        if ([self.zViews indexOfObject:c] == rowNo) {
            c.alpha = 1;
        } else {
            c.alpha = 0;
        }
    }
}

- (void)alphaChangeOnZViews:(CGFloat)scrollViewOffsetY cellHeight:(CGFloat)h
{
    if ([self.zViews count] > 0) {
        CGFloat r0 = scrollViewOffsetY / h;
        NSInteger i = ceilf(r0);
        if (r0 - i == 0) {
            i++;
        }
        CGFloat r1 = fmodf(scrollViewOffsetY, h) / h;
        for (SFCellCover *c in self.zViews) {
            if (r0 > 0) {
                if ([self.zViews indexOfObject:c] == i - 1) {
                    c.alpha = 1 - r1;
                } else if ([self.zViews indexOfObject:c] == i) {
                    c.alpha = r1;
                } else {
                    c.alpha = 0;
                }
            } else if (r0 == 0) {
                if ([self.zViews indexOfObject:c] == 0) {
                    c.alpha = 1;
                } else {
                    c.alpha = 0;
                }
                break;
            } else {
                if ([self.zViews indexOfObject:c] == 0) {
                    c.alpha = 1 + r1;
                } else {
                    c.alpha = 0;
                }
                break;
            }
        }
    }
}

#pragma mark - fakeDeleteBtn
// Use frame of deleteBtn on cell.
- (void)getFakeDeleteBtn:(CGRect)frame
{
    if (!self.fakeDeleteBtn && self.isForCard) {
        self.fakeDeleteBtn = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x + self.tableView.frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        self.fakeDeleteBtn.backgroundColor = [UIColor yellowColor];
        [self.tableView.superview addSubview:self.fakeDeleteBtn];
    }
}

- (void)alphaChangeOnFakeDeleteBtn:(CGFloat)scrollViewOffsetY cellHeight:(CGFloat)h
{
    // btn is visible in the range of first half of the height of the cell.
    if ([self.box.fResultsCtl.fetchedObjects count] > 0) {
        CGFloat r = fmodf(scrollViewOffsetY, h) / h;
        CGFloat x = 0.25;
        if (r > 0 && r <= x) {
            self.fakeDeleteBtn.alpha = 1 - r / x;
        } else if (r < 0) {
            self.fakeDeleteBtn.alpha = 1 + r / x;
        } else if (r >= 1 - x && r < 1) {
            self.fakeDeleteBtn.alpha = 1 - (1 - r) / x;
        } else if (r == 0) {
            self.fakeDeleteBtn.alpha = 1;
        } else if (r > x && r < 1 - x) {
            self.fakeDeleteBtn.alpha = 0;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.box.fResultsCtl.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.box.fResultsCtl.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (self.isForCard) {
        cellIdentifier = @"card";
    } else {
        cellIdentifier = @"cell";
    }
    [self.tableView registerClass:[SFTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    SFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.box = self.box;
    NSManagedObject *managedObject = [self.box.fResultsCtl.fetchedObjects objectAtIndex:indexPath.row];
    [cell.pic hnk_cancelSetImage];
    cell.pic.image = nil;
    NSLog(@"obj: %@", managedObject);
    // Make sure the layout is done before assigning any value from NSManagedObj.
    cell.statusCode = [[managedObject valueForKey:@"freshness"] integerValue];
    [cell layoutIfNeeded];
    if ([[managedObject valueForKey:@"hasPic"] boolValue]) {
        NSError *err;
        NSURL *libraryDirectory = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
        if (!err) {
            NSURL *path = [NSURL URLWithString:[managedObject valueForKey:@"itemId"] relativeToURL:libraryDirectory];
            NSData *dImg = [NSData dataWithContentsOfURL:path];
            
            NSLog(@"pic size on local db: %f MB", dImg.length / 1024.0 / 1024);
            if (dImg.length > 0) {
                NSLog(@"path: %@", path.path);
                // Try reading from cache, if not available, async process to generate related ones will be underway so that we probably will have those next time.
                [cell.pic hnk_setImageFromFile:path.path];
                if (cell.pic.image) {
                    NSLog(@"has image");
                } else {
                    NSLog(@"no image");
                    // Use the original one if nothing is available in cache.
                    cell.pic.image = [UIImage imageWithData:dImg];
                }
            } else if (self.box.imgJustSaved && [self.box.imgNameJustSaved isEqualToString:[managedObject valueForKey:@"itemId"]]) {
                cell.pic.image = self.box.imgJustSaved;
            }
        }
    }
    if (self.isForCard) {
        cell.notes.text = [managedObject valueForKey:@"notes"];
        [cell.itemId setString:[managedObject valueForKey:@"itemId"]];
    } else {
        cell.number.text = [NSString stringWithFormat:@"%ld", (long)[[managedObject valueForKey:@"daysLeft"] integerValue]];
        cell.text.text = [managedObject valueForKey:@"notes"];
    }
    // Check and get fakeDeleteBtn ready if necessary.
    [self getFakeDeleteBtn:cell.deleteBtn.frame];
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isForCard) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rowSelected" object:self];
    }
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isForCard) {
        if (!self.isTransitingFromList) {
            [self alphaChangeOnZViews:scrollView.contentOffset.y cellHeight:self.tableView.rowHeight];
            if (self.fakeDeleteBtn) {
                [self alphaChangeOnFakeDeleteBtn:scrollView.contentOffset.y cellHeight:self.tableView.rowHeight];
            }
        }
    }
}



@end
