//
//  SFCollectionViewController.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-04.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFCollectionViewController.h"
#import "SFCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SFHeader.h"
#import "SFBox.h"
#import "NSObject+SFExtra.h"

@interface SFCollectionViewController ()

@property (strong, nonatomic) NSMutableDictionary *dynamicDaysLeftDisplay;

@end

@implementation SFCollectionViewController

@dynamic name;
@dynamic indexTitle;
@dynamic objects;
@dynamic numberOfObjects;

static NSString * const reuseIdentifierCell = @"Bloc";
static NSString * const reuseIdentifierHeader = @"HeaderView";

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _dynamicDaysLeftDisplay = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    CGFloat x = ([SFBox sharedBox].appRect.size.width + gapToEdgeS) * 2;
    self.collectionView.frame = CGRectMake(x, 0, [SFBox sharedBox].appRect.size.width, [SFBox sharedBox].appRect.size.height);
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.bounces = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dynamicDaysLeftDisplayBase = [[UIView alloc] initWithFrame:self.collectionView.frame];
    self.dynamicDaysLeftDisplayBase.backgroundColor = [UIColor clearColor];
    self.dynamicDaysLeftDisplayBase.userInteractionEnabled = NO;
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[SFCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCell];
//    [self.collectionView registerClass:[SFHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifierHeader];
    // Do any additional setup after loading the view.
    // There is no way to detect the completion of the loading of all the visible cells. So we set a delay here.
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(addDynamicDaysLeftDisplayBase) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
}

- (void)addDynamicDaysLeftDisplayBase {
    [self.collectionView.superview addSubview:self.dynamicDaysLeftDisplayBase];
    [self refreshDynamicDisplays:self.dynamicDaysLeftDisplay inCollectionView:self.collectionView];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[SFBox sharedBox].fResultsCtl.sections count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> s = [SFBox sharedBox].fResultsCtl.sections[section];
    return [s numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    NSManagedObject *managedObject = [[SFBox sharedBox].fResultsCtl objectAtIndexPath:indexPath];
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
    cell.contentView.backgroundColor = [self getStatusColor:cell.statusCode];
    cell.text.text = [managedObject valueForKey:@"notes"];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        SFHeader *h = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifierHeader forIndexPath:indexPath];
////        UICollectionViewLayoutAttributes *a = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
////        h.frame = CGRectMake(0, [self aboveItemBottomY:indexPath], [SFBox sharedBox].appRect.size.width, 30);
//        id <NSFetchedResultsSectionInfo> s = [SFBox sharedBox].fResultsCtl.sections[indexPath.section];
//        h.text.text = [s name];
//        NSLog(@"h.text.text: %@", h.text.text);
//        NSLog(@"h.frame.origin.y: %f", h.frame.origin.y);
//        return h;
//    }
//    return nil;
//}
//
//- (CGFloat)aboveItemBottomY:(NSIndexPath *)sectionIndexPath {
//    if (sectionIndexPath.section - 1 < 0) {
//        return 20;
//    } else {
//        id <NSFetchedResultsSectionInfo> s = [SFBox sharedBox].fResultsCtl.sections[sectionIndexPath.section - 1];
//        NSInteger l = [s numberOfObjects];
//        NSIndexPath *p = [NSIndexPath indexPathForItem:(l - 1) inSection:(sectionIndexPath.section - 1)];
//        UICollectionViewLayoutAttributes *a = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:p];
//        return CGRectGetMaxY(a.frame);
//    }
//}

#pragma mark - Dynamic Display

- (void)refreshDynamicDisplays:(NSMutableDictionary *)currentOnes inCollectionView:(UICollectionView *)view {
    NSDictionary *d = [self getVisibaleSectionsYsInCollectionView:view];
    // Remove ones not needed
    for (NSNumber *s1 in currentOnes.allKeys) {
        BOOL matched = NO;
        for (NSNumber *s2 in d.allKeys) {
            if ([s1 isEqualToNumber:s2]) {
                matched = YES;
                break;
            }
        }
        if (!matched) {
            [(UILabel *)[currentOnes objectForKey:s1] removeFromSuperview];
            [currentOnes removeObjectForKey:s1];
        }
    }
    // Update frame for exsiting ones
    for (NSNumber *s in currentOnes.allKeys) {
        UILabel *l = [currentOnes objectForKey:s];
        NSLog(@"frame: %@", NSStringFromCGRect([self getDynamicDisplayFrameForSection:s.integerValue inCollectionView:view]));
        l.frame = [self getDynamicDisplayFrameForSection:s.integerValue inCollectionView:view];
    }
    // Add new ones
    for (NSNumber *s1 in d.allKeys) {
        BOOL matched = NO;
        for (NSNumber *s2 in currentOnes.allKeys) {
            if ([s1 isEqualToNumber:s2]) {
                matched = YES;
                break;
            }
        }
        if (!matched) {
            CGRect f = [self getDynamicDisplayFrameForSection:s1.integerValue inCollectionView:view];
            NSLog(@"frame: %@", NSStringFromCGRect(f));
            UILabel *l = [self getDynamicDisplayWithFrame:f];
            [self adjustOneFontSize:l];
            l.text = [[SFBox sharedBox].fResultsCtl.sections[s1.integerValue] name];
            [self.dynamicDaysLeftDisplayBase addSubview:l];
            [currentOnes setObject:l forKey:s1];
        }
    }
    
}

- (CGRect)getDynamicDisplayFrameForSection:(NSInteger)s inCollectionView:(UICollectionView *)view {
    NSDictionary *d = [self getVisibaleSectionsYsInCollectionView:view];
    if ([d.allKeys count] == 0) {
        return CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    } else {
        NSNumber *x = [d objectForKey:[NSNumber numberWithInteger:s]];
        if (x) {
            NSArray *a = [d.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 integerValue] > [obj2 integerValue]) {
                    return NSOrderedDescending;
                } else if ([obj1 integerValue] < [obj2 integerValue]) {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            if (s == [a[0] integerValue]) {
                CGFloat y = [[d objectForKey:a[0]] floatValue];
                return CGRectMake(0, 0, view.frame.size.width, y - view.contentOffset.y);
            } else {
                CGFloat y1 = [[d objectForKey:[NSNumber numberWithInteger:(s - 1)]] floatValue];
                CGFloat y2 = [[d objectForKey:[NSNumber numberWithInteger:s]] floatValue];
                return CGRectMake(0, y1 - view.contentOffset.y, view.frame.size.width, y2 - y1);
            }
        } else {
            for (NSNumber *n in d.allKeys) {
                if (s - 1 == n.integerValue) {
                    CGFloat y = [[d objectForKey:n] floatValue];
                    return CGRectMake(0, y - view.contentOffset.y, view.frame.size.width, view.frame.size.height - (y - view.contentOffset.y));
                }
            }
        }
    }
    return CGRectZero;
}

- (UILabel *)getDynamicDisplayWithFrame:(CGRect)frame {
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.backgroundColor = [UIColor clearColor];
    l.textAlignment = NSTextAlignmentCenter;
    l.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    l.font = [SFBox sharedBox].fontL;
    l.minimumScaleFactor = 10 / l.font.pointSize;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    l.numberOfLines = 0;
//    l.adjustsFontSizeToFitWidth = YES;
    l.alpha = 0.5;
    l.textColor = [UIColor blackColor];
    l.layer.borderColor = [UIColor redColor].CGColor;
    l.layer.borderWidth = 2;
    return l;
}

- (NSDictionary *)getVisibaleSectionsYsInCollectionView:(UICollectionView *)view {
    // To get the sections' Ys, we only need the dots between the two ends. We do not need the points of both ends since they are already there. So we assign sectionNo as the key and its lower end point as the object.
    // For consistency purpose, in which we have sectionNo/lower-end-point pair as key/value in the dictionary, we add lower end of the view as the last point.
    NSArray *a = [self ascendSections:[view indexPathsForVisibleItems]];
    NSLog(@"array: %@", a);
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    for (NSIndexPath *i in a) {
        if ([a indexOfObject:i] + 1 < [a count]) {
            NSIndexPath *j = a[[a indexOfObject:i] + 1];
            if (i.section < j.section) {
                UICollectionViewCell *c = [view cellForItemAtIndexPath:i];
                [d setObject:[NSNumber numberWithFloat:CGRectGetMaxY(c.frame)] forKey:[NSNumber numberWithInteger:i.section]];
            }
        } else {
            // Last item visible
            UICollectionViewCell *c = [view cellForItemAtIndexPath:i];
            if (CGRectGetMaxY(c.frame) - view.contentOffset.y < CGRectGetHeight(c.frame)) {
                // Lower edge is the bottomline of the cell
                [d setObject:[NSNumber numberWithFloat:CGRectGetMaxY(c.frame)] forKey:[NSNumber numberWithInteger:i.section]];
            } else {
                // Lower edge is the bottomline of the view
                [d setObject:[NSNumber numberWithFloat:(view.frame.size.height + view.contentOffset.y)] forKey:[NSNumber numberWithInteger:i.section]];
            }
        }
    }
    
    NSLog(@"dic: %@", d);
    return d;
}

- (NSArray *)ascendSections:(NSArray *)indexPaths {
    return [indexPaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger s1 = [obj1 section];
        NSInteger s2 = [obj2 section];
        NSInteger r1 = [obj1 row];
        NSInteger r2 = [obj2 row];
        if (s1 == s2) {
            if (r1 > r2) {
                return (NSComparisonResult)NSOrderedDescending;
            } else if (r1 < r2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        } else if (s1 < s2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedDescending;
    }];
}

#pragma mark - Adjust Font Size

- (void)adjustAllFontSize:(NSArray *)labels {
    CGFloat m = [SFBox sharedBox].fontL.pointSize;
    CGFloat maxH = [SFBox sharedBox].fontL.lineHeight;
    CGFloat minH = [UIFont fontWithName:[SFBox sharedBox].fontL.fontName size:20].lineHeight;
    for (UILabel *l in labels) {
        [self adjustFontSize:l maxFontSize:m maxHeight:maxH minHeight:minH];
    }
}

- (void)adjustOneFontSize:(UILabel *)l {
    CGFloat m = [SFBox sharedBox].fontL.pointSize;
    CGFloat maxH = [SFBox sharedBox].fontL.lineHeight;
    CGFloat minH = [UIFont fontWithName:[SFBox sharedBox].fontL.fontName size:20].lineHeight;
    [self adjustFontSize:l maxFontSize:m maxHeight:maxH minHeight:minH];
}

- (void)adjustFontSize:(UILabel *)l maxFontSize:(CGFloat)s maxHeight:(CGFloat)maxH minHeight:(CGFloat)minH {
    if (l.font.lineHeight > l.frame.size.height / 2.5 && l.font.lineHeight >= minH) {
        for (CGFloat i = l.font.pointSize ; i > 0; i = i - 0.1) {
            UIFont *f = [UIFont fontWithName:l.font.fontName size:i];
            if (f.lineHeight < l.frame.size.height / 2.5 && f.lineHeight >= minH) {
                l.font = f;
                break;
            }
        }
    } else if (l.font.lineHeight <= l.frame.size.height / 2.5 && l.font.lineHeight <= maxH) {
        for (CGFloat i = s ; i > 0; i = i - 0.1) {
            UIFont *f = [UIFont fontWithName:l.font.fontName size:i];
            if (f.lineHeight < l.frame.size.height / 2.5 && f.lineHeight <= maxH) {
                l.font = f;
                break;
            }
        }
    } else if (l.font.)
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshDynamicDisplays:self.dynamicDaysLeftDisplay inCollectionView:self.collectionView];
    [self adjustAllFontSize:self.dynamicDaysLeftDisplay.allValues];
//    for (UILabel *l in self.dynamicDaysLeftDisplay.allValues) {
//        NSLog(@"frame: %@", NSStringFromCGRect(l.frame));
//    }
//    [self.dynamicDaysLeftDisplayBase setNeedsDisplay];
}


@end
