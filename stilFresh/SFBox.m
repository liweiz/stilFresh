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
@synthesize sfGreen0Highlighted;
@synthesize sfGreen0;
@synthesize sfGreen1;
@synthesize sfGreen2;
@synthesize sfGray;
@synthesize imgJustSaved;
@synthesize imgNameJustSaved;
@synthesize goldenRatio;
@synthesize gapToEdgeS;
@synthesize gapToEdgeM;
@synthesize gapToEdgeL;
@synthesize placeholderFontColor;
@synthesize hintIsOn;
@synthesize fontM;
@synthesize fontL;

- (id)init
{
    self = [super init];
    if (self) {
        self.sortSelection = [NSMutableArray arrayWithCapacity:0];
        [self.sortSelection addObject:[NSNumber numberWithInteger:SFSortDaysLeftA]];
        [self.sortSelection addObject:[NSNumber numberWithInteger:SFSortFreshnessD]];
        [self.sortSelection addObject:[NSNumber numberWithInteger:SFSortTimeCreatedD]];
//        [self.sortSelection addObject:[NSNumber numberWithInteger:SFSortCellTextAlphabetA]];
        self.warningText = [[NSMutableString alloc] init];
        self.gapToEdgeS = 5;
        self.gapToEdgeM = 10;
        self.gapToEdgeL = 15;
        self.fontSizeM = 20;
        self.fontSizeL = 38;
        self.fontM = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.fontSizeM];
        self.fontL = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.fontSizeL];
        CGFloat alpha = 1;
        // http://stackoverflow.com/questions/10496114/uitextfield-placeholder-font-color-white-ios-5
        self.placeholderFontColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.098/255.0 alpha:0.22];
        self.sfGreen0 = [UIColor colorWithRed:152 / 255.0 green:221 / 255.0 blue:120 / 255.0 alpha:alpha];
        self.sfGreen1 = [UIColor colorWithRed:150 / 255.0 green:206 / 255.0 blue:107 / 255.0 alpha:alpha];
        self.sfGreen2 = [UIColor colorWithRed:152 / 255.0 green:189 / 255.0 blue:93 / 255.0 alpha:alpha];
        self.sfGray = [UIColor colorWithRed:130 / 255.0 green:131 / 255.0 blue:126 / 255.0 alpha:alpha];
        self.sfGreen0Highlighted = [self.sfGreen0 colorWithAlphaComponent:0.1];
        self.goldenRatio = 1.61803398875;
        self.hintIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"HintIsOn"];
    }
    return self;
}

- (void)switchHint
{
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    if (self.hintIsOn) {
        self.hintIsOn = NO;
        [u setBool:NO forKey:@"HintIsOn"];
    } else {
        self.hintIsOn = YES;
        [u setBool:YES forKey:@"HintIsOn"];
    }
}

- (void)prepareDataSource {
    if (!self.fReq) {
        self.fReq = [NSFetchRequest fetchRequestWithEntityName:@"SFItem"];
    }
    self.fReq.sortDescriptors = [self sortOption:self.sortSelection];
    // Config fetchResultController
    self.fResultsCtl = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fReq managedObjectContext:self.ctx sectionNameKeyPath:@"timeLeftMsg" cacheName:nil];
    self.fResultsCtl.delegate = self;
    [self.fResultsCtl performFetch:nil];
    [self refreshDb];
}

- (void)refreshDb {
    for (SFItem *i in self.fResultsCtl.fetchedObjects) {
        [self resetDaysLeft:i];
        [self resetFreshness:i];
    }
    if (![self saveToDb]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"generalError" object:self];
    } else {
        
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
    [d setValue:[NSNumber numberWithBool:NO] forKey:@"isForSection"];
    NSNotification *n = [NSNotification notificationWithName:@"runTableChange" object:self userInfo:d];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setValue:sectionInfo forKey:@"sectionInfo"];
    [d setValue:[NSNumber numberWithUnsignedInteger:sectionIndex] forKey:@"sectionIndex"];
    [d setValue:[NSNumber numberWithUnsignedInteger:type] forKey:@"type"];
    [d setValue:[NSNumber numberWithBool:YES] forKey:@"isForSection"];
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
            return [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
        case SFSortTimeCreatedD:
            return [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
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
