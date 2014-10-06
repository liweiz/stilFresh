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
    NSInteger d = [self getDaysLeftFrom:[NSDate date] to:[obj valueForKey:@"bestBefore"]];
    NSNumber *n = [NSNumber numberWithInteger:d];
    [obj setValue:n forKey:@"daysLeft"];
}

// Four scales correspond to four colors: 0: green0, 1: green1, 2: green2, 3: gray.
- (void)resetFreshness:(SFItem *)obj
{
    NSInteger f = [[obj valueForKey:@"daysLeft"] integerValue];
    NSInteger d = [self getDaysLeftFrom:[obj valueForKey:@"timeAdded"] to:[obj valueForKey:@"bestBefore"]];
    CGFloat r1 = d / 3.0;
    CGFloat r2 = d * 2.0 / 3;
    NSNumber *n;
    if (f <= 0) {
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
    NSArray *a = [self getDateFromString:string];
    if (a) {
        NSDateComponents *c = [[NSDateComponents alloc] init];
        [c setTimeZone:[NSTimeZone defaultTimeZone]];
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

- (NSArray *)getDateFromString:(NSString *)string
{
    if ([self validateDateInput:string]) {
        NSString *year = [string substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [string substringWithRange:NSMakeRange(4, 2)];
        if (month.integerValue < 1 || month.integerValue > 12) {
            // Incorrect data
            return nil;
        }
        NSString *day = [string substringWithRange:NSMakeRange(6, 2)];
        if (month.integerValue < 1 || month.integerValue > 31) {
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
    NSDateComponents *c = [[NSCalendar currentCalendar]
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

@end
