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
#import "SFBox.h"
#import "NSObject+SFExtra.h"
#import "SFHeader.h"

@interface SFCollectionViewController ()

@property (strong, nonatomic) NSMutableDictionary *dynamicDaysLeftDisplay;
@property (strong, nonatomic) NSMutableDictionary *dynamicDaysLeftDisplayBackGroundViews;
@property (strong, nonatomic) NSMutableDictionary *dynamicDaysLeftDisplaySeparatorViews;
@property (assign, nonatomic) CGFloat lineHeightFrameHeightRatio;
@property (assign, nonatomic) CGFloat maxLineHeight;
@property (assign, nonatomic) CGFloat minLineHeight;

@end

@implementation SFCollectionViewController

@dynamic name;
@dynamic indexTitle;
@dynamic objects;
@dynamic numberOfObjects;

static NSString * const reuseIdentifierCell = @"Bloc";
static NSString * const reuseIdentifierHeader = @"HeaderView";
static CGFloat const minFontSize = 10;
//static CGFloat const picGapToTop = 10;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _dynamicDaysLeftDisplay = [NSMutableDictionary dictionaryWithCapacity:0];
        _dynamicDaysLeftDisplayBackGroundViews = [NSMutableDictionary dictionaryWithCapacity:0];
        _dynamicDaysLeftDisplaySeparatorViews = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.collectionView.frame = [SFBox sharedBox].appRect;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.bounces = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, self.collectionView.frame.size.width / 4, 0, gapToEdgeM);
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.dynamicDaysLeftDisplayBase = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [SFBox sharedBox].appRect.size.width - self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    self.dynamicDaysLeftDisplayBase.backgroundColor = [UIColor clearColor];
    self.dynamicDaysLeftDisplayBase.userInteractionEnabled = NO;
    
    self.maxLineHeight = [SFBox sharedBox].fontL.lineHeight;
    self.minLineHeight = [UIFont fontWithName:[SFBox sharedBox].fontL.fontName size:minFontSize].lineHeight;
    self.lineHeightFrameHeightRatio = 0;
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[SFCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCell];
    [self.collectionView registerClass:[SFHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifierHeader];
    // Do any additional setup after loading the view.
    // There is no way to detect the completion of the loading of all the visible cells. So we set a delay here.
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(addDynamicDaysLeftDisplayBase) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildDynamicDisplays) name:@"rebuildDynamicDisplays" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDynamicDisplays) name:@"refreshDynamicDisplays" object:nil];
}

- (void)addDynamicDaysLeftDisplayBase {
    [self.collectionView.superview insertSubview:self.dynamicDaysLeftDisplayBase belowSubview:self.collectionView];
    [self refreshDynamicDisplays:self.dynamicDaysLeftDisplay inCollectionView:self.collectionView onView:self.dynamicDaysLeftDisplayBase x:gapToEdgeM width:(self.collectionView.frame.size.width / 4 - gapToEdgeM * 2)];
    [self refreshDynamicDisplayBackGroundViews];
    [self refreshDynamicDisplaySeparatorViews];
}

- (void)rebuildDynamicDisplays {
    [self.dynamicDaysLeftDisplay removeAllObjects];
    [self.dynamicDaysLeftDisplayBackGroundViews removeAllObjects];
    [self.dynamicDaysLeftDisplaySeparatorViews removeAllObjects];
    for (UIView *v in self.dynamicDaysLeftDisplayBase.subviews) {
        [v removeFromSuperview];
    }
    [self refreshDynamicDisplays];
}

- (void)refreshDynamicDisplays {
    [self refreshDynamicDisplays:self.dynamicDaysLeftDisplay inCollectionView:self.collectionView onView:self.dynamicDaysLeftDisplayBase x:gapToEdgeM width:(self.collectionView.frame.size.width / 4 - gapToEdgeM * 2)];
    [self adjustAllFontSize:self.dynamicDaysLeftDisplay.allValues];
    [self refreshDynamicDisplayBackGroundViews];
    [self refreshDynamicDisplaySeparatorViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[SFBox sharedBox].fResultsCtl.sections count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([[SFBox sharedBox].fResultsCtl.sections count] == 0) {
        return 0;
    } else {
        id <NSFetchedResultsSectionInfo> s = [SFBox sharedBox].fResultsCtl.sections[section];
        return [s numberOfObjects];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    NSManagedObject *managedObject = [[SFBox sharedBox].fResultsCtl objectAtIndexPath:indexPath];
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
    } else {
        cell.text.attributedText = [self string:[managedObject valueForKey:@"notes"] withBackgroundColor:[SFBox sharedBox].sfGreen0 font:[SFBox sharedBox].fontY];
    }
    if (self.lineHeightFrameHeightRatio == 0) {
        self.lineHeightFrameHeightRatio = self.maxLineHeight / cell.frame.size.height;
    }
    if (indexPath.row + 1 == [self.collectionView numberOfItemsInSection:indexPath.section]) {
        if (indexPath.row == 0) {
            cell.layer.mask = cell.bothMask;
        } else {
            cell.layer.mask = cell.lowerMask;
        }
    } else if (indexPath.row == 0) {
        cell.layer.mask = cell.upperMask;
    }
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SFHeader *h = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifierHeader forIndexPath:indexPath];
        return h;
    }
    return nil;
}

- (CGFloat)aboveItemBottomY:(NSIndexPath *)sectionIndexPath {
    if (sectionIndexPath.section - 1 < 0) {
        return 20;
    } else {
        id <NSFetchedResultsSectionInfo> s = [SFBox sharedBox].fResultsCtl.sections[sectionIndexPath.section - 1];
        NSInteger l = [s numberOfObjects];
        NSIndexPath *p = [NSIndexPath indexPathForItem:(l - 1) inSection:(sectionIndexPath.section - 1)];
        UICollectionViewLayoutAttributes *a = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:p];
        return CGRectGetMaxY(a.frame);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rowSelected" object:self];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat regularH = 10;
    if (section == 0) {
        // This is because we increaed the upper and bottom margins of each section's backgroundView.
        return UIEdgeInsetsMake(20, 0, regularH, 0);
    } else {
        return UIEdgeInsetsMake(regularH, 0, regularH, 0);
    }
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat w = [SFBox sharedBox].appRect.size.width * 3 / 4 - gapToEdgeM;
//    NSManagedObject *managedObject = [[SFBox sharedBox].fResultsCtl objectAtIndexPath:indexPath];
//    if ([[managedObject valueForKey:@"hasPic"] boolValue]) {
//        if ([[managedObject valueForKey:@"notes"] length] > 0) {
//            return CGSizeMake(w, (self.view.frame.size.height - 20) / 4);
//        } else {
//            return CGSizeMake(w, (self.view.frame.size.height - 20) / 5);
//        }
//    } else {
//        return CGSizeMake(w, (self.view.frame.size.height - 20) / 7);
//    }
//}

#pragma mark - Dynamic Display

- (void)refreshDynamicDisplays:(NSMutableDictionary *)currentOnes inCollectionView:(UICollectionView *)view onView:(UIView *)parentView x:(CGFloat)x width:(CGFloat)w {
    NSDictionary *d = [self getVisibaleSectionsLowerYsInCollectionView:view];
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
        if ([currentOnes isEqual:self.dynamicDaysLeftDisplay]) {
            l.frame = [self getDynamicDisplayFrameForSection:s.integerValue inCollectionView:view x:x width:w extraY:0];
        } else {
            l.frame = [self getDynamicDisplayFrameForSection:s.integerValue inCollectionView:view x:x width:w extraY:0];
        }
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
            CGRect f;
            if ([currentOnes isEqual:self.dynamicDaysLeftDisplay]) {
                f = [self getDynamicDisplayFrameForSection:s1.integerValue inCollectionView:view x:x width:w extraY:0];
                UILabel *l = [self getDynamicDisplayLabelWithFrame:f];
                l.text = [[[SFBox sharedBox].fResultsCtl.sections[s1.integerValue] objects][0] valueForKey:@"timeLeftMsg"];
                [self adjustOneFontSize:l];
                [parentView addSubview:l];
                [currentOnes setObject:l forKey:s1];
            } else {
                // UILabel bug on iOS7: http://stackoverflow.com/questions/21065921/uilabel-have-a-weird-grey-top-line-border-in-ios7-how-can-i-remove-it
                f = [self getDynamicDisplayFrameForSection:s1.integerValue inCollectionView:view x:x width:w extraY:0];
                UIView *v = [[UIView alloc] initWithFrame:f];
                [parentView addSubview:v];
                [currentOnes setObject:v forKey:s1];
            }
        }
    }
}

- (void)refreshDynamicDisplaySeparatorViews {
    [self refreshDynamicDisplays:self.dynamicDaysLeftDisplaySeparatorViews inCollectionView:self.collectionView onView:self.dynamicDaysLeftDisplayBase x:self.collectionView.contentInset.left width:self.collectionView.frame.size.width - self.collectionView.contentInset.left];
    for (UIView *v in self.dynamicDaysLeftDisplaySeparatorViews.allValues) {
        //  http://stackoverflow.com/questions/970475/how-to-compare-uicolors
        if (![v.backgroundColor isEqual:[UIColor clearColor]]) {
            v.backgroundColor = [UIColor clearColor];
        }
        v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y + gapToEdgeM + 10, [SFBox sharedBox].appRect.size.width * 3 / 4 - gapToEdgeM, v.frame.size.height - gapToEdgeM * 2 - 10 * 2); // Adjusted the y and height to shrink it a bit to avoid a visual bug which shows s thin line on both vertical ends.
    }
}

- (void)refreshDynamicDisplayBackGroundViews {
    [self refreshDynamicDisplays:self.dynamicDaysLeftDisplayBackGroundViews inCollectionView:self.collectionView onView:self.dynamicDaysLeftDisplayBase x:0 width:self.collectionView.contentInset.left + [(UICollectionViewFlowLayout *)self.collectionViewLayout itemSize].width];
    [self keepDynamicDisplayBackGroundViewsBack];
}

- (void)keepDynamicDisplayBackGroundViewsBack {
    for (UIView *v in self.dynamicDaysLeftDisplayBackGroundViews.allValues) {
        [v.superview sendSubviewToBack:v];
        if (![v.backgroundColor isEqual:[SFBox sharedBox].milkWhite]) {
            v.backgroundColor = [SFBox sharedBox].milkWhite;
        }
        v.backgroundColor = [SFBox sharedBox].milkWhite;
        CAShapeLayer *bothMask = [CAShapeLayer layer];
        bothMask.path = [UIBezierPath bezierPathWithRoundedRect:v.bounds byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)].CGPath;
        v.layer.mask = bothMask;
    }
}

- (CGRect)getDynamicDisplayFrameForSection:(NSInteger)s inCollectionView:(UICollectionView *)view x:(CGFloat)x width:(CGFloat)w extraY:(CGFloat)eY {
    NSDictionary *dUp = [self getVisibaleSectionsUpperYsInCollectionView:view];
    NSDictionary *dLow = [self getVisibaleSectionsLowerYsInCollectionView:view];
    NSNumber *n = [dLow objectForKey:[NSNumber numberWithInteger:s]];
    if (n) {
        CGFloat y1 = [[dUp objectForKey:[NSNumber numberWithInteger:s]] floatValue];
        CGFloat y2 = [[dLow objectForKey:[NSNumber numberWithInteger:s]] floatValue];
        return CGRectMake(x, y1 - view.contentOffset.y - eY, w, y2 - y1 + eY * 2);
    }
    return CGRectZero;
}

- (UILabel *)getDynamicDisplayLabelWithFrame:(CGRect)frame {
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.textAlignment = NSTextAlignmentLeft;
    l.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    l.font = [SFBox sharedBox].fontX;
    l.minimumScaleFactor = 10 / l.font.pointSize;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    l.numberOfLines = 0;
    l.textColor = [SFBox sharedBox].darkText;
    return l;
}

- (NSDictionary *)getVisibaleSectionsUpperYsInCollectionView:(UICollectionView *)view {
    // To get the sections' Ys, we only need the dots between the two ends. We do not need the points of both ends since they are already there. So we assign sectionNo as the key and its lower end point as the object.
    // For consistency purpose, in which we have sectionNo/lower-end-point pair as key/value in the dictionary, we add lower end of the view as the last point.
    NSArray *a = [self ascendSections:[view indexPathsForVisibleItems]];
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    for (NSIndexPath *i in a) {
        if (i.item == 0) {
            UICollectionViewCell *c = [view cellForItemAtIndexPath:i];
            if (c) {
                if (c.frame.origin.y - view.contentOffset.y > 0) {
                    [d setObject:[NSNumber numberWithFloat:CGRectGetMinY(c.frame)] forKey:[NSNumber numberWithInteger:i.section]];
                } else {
                    [d setObject:[NSNumber numberWithFloat:view.contentOffset.y] forKey:[NSNumber numberWithInteger:i.section]];
                }
            }
        } else if ([a indexOfObject:i] == 0) {
            [d setObject:[NSNumber numberWithFloat:view.contentOffset.y] forKey:[NSNumber numberWithInteger:i.section]];
        }
    }
    return d;
}

- (NSDictionary *)getVisibaleSectionsLowerYsInCollectionView:(UICollectionView *)view {
    // To get the sections' Ys, we only need the dots between the two ends. We do not need the points of both ends since they are already there. So we assign sectionNo as the key and its lower end point as the object.
    // For consistency purpose, in which we have sectionNo/lower-end-point pair as key/value in the dictionary, we add lower end of the view as the last point.
    NSArray *a = [self ascendSections:[view indexPathsForVisibleItems]];
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    for (NSIndexPath *i in a) {
        if (i.item == 0 && ![a[0] isEqual:i]) {
            NSIndexPath *j = a[[a indexOfObject:i] - 1];
            UICollectionViewCell *c = [view cellForItemAtIndexPath:j];
            if (c) {
                if (CGRectGetMaxY(c.frame) - view.contentOffset.y > 0) {
                    [d setObject:[NSNumber numberWithFloat:CGRectGetMaxY(c.frame)] forKey:[NSNumber numberWithInteger:j.section]];
                }
            }
        }
        if ([i isEqual:[a lastObject]]) {
            UICollectionViewCell *c = [view cellForItemAtIndexPath:i];
            if ([(id <NSFetchedResultsSectionInfo>)[SFBox sharedBox].fResultsCtl.sections[i.section] numberOfObjects] - 1 > i.item) {
                [d setObject:[NSNumber numberWithFloat:(view.contentOffset.y + view.frame.size.height)] forKey:[NSNumber numberWithInteger:i.section]];
            } else if (view.contentOffset.y + view.frame.size.height > CGRectGetMaxY(c.frame)) {
                [d setObject:[NSNumber numberWithFloat:CGRectGetMaxY(c.frame)] forKey:[NSNumber numberWithInteger:i.section]];
            } else if (view.contentOffset.y + view.frame.size.height <= CGRectGetMaxY(c.frame)) {
                [d setObject:[NSNumber numberWithFloat:(view.contentOffset.y + view.frame.size.height)] forKey:[NSNumber numberWithInteger:i.section]];
            }
        }
    }
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
    for (UILabel *l in labels) {
        [self adjustFontSize:l maxFontSize:[SFBox sharedBox].fontX.pointSize maxHeight:self.maxLineHeight minHeight:self.minLineHeight];
    }
}

- (void)adjustOneFontSize:(UILabel *)l {
    [self adjustFontSize:l maxFontSize:[SFBox sharedBox].fontX.pointSize maxHeight:self.maxLineHeight minHeight:self.minLineHeight];
}

- (void)adjustFontSize:(UILabel *)l maxFontSize:(CGFloat)s maxHeight:(CGFloat)maxH minHeight:(CGFloat)minH {
    if (l.font.lineHeight > l.frame.size.height * self.lineHeightFrameHeightRatio && l.font.lineHeight > minH) {
        if (l.frame.size.height * self.lineHeightFrameHeightRatio <= minH) {
            l.font = [UIFont fontWithName:l.font.fontName size:minFontSize];
        } else {
            for (CGFloat i = l.font.pointSize ; i >= minFontSize; i = i - 0.1) {
                if ([UIFont fontWithName:l.font.fontName size:i].lineHeight <= l.frame.size.height * self.lineHeightFrameHeightRatio && [UIFont fontWithName:l.font.fontName size:i].lineHeight >= minH) {
                    l.font = [UIFont fontWithName:l.font.fontName size:i];
                    break;
                }
            }
        }
    } else if (l.font.lineHeight < l.frame.size.height * self.lineHeightFrameHeightRatio && l.font.lineHeight < maxH) {
        if (l.frame.size.height * self.lineHeightFrameHeightRatio >= maxH) {
            l.font = [SFBox sharedBox].fontX;
        } else {
            for (CGFloat i = s ; i > 0; i = i - 0.1) {
                if ([UIFont fontWithName:l.font.fontName size:i].lineHeight <= l.frame.size.height * self.lineHeightFrameHeightRatio && [UIFont fontWithName:l.font.fontName size:i].lineHeight <= maxH) {
                    l.font = [UIFont fontWithName:l.font.fontName size:i];
                    break;
                }
            }
        }
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshDynamicDisplays];
}


@end
