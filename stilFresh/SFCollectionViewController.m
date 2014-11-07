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

@interface SFCollectionViewController ()

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
    self.collectionView.backgroundColor = [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[SFCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCell];
    [self.collectionView registerClass:[SFHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseIdentifierHeader];
    // Do any additional setup after loading the view.
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
    cell.text.text = [managedObject valueForKey:@"notes"];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SFHeader *h = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseIdentifierHeader forIndexPath:indexPath];
//        UICollectionViewLayoutAttributes *a = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        h.frame = CGRectMake(0, [self aboveItemBottomY:indexPath], [SFBox sharedBox].appRect.size.width, 100);
        id <NSFetchedResultsSectionInfo> s = [SFBox sharedBox].fResultsCtl.sections[indexPath.section];
        h.text.text = [s name];
        NSLog(@"h.text.text: %@", h.text.text);
        h.backgroundColor = [UIColor greenColor];
        h.text.textColor = [UIColor whiteColor];
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

@end
