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

CGFloat const goldenRatio = 1.61803398875;
CGFloat const fontSizeM = 20;
CGFloat const fontSizeL = 38;
CGFloat const gapToEdgeS = 5;
CGFloat const gapToEdgeM = 10;
CGFloat const gapToEdgeL = 15;

@implementation SFBox

@dynamic indexTitle;
@dynamic numberOfObjects;
@dynamic name;
@dynamic objects;

+ (instancetype)sharedBox {
    static SFBox *box = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        box = [[self alloc] init];
    });
    return box;
}

- (id)init
{
    self = [super init];
    if (self) {
        CGRect c = [[UIScreen mainScreen] bounds];
        _appRect = CGRectMake(CGRectGetMinX(c), CGRectGetMinY(c), CGRectGetWidth(c), CGRectGetHeight(c));
        _sortSelection = [NSMutableArray arrayWithCapacity:0];
        [_sortSelection addObject:[NSNumber numberWithInteger:SFSortDaysLeftA]];
        [_sortSelection addObject:[NSNumber numberWithInteger:SFSortFreshnessD]];
        [_sortSelection addObject:[NSNumber numberWithInteger:SFSortTimeCreatedD]];
        _warningText = [[NSMutableString alloc] init];
        _fontM = [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSizeM];
        _fontL = [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSizeL];
        CGFloat alpha = 1;
        // http://stackoverflow.com/questions/10496114/uitextfield-placeholder-font-color-white-ios-5
        _placeholderFontColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.098/255.0 alpha:0.22];
        _sfGreen0 = [UIColor colorWithRed:152 / 255.0 green:221 / 255.0 blue:120 / 255.0 alpha:alpha];
        _sfGreen1 = [UIColor colorWithRed:150 / 255.0 green:206 / 255.0 blue:107 / 255.0 alpha:alpha];
        _sfGreen2 = [UIColor colorWithRed:152 / 255.0 green:189 / 255.0 blue:93 / 255.0 alpha:alpha];
        _sfGray = [UIColor colorWithRed:130 / 255.0 green:131 / 255.0 blue:126 / 255.0 alpha:alpha];
        _sfGreen0Highlighted = [self.sfGreen0 colorWithAlphaComponent:0.1];
        _hintIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"HintIsOn"];
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
    NSNotification *nn = [NSNotification notificationWithName:@"itemsChange" object:self userInfo:d];
//    [[NSNotificationCenter defaultCenter] postNotification:nn];
    NSNotification *n = [NSNotification notificationWithName:@"runTableChange" object:self userInfo:d];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:0];
    [d setValue:[NSNumber numberWithUnsignedInteger:sectionIndex] forKey:@"sectionIndex"];
    [d setValue:[NSNumber numberWithUnsignedInteger:type] forKey:@"type"];
    NSNotification *n = [NSNotification notificationWithName:@"sectionsChange" object:self userInfo:d];
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
