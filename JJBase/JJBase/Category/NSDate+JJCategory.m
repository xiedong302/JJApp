//
//  NSDate+JJCategory.m
//  JJBase
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "NSDate+JJCategory.h"

NSString * const kJJDateFormat_HHmm = @"HH:mm";
NSString * const kJJDateFormat_HHmmss = @"HH:mm:ss";
NSString * const kJJDateFormat_MMdd = @"MMdd";
NSString * const kJJDateFormat_MMdd_line = @"MM-dd";
NSString * const kJJDateFormat_MMdd_chinese = @"MM月dd日";
NSString * const kJJDateFormat_MMddHHmm = @"MMdd HH:mm";
NSString * const kJJDateFormat_MMddHHmm_line = @"MM-dd HH:mm";
NSString * const kJJDateFormat_MMddHHmm_chinese = @"MM月dd日 HH:mm";
NSString * const kJJDateFormat_MMddHHmmss = @"MMdd HH:mm:ss";
NSString * const kJJDateFormat_MMddHHmmss_line = @"MM-dd HH:mm:ss";
NSString * const kJJDateFormat_MMddHHmmss_chinese = @"MM月dd日 HH:mm:ss";
NSString * const kJJDateFormat_yyyyMMdd = @"yyyyMMdd";
NSString * const kJJDateFormat_yyyyMMdd_line = @"yyyy-MM-dd";
NSString * const kJJDateFormat_yyyyMMdd_chinese = @"yyyy年MM月dd日";
NSString * const kJJDateFormat_yyyyMMddHHmm = @"yyyyMMdd HH:mm";
NSString * const kJJDateFormat_yyyyMMddHHmm_line = @"yyyy-MM-dd HH:mm";
NSString * const kJJDateFormat_yyyyMMddHHmm_chinese = @"yyyy年MM月dd日 HH:mm";
NSString * const kJJDateFormat_yyyyMMddHHmmss = @"yyyyMMdd HH:mm:ss";
NSString * const kJJDateFormat_yyyyMMddHHmmss_line = @"yyyy-MM-dd HH:mm:ss";
NSString * const kJJDateFormat_yyyyMMddHHmmss_chinese = @"yyyy年MM月dd日 HH:mm:ss";

@implementation NSDate (JJCategory)

+ (instancetype)jj_dateFromString:(NSString *)str dateFormat:(NSString *)format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    return [dateFormat dateFromString:str];
}

+ (instancetype)jj_dateFromSecond:(NSTimeInterval)second {
    return [NSDate dateWithTimeIntervalSince1970:second];
}

+ (instancetype)jj_dateFromMillisecond:(NSTimeInterval)millisecond {
    return [NSDate dateWithTimeIntervalSince1970:millisecond / 1000.0];
}

- (NSString *)jj_stringFromDateFormat:(NSString *)format {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    return [dateFormat stringFromDate:self];
}

- (NSString *)jj_yyyyMMdd {
    if (self == nil) return @"";
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    
    return [NSString stringWithFormat:@"%04zd%02zd%02zd",components.year,components.month,components.day];
}

- (NSString *)jj_HHmmss {
    if (self == nil) return @"";
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    
    return [NSString stringWithFormat:@"%02zd%02zd%02zd",components.hour,components.minute,components.second];
}

- (NSString *)jj_week {
    if (self == nil) return @"";
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    
    //1-7 周日-周一-..-周六
    return [self _jj_weekStrFromWeekInt:components.weekday];
}


//MARK: - private
- (NSString *)_jj_weekStrFromWeekInt:(NSInteger)week {
    switch (week) {
        case 1:
            return @"周日";
        case 2:
            return @"周一";
        case 3:
            return @"周二";
        case 4:
            return @"周三";
        case 5:
            return @"周四";
        case 6:
            return @"周五";
        case 7:
            return @"周六";
        default:
            break;
    }
    return @"";
}


@end
