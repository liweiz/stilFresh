//
//  NSObject+SFExtra.h
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-28.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFBox.h"
#import "SFItem.h"

@interface NSObject (SFExtra)

- (UICollectionViewFlowLayout *)getLayout;

- (NSIndexPath *)keyForIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)stringToDate:(NSString *)string;
- (NSArray *)getDateElemFromString:(NSString *)string;
- (NSString *)combineToGetStringDate:(NSDateComponents *)c;
- (NSString *)dateToString:(NSDate *)date;
- (NSInteger)getDaysLeftFrom:(NSDate *)start to:(NSDate *)end;
- (BOOL)validateDateInput:(NSString *)input;
- (BOOL)validateNotesInput:(NSString *)input;

- (void)configLayer:(CALayer *)layer box:(SFBox *)b isClear:(BOOL)isClear;

- (void)resetDaysLeft:(SFItem *)obj;

// Four scales correspond to four colors: 0: green0, 1: green1, 2: green2, 3: gray.
- (void)resetFreshness:(SFItem *)obj;
- (NSString *)addHyphensToDateString:(NSString *)date;
- (NSAttributedString *)convertDaysLeftToSemanticText:(NSInteger)i font:(UIFont *)f shadowColor:(UIColor *)c;
- (void)addCommonFontEff:(NSMutableAttributedString *)s shadowColor:(UIColor *)c;
- (UIImage *)convertImageToGrayscale:(UIImage *)image;
- (NSNumber *)rankDaysLeft:(NSInteger)i;

- (NSURL *)getFileBaseUrl;
- (NSString *)displayDateString:(NSString *)date;
- (NSString *)displayMonthString:(NSString *)date;
- (NSString *)displayDayString:(NSString *)date;
- (NSString *)displayBBWithIntro:(NSString *)date;

- (UIColor *)getStatusColor:(NSInteger)statusCode;

@end
