//
//  NSObject+SFExtra.m
//  kipFresh
//
//  Created by Liwei Zhang on 2014-09-28.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "NSObject+SFExtra.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSObject (SFExtra)

- (UICollectionViewFlowLayout *)getLayout {
    UICollectionViewFlowLayout *l = [[UICollectionViewFlowLayout alloc] init];
    l.minimumInteritemSpacing = 0;
    l.minimumLineSpacing = 8;
    CGFloat w = [SFBox sharedBox].appRect.size.width * 3 / 4 - gapToEdgeM;
    l.itemSize = CGSizeMake(w, w / (goldenRatio + 1));
    l.scrollDirection = UICollectionViewScrollDirectionVertical;
    return l;
}

// http://stackoverflow.com/questions/18919459/ios-7-beginupdates-endupdates-inconsistent/18920573#18920573
- (NSIndexPath *)keyForIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath class] == [NSIndexPath class]) {
        return indexPath;
    }
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
}

#pragma mark - convert number to semantic text
- (NSAttributedString *)convertDaysLeftToSemanticText:(NSInteger)i font:(UIFont *)f shadowColor:(UIColor *)c {
    NSString *s;
    NSRange r1 = NSMakeRange(0, 0);
    NSRange r2 = NSMakeRange(0, 0);
    if (i < 1) {
        s = @"No longer fresh";
    } else if (i == 1) {
        s = @"1 day\nleft";
    } else if (i < 7) {
        s = [NSString stringWithFormat:@"%ld days\nleft", (long)i];
    } else if (i < 11) {
        s = @"About\n1 week\nleft";
    } else if (i < 25) {
        s = [NSString stringWithFormat:@"About\n%ld weeks\nleft", (long)(i / 7.0)];
    } else if (i < 35) {
        s = [NSString stringWithFormat:@"About\n1 month\nleft"];
    } else if (i < 30 * 6 - 15) {
        s = [NSString stringWithFormat:@"About\n%ld months\nleft", (long)(i / 30.0)];
    } else if (i < 30 * 6 + 15) {
        s = [NSString stringWithFormat:@"About\nhalf year\nleft"];
    } else if (i < 30 * 12 - 15) {
        s = [NSString stringWithFormat:@"About\n%ld months\nleft", (long)(i / 30.0)];
    } else if (i < 30 * 12 + 15) {
        s = [NSString stringWithFormat:@"About\n1 year\nleft"];
    } else if (i < 365 * 2) {
        s = [NSString stringWithFormat:@"Over\n1 year\nleft"];
    } else {
        s = [NSString stringWithFormat:@"Over\n%ld years\nleft", (long)floorf(i / 365.0)];
    }
    if ([self haveSubString:@"About" inString:s]) {
        r1 = NSMakeRange(0, 5);
    } else if ([self haveSubString:@"Over" inString:s]){
        r1 = NSMakeRange(0, 4);
    } else if ([self haveSubString:@"Best before date" inString:s]) {
        r1 = NSMakeRange(0, 16);
    }
    if ([s containsString:@"left"]) {
        r2 = NSMakeRange(s.length - 4, 4);
    }
    NSMutableAttributedString * r = [[NSMutableAttributedString alloc] initWithString:s];
    if (f) {
        UIFont *ff = [UIFont fontWithName:f.familyName size:f.pointSize * 0.4];
        if (r1.length > 0) {
            [r addAttribute:NSFontAttributeName value:ff range:r1];
        }
        if (r2.length > 0) {
            [r addAttribute:NSFontAttributeName value:ff range:r2];
        }
        NSRange rd = NSMakeRange(r1.location + r1.length, r.length - r1.length - r2.length);
        [r addAttribute:NSFontAttributeName value:f range:rd];
    }
    if (c) {
        [self addCommonFontEff:r shadowColor:c];
    }
    return r;
}

- (NSAttributedString *)string:(NSString *)s withBackgroundColor:(UIColor *)c font:(UIFont *)f {
    NSMutableAttributedString * r = [[NSMutableAttributedString alloc] initWithString:s];
    NSRange a = NSMakeRange(0, s.length);
    [r addAttribute:NSFontAttributeName value:f range:a];
    [r addAttribute:NSBackgroundColorAttributeName value:c range:a];
    return r;
}

- (BOOL)haveSubString:(NSString *)s inString:(NSString *)x {
    if ([x rangeOfString:s].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (NSString *)convertDaysLeftToSemanticText:(NSInteger)i {
    NSString *s;
    if (i < 1) {
        s = @"No longer fresh";
    } else if (i == 1) {
        s = @"1 day left";
    } else if (i < 7) {
        s = [NSString stringWithFormat:@"%ld days left", (long)i];
    } else if (i < 11) {
        s = @"About 1 week left";
    } else if (i < 25) {
        s = [NSString stringWithFormat:@"About %ld weeks left", (long)(i / 7.0)];
    } else if (i < 35) {
        s = [NSString stringWithFormat:@"About 1 month left"];
    } else if (i < 30 * 6 - 15) {
        s = [NSString stringWithFormat:@"About %ld months left", (long)(i / 30.0)];
    } else if (i < 30 * 6 + 15) {
        s = [NSString stringWithFormat:@"About half year left"];
    } else if (i < 30 * 12 - 15) {
        s = [NSString stringWithFormat:@"About %ld months left", (long)(i / 30.0)];
    } else if (i < 30 * 12 + 15) {
        s = [NSString stringWithFormat:@"About 1 year left"];
    } else if (i < 365 * 2) {
        s = [NSString stringWithFormat:@"Over 1 year left"];
    } else {
        s = [NSString stringWithFormat:@"Over %ld years left", (long)floorf(i / 365.0)];
    }
    return s;
}

- (NSNumber *)rankDaysLeft:(NSInteger)i {
    NSInteger s = 99999;
    if (i < 1) {
        s = 0; // No longer fresh
    } else if (i < 7) {
        s = 10 + i; // i day(s) left
    } else if (i < 11) {
        s = 20 + 1; // About 1 week left
    } else if (i < 25) {
        NSInteger j = [NSString stringWithFormat:@"%ld", (long)(i / 7.0)].integerValue;
        s = 20 + j; // About j weeks left
    } else if (i < 35) {
        s = 30 + 1; // About 1 month left
    } else if (i < 30 * 6 - 15) {
        NSInteger j = [NSString stringWithFormat:@"%ld", (long)(i / 30.0)].integerValue;
        s = 40 + j; // About j months left
    } else if (i < 30 * 6 + 15) {
        s = 50; // About half year left
    } else if (i < 30 * 12 - 15) {
        NSInteger j = [NSString stringWithFormat:@"%ld", (long)(i / 30.0)].integerValue;
        s = 50 + j; // About j months left
    } else if (i < 30 * 12 + 15) {
        s = 70; // About 1 year left
    } else if (i < 365 * 2) {
        s = 71; // Over 2 years left
    } else {
        NSInteger j = [NSString stringWithFormat:@"%ld", (long)floorf(i / 365.0)].integerValue;
        s = 80 + j; // Over j years left
    }
    return [NSNumber numberWithInteger:s];
}

- (void)addCommonFontEff:(NSMutableAttributedString *)s shadowColor:(UIColor *)c {
    [s addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, s.length)];
//    NSShadow *h = [[NSShadow alloc] init];
//    h.shadowColor = c;
//    h.shadowOffset = CGSizeMake(0, 0);
//    h.shadowBlurRadius = 1;
//    [s addAttribute:NSShadowAttributeName value:h range:NSMakeRange(0, s.length)];
}

#pragma mark - config layer

- (void)configLayer:(CALayer *)layer box:(SFBox *)b isClear:(BOOL)isClear
{
    if (isClear) {
        CALayer *bottomLine = [CALayer layer];
        CGFloat lineHeight = 1;
        bottomLine.frame = CGRectMake(0, layer.bounds.size.height - lineHeight, layer.bounds.size.width, lineHeight);
        bottomLine.backgroundColor = b.sfGreen0.CGColor;
        [layer addSublayer:bottomLine];
    } else {
        layer.cornerRadius = 3;
    }
}

#pragma mark - reset dynamic properties in db

- (void)resetDaysLeft:(SFItem *)obj
{
    NSInteger d = [self getDaysLeftFrom:[NSDate date] to:[self stringToDate:[obj valueForKey:@"bestBefore"]]];
    NSNumber *n = [NSNumber numberWithInteger:d];
    [obj setValue:n forKey:@"daysLeft"];
    [obj setValue:[self resetTimeLeftMsg:[obj valueForKey:@"daysLeft"]] forKey:@"timeLeftMsg"];
    [obj setValue:[self rankDaysLeft:[n integerValue]] forKey:@"timeLeftMsgRank"];
}

- (NSString *)resetTimeLeftMsg:(NSNumber *)daysLeft
{
    return [self convertDaysLeftToSemanticText:[daysLeft integerValue]];
}

// Four scales correspond to four colors: 0: green0, 1: green1, 2: green2, 3: gray.
- (void)resetFreshness:(SFItem *)obj
{
    NSInteger f = [[obj valueForKey:@"daysLeft"] integerValue];
    NSInteger d = [self getDaysLeftFrom:[self stringToDate:[obj valueForKey:@"dateAdded"]] to:[self stringToDate:[obj valueForKey:@"bestBefore"]]];
    CGFloat r1 = d / 3.0;
    CGFloat r2 = d * 2.0 / 3;
    NSNumber *n;
    if (d == 1) {
        n = [NSNumber numberWithInteger:1];
    } else if (d == 2) {
        if (f == 2) {
            n = [NSNumber numberWithInteger:0];
        } else if (f == 1) {
            n = [NSNumber numberWithInteger:2];
        }
    } else if (f <= 0) {
        n = [NSNumber numberWithInteger:3];
    } else if (f <= floorf(r1)) {
        n = [NSNumber numberWithInteger:2];
    } else if (f <= floorf(r2)) {
        n = [NSNumber numberWithInteger:1];
    } else {
        n = [NSNumber numberWithInteger:0];
    }
    [obj setValue:n forKey:@"freshness"];
}

#pragma mark - string / date conversion

- (NSDate *)stringToDate:(NSString *)string
{
    NSArray *a = [self getDateElemFromString:string];
    if (a) {
        NSDateComponents *c = [[NSDateComponents alloc] init];
        [c setTimeZone:[NSTimeZone localTimeZone]];
        [c setCalendar:[NSCalendar currentCalendar]];
        NSString *year = a[0];
        NSString *month = a[1];
        NSString *day = a[2];
        [c setYear:year.integerValue];
        [c setMonth:month.integerValue];
        [c setDay:day.integerValue];
        return [[NSCalendar currentCalendar] dateFromComponents:c];
    }
    return nil;
}

- (NSArray *)getDateElemFromString:(NSString *)string
{
    if ([self validateDateInput:string]) {
        NSString *year = [string substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [string substringWithRange:NSMakeRange(4, 2)];
        if (month.integerValue < 1 || month.integerValue > 12) {
            // Incorrect data
            return nil;
        }
        NSString *day = [string substringWithRange:NSMakeRange(6, 2)];
        if (day.integerValue < 1 || day.integerValue > 31) {
            // Incorrect data
            return nil;
        }
        return [NSArray arrayWithObjects:year, month, day, nil];
    }
    return nil;
}

- (NSString *)combineToGetStringDate:(NSDateComponents *)c
{
    NSString *year = [NSString stringWithFormat:@"%li", (long)c.year];
    NSString *month = [NSString stringWithFormat:@"%ld", (long)c.month];
    NSString *day = [NSString stringWithFormat:@"%ld", (long)c.day];
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    [s appendString:year];
    if (c.month < 10) {
        [s appendString:@"0"];
    }
    [s appendString:month];
    if (c.day < 10) {
        [s appendString:@"0"];
    }
    [s appendString:day];
    return s;
}

- (NSString *)dateToString:(NSDate *)date
{
    NSCalendar *x = [NSCalendar currentCalendar];
    // http://stackoverflow.com/questions/3385552/nsdatecomponents-componentsfromdate-and-time-zones
    x.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents *c = [x
                           components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                           fromDate:date];
    return [self combineToGetStringDate:c];
}

- (NSInteger)getDaysLeftFrom:(NSDate *)start to:(NSDate *)end
{
    NSDateComponents *c = [[NSCalendar currentCalendar]
                           components:NSCalendarUnitDay
                           fromDate:start toDate:end options:0];
    return c.day;
}

- (NSString *)addHyphensToDateString:(NSString *)date
{
    NSMutableString *s = [NSMutableString stringWithString:date];
    [s insertString:@"-" atIndex:4];
    [s insertString:@"-" atIndex:7];
    return s;
}

- (NSString *)displayBBWithIntro:(NSString *)date
{
    return [[[@"Best before:\n" stringByAppendingString:[self displayDateString:date]] stringByAppendingString:@", "] stringByAppendingString:[date substringWithRange:NSMakeRange(0, 4)]];
}

- (NSString *)displayDateString:(NSString *)date
{
    NSString *mm = [date substringWithRange:NSMakeRange(4, 2)];
    NSString *m;
    switch (mm.integerValue) {
        case 1:
            m = @"Jan.";
            break;
        case 2:
            m = @"Feb.";
            break;
        case 3:
            m = @"Mar.";
            break;
        case 4:
            m = @"Apr.";
            break;
        case 5:
            m = @"May";
            break;
        case 6:
            m = @"Jun.";
            break;
        case 7:
            m = @"Jul.";
            break;
        case 8:
            m = @"Aug.";
            break;
        case 9:
            m = @"Sep.";
            break;
        case 10:
            m = @"Oct.";
            break;
        case 11:
            m = @"Nov.";
            break;
        case 12:
            m = @"Dec.";
            break;
        default:
            break;
    }
    if (m) {
        return [[m stringByAppendingString:@" "] stringByAppendingString:[date substringWithRange:NSMakeRange(6, 2)]];
    }
    return nil;
}

- (NSString *)displayMonthString:(NSString *)date
{
    NSString *mm = [date substringWithRange:NSMakeRange(4, 2)];
    NSString *m;
    switch (mm.integerValue) {
        case 1:
            m = @"Jan";
            break;
        case 2:
            m = @"Feb";
            break;
        case 3:
            m = @"Mar";
            break;
        case 4:
            m = @"Apr";
            break;
        case 5:
            m = @"May";
            break;
        case 6:
            m = @"Jun";
            break;
        case 7:
            m = @"Jul";
            break;
        case 8:
            m = @"Aug";
            break;
        case 9:
            m = @"Sep";
            break;
        case 10:
            m = @"Oct";
            break;
        case 11:
            m = @"Nov";
            break;
        case 12:
            m = @"Dec";
            break;
        default:
            m = @"";
            break;
    }
    return m;
}

- (NSString *)displayDayString:(NSString *)date
{
    return [date substringWithRange:NSMakeRange(6, 2)];
}

#pragma mark - validate input
- (BOOL)validateDateInput:(NSString *)input
{
    NSSet *n = [NSSet setWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", nil];
    if (input.length == 8) {
        for (NSUInteger i = 0; i < 8; i++) {
            NSString *x = [input substringWithRange:NSMakeRange(i, 1)];
            BOOL isNumber = NO;
            for (NSString *s in n) {
                if ([x isEqualToString:s]) {
                    isNumber = YES;
                    break;
                }
            }
            if (!isNumber) {
                break;
            }
            if ([[input substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"0"]) {
                return NO;
            }
            if (isNumber && i == 7) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)validateNotesInput:(NSString *)input
{
    if (input.length <= 144) {
        return YES;
    }
    return NO;
}

-(UIImage*)getGrayImage:(UIImage*)sourceImage
{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,(CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

// Modified from http://stackoverflow.com/questions/22422480/apply-black-and-white-filter-to-uiimage
- (UIImage *)convertImageToGrayscale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect;
    if (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight) {
        // For app only allows portrait usage like this one, this is the only possibility.
        imageRect = CGRectMake(0, 0, image.size.height, image.size.width);
    } else {
        // Not test yet.
        imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // http://stackoverflow.com/questions/18921703/implicit-conversion-from-enumeration-type-enum-cgimagealphainfo-to-different-e
    // Create bitmap content with new image size and grayscale colorspace. Use the new size to match the possible different size from original image due to possible orientation change.
    CGContextRef context = CGBitmapContextCreate(nil, imageRect.size.width, imageRect.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    // http://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1 orientation:image.imageOrientation];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

- (NSURL *)getFileBaseUrl
{
    NSError *err;
    NSURL *libraryDirectory = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
    if (err) {
        return nil;
    }
    return libraryDirectory;
}

- (UIColor *)getStatusColor:(NSInteger)statusCode {
    UIColor *c;
    switch (statusCode) {
        case 0:
            c = [SFBox sharedBox].sfGreen0;
            break;
        case 1:
            c = [SFBox sharedBox].sfGreen1;
            break;
        case 2:
            c = [SFBox sharedBox].sfGreen2;
            break;
        case 3:
            c = [SFBox sharedBox].sfGray;
            break;
        default:
            c = [UIColor clearColor];
            break;
    }
    return c;
}

@end
