//
//  NSDate+JJBase.h
//  JJBase
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kJJDateFormat_HHmm;                     //HH:mm
FOUNDATION_EXPORT NSString * const kJJDateFormat_HHmmss;                   //HH:mm:ss
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMdd;                     //MMdd
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMdd_line;                //MM-dd
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMdd_chinese;             //MM月dd日
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMddHHmm;                 //MMdd HH:mm
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMddHHmm_line;            //MM-dd HH:mm
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMddHHmm_chinese;         //MM月dd日 HH:mm
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMddHHmmss;               //MMdd HH:mm:ss
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMddHHmmss_line;          //MM-dd HH:mm:ss
FOUNDATION_EXPORT NSString * const kJJDateFormat_MMddHHmmss_chinese;       //MM月dd日 HH:mm:ss
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMdd;                 //yyyyMMdd
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMdd_line;            //yyyy-MM-dd
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMdd_chinese;         //yyyy年MM月dd日
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMddHHmm;             //yyyyMMdd HH:mm
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMddHHmm_line;        //yyyy-MM-dd HH:mm
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMddHHmm_chinese;     //yyyy年MM月dd日 HH:mm
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMddHHmmss;           //yyyyMMdd HH:mm:ss
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMddHHmmss_line;      //yyyy-MM-dd HH:mm:ss
FOUNDATION_EXPORT NSString * const kJJDateFormat_yyyyMMddHHmmss_chinese;   //yyyy年MM月dd日 HH:mm:ss

@interface NSDate (JJBase)

+ (instancetype)jj_dateFromString:(NSString *)str dateFormat:(NSString *)format;

+ (instancetype)jj_dateFromSecond:(NSTimeInterval)second;

+ (instancetype)jj_dateFromMillisecond:(NSTimeInterval)millisecond;

- (NSString *)jj_stringFromDateFormat:(NSString *)format;

- (NSString *)jj_yyyyMMdd;

- (NSString *)jj_HHmmss;

- (NSString *)jj_week;

@end

NS_ASSUME_NONNULL_END

