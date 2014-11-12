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
#import "SFCellCover.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SFHintView.h"
#import "SFBox.h"

@interface SFTableViewController ()

@end

@implementation SFTableViewController

@dynamic objects;
@dynamic name;
@dynamic numberOfObjects;
@dynamic indexTitle;

- (void)loadView
{
    CGFloat x;
    x = 0;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(x, 0, [SFBox sharedBox].appRect.size.width, [SFBox sharedBox].appRect.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.bounces = YES;
    self.tableView.rowHeight = [SFBox sharedBox].appRect.size.height;
    self.tableView.pagingEnabled = YES;
    
    self.tableView.allowsSelection = NO;
    self.zViews = [NSMutableArray arrayWithCapacity:0];
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
    for (SFCellCover *x in self.zViews) {
        if (x.superview) {
            [x removeFromSuperview];
        }
    }
    [self.zViews removeAllObjects];
    
    for (NSManagedObject *o in [SFBox sharedBox].fResultsCtl.fetchedObjects) {
        SFCellCover *c = [[SFCellCover alloc] initWithFrame:self.tableView.frame];
        c.dateAddedTL = [self stringToDate:[o valueForKey:@"dateAdded"]];
        c.bestBeforeTL = [self stringToDate:[o valueForKey:@"bestBefore"]];
        c.todayTL = [self stringToDate:[self dateToString:[NSDate date]]];
        c.stringDaysLeft = [NSString stringWithFormat:@"%ld", (long)[[o valueForKey:@"daysLeft"] integerValue]];
        [c addContent];
        c.alpha = 0;
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
        self.fakeDeleteBtn.backgroundColor = [UIColor clearColor];
        UIImage *i = [UIImage imageNamed:@"DeleteIcon"];
        self.fakeDeleteBtn.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.fakeDeleteBtn.tintColor = [UIColor whiteColor];
        [self.tableView.superview addSubview:self.fakeDeleteBtn];
        // First time launch.
        [self refreshZViews];
    }
}

- (void)alphaChangeOnFakeDeleteBtn:(CGFloat)scrollViewOffsetY cellHeight:(CGFloat)h
{
    // btn is visible in the range of first half of the height of the cell.
    if ([[SFBox sharedBox].fResultsCtl.fetchedObjects count] > 0) {
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[SFBox sharedBox].fResultsCtl.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    cellIdentifier = @"card";
    [self.tableView registerClass:[SFTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    SFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSManagedObject *managedObject = [[SFBox sharedBox].fResultsCtl.fetchedObjects objectAtIndex:indexPath.row];
    cell.pic.image = nil;
    NSLog(@"obj: %@", managedObject);
    // Make sure the layout is done before assigning any value from NSManagedObj.
    cell.statusCode = [[managedObject valueForKey:@"freshness"] integerValue];
    BOOL hasImg = NO;
    if ([[managedObject valueForKey:@"hasPic"] boolValue]) {
        hasImg = YES;
        NSError *err;
        NSURL *libraryDirectory = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
        if (!err) {
            NSURL *path = [NSURL URLWithString:[managedObject valueForKey:@"itemId"] relativeToURL:libraryDirectory];
            NSData *dImg = [NSData dataWithContentsOfURL:path];
            NSLog(@"pic size on local db: %f MB", dImg.length / 1024.0 / 1024);
            if (dImg.length > 0) {
                // Try reading from cache, if not available, async process to generate related ones will be underway so that we probably will have those next time.
                [cell.pic sd_setImageWithURL:path];
                if (!cell.pic.image) {
                    // Use the original one if nothing is available in cache.
                    cell.pic.image = [UIImage imageWithData:dImg];
                }
            } else if ([SFBox sharedBox].imgJustSaved && [[SFBox sharedBox].imgNameJustSaved isEqualToString:[managedObject valueForKey:@"itemId"]]) {
                cell.pic.image = [SFBox sharedBox].imgJustSaved;
            }
        }
    }
    [cell getViewsReady];
    cell.bestBefore.text = [self displayBBWithIntro:[managedObject valueForKey:@"bestBefore"]];
    cell.notes.text = [managedObject valueForKey:@"notes"];
    [cell.itemId setString:[managedObject valueForKey:@"itemId"]];
    [cell configWithImg:hasImg];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.isForCard) {
        id <NSFetchedResultsSectionInfo> x = [SFBox sharedBox].fResultsCtl.sections[section];
        return [x name];
    }
    return nil;
}

#pragma mark - scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isTransitingFromList) {
        [self alphaChangeOnZViews:scrollView.contentOffset.y cellHeight:self.tableView.rowHeight];
    }
}

@end
