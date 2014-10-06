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

@interface SFTableViewController ()

@end

@implementation SFTableViewController

@synthesize box;
@synthesize isForCard;


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
    if (self.isForCard) {
        self.tableView.rowHeight = self.box.appRect.size.height;
        self.tableView.pagingEnabled = YES;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.bounces = YES;
        self.tableView.allowsSelection = NO;
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
    cell.imageView.image = nil;
    NSError *err;
    NSURL *libraryDirectory = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
    if (!err) {
        NSURL *path = [NSURL URLWithString:[managedObject valueForKey:@"itemId"] relativeToURL:libraryDirectory];
        NSData *dImg = [NSData dataWithContentsOfURL:path];
        UIImage *i = [UIImage imageWithData:dImg];
        if (i) {
            cell.imageView.image = i;
        }
    }
    // Make sure the layout is done before assigning any value from NSManagedObj.
    cell.statusCode = [[managedObject valueForKey:@"freshness"] integerValue];
    [cell layoutIfNeeded];
    if (self.isForCard) {
        NSLog(@"obj: %@", managedObject);
        cell.notes.text = [managedObject valueForKey:@"notes"];
        cell.dateAdded.text = [self addHyphensToDateString:[self dateToString:[managedObject valueForKey:@"timeAdded"]]];
        cell.bestBefore.text = [self addHyphensToDateString:[self dateToString:[managedObject valueForKey:@"bestBefore"]]];
        cell.daysLeft.text = [NSString stringWithFormat:@"%ld", (long)[[managedObject valueForKey:@"daysLeft"] integerValue]];
        [cell.itemId setString:[managedObject valueForKey:@"itemId"]];
    } else {
        cell.number.text = [NSString stringWithFormat:@"%ld", (long)[[managedObject valueForKey:@"daysLeft"] integerValue]];
        cell.text.text = [managedObject valueForKey:@"notes"];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
