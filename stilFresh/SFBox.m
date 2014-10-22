//
//  SFBox.m
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-25.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFBox.h"
#import "SFItem.h"
#import "NSObject+SFExtra.h"

@implementation SFBox

@synthesize appRect;
@synthesize ctx;
@synthesize fReq;
@synthesize fResultsCtl;
@synthesize sortSelection;
@synthesize warningText;
@synthesize originX;
@synthesize originY;
@synthesize oneLineHeight;
@synthesize width;
@synthesize gap;
@synthesize sfGreen0;
@synthesize sfGreen1;
@synthesize sfGreen2;
@synthesize sfGray;
@synthesize imgJustSaved;
@synthesize imgNameJustSaved;
@synthesize goldenRatio;
@synthesize gapToEdge;
@synthesize bestBeforeFrame;
@synthesize placeholderFontColor;

- (id)init
{
    self = [super init];
    if (self) {
        self.sortSelection = [NSMutableArray arrayWithCapacity:0];
        [self.sortSelection addObject:[NSNumber numberWithInteger:SFSortFreshnessD]];
        [self.sortSelection addObject:[NSNumber numberWithInteger:SFSortDaysLeftA]];
//        [self.sortSelection addObject:[NSNumber numberWithInteger:SFSortCellTextAlphabetA]];
        self.warningText = [[NSMutableString alloc] init];
        self.originX = 15;
        self.originY = 15;
        self.gap = 2;
        self.gapToEdge = 15;
        self.oneLineHeight = 40;
        self.fontSizeL = 16;
        self.fontSizeM = 14;
        CGFloat alpha = 0.8;
        // http://stackoverflow.com/questions/10496114/uitextfield-placeholder-font-color-white-ios-5
        self.placeholderFontColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.098/255.0 alpha:0.22];
        self.sfGreen0 = [UIColor colorWithRed:157 / 255.0 green:225 / 255.0 blue:63 / 255.0 alpha:alpha];
        self.sfGreen1 = [UIColor colorWithRed:150 / 255.0 green:206 / 255.0 blue:107 / 255.0 alpha:alpha];
        self.sfGreen2 = [UIColor colorWithRed:152 / 255.0 green:189 / 255.0 blue:93 / 255.0 alpha:alpha];
        self.sfGray = [UIColor colorWithRed:130 / 255.0 green:131 / 255.0 blue:126 / 255.0 alpha:alpha];
        self.goldenRatio = 1.61803398875;
    }
    return self;
}

- (void)prepareDataSource
{
    if (!self.fReq) {
        self.fReq = [NSFetchRequest fetchRequestWithEntityName:@"SFItem"];
    }
    self.fReq.sortDescriptors = [self sortOption:self.sortSelection];
    // Config fetchResultController
    self.fResultsCtl = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fReq managedObjectContext:self.ctx sectionNameKeyPath:nil cacheName:nil];
    self.fResultsCtl.delegate = self;
    [self.fResultsCtl performFetch:nil];
    [self refreshDb];
}

- (void)refreshDb
{
    for (SFItem *i in self.fResultsCtl.fetchedObjects) {
        [self resetDaysLeft:i];
        [self resetFreshness:i];
    }
    if (![self saveToDb]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"generalError" object:self];
    }
}

#pragma mark - fetchedResultsController delegate callbacks

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startTableChange" object:self];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setValue:indexPath forKey:@"indexPath"];
    [d setValue:newIndexPath forKey:@"newIndexPath"];
    [d setValue:[NSNumber numberWithUnsignedInteger:type] forKey:@"type"];
    NSNotification *n = [NSNotification notificationWithName:@"runTableChange" object:self userInfo:d];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endTableChange" object:self];
}


- (NSArray *)sortOption:(NSArray *)options
{
    NSMutableArray *ma = [NSMutableArray arrayWithCapacity:0];
    for (NSNumber *n in options) {
        NSSortDescriptor *sd = [self sortBy:n.integerValue];
        [ma addObject:sd];
    }
    return ma;
}

- (NSSortDescriptor *)sortBy:(NSInteger)by
{
    switch (by) {
        case SFSortCellTextAlphabetA:
            return [NSSortDescriptor sortDescriptorWithKey:@"notes" ascending:YES comparator:^(NSString *obj1, NSString *obj2) {
                return [obj1 localizedCompare:obj2];
            }];
        case SFSortCellTextAlphabetD:
            return [NSSortDescriptor sortDescriptorWithKey:@"notes" ascending:NO comparator:^(NSString *obj1, NSString *obj2) {
                return [obj1 localizedCompare:obj2];
            }];
        case SFSortDaysLeftA:
            return [[NSSortDescriptor alloc] initWithKey:@"daysLeft" ascending:YES];
        case SFSortDaysLeftD:
            return [[NSSortDescriptor alloc] initWithKey:@"daysLeft" ascending:NO];
        case SFSortTimeCreatedA:
            return [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:YES];
        case SFSortTimeCreatedD:
            return [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
        case SFSortFreshnessA:
            return [[NSSortDescriptor alloc] initWithKey:@"freshness" ascending:YES];
        case SFSortFreshnessD:
            return [[NSSortDescriptor alloc] initWithKey:@"freshness" ascending:NO];
        default:
            return nil;
    }
}

- (BOOL)saveToDb
{
    NSError *err;
    [self.ctx save:&err];
    if (err) {
        return NO;
    } else {
        return YES;
    }
}

@end
