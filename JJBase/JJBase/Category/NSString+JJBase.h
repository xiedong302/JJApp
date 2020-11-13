//
//  NSString+JJBase.h
//  JJBase
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JJBase)

/**
 判断两个字符串是否相等，nil也相等
 */
+ (BOOL)jj_isEqual:(NSString *)a to:(NSString *)b;

/**
 判断两个字符串是否相等忽略大小写，nil也相等
 */
+ (BOOL)jj_isEqualIgnoreCase:(NSString *)a to:(NSString *)b;

/**
 判断字符串为汉字
 */
- (BOOL)jj_isChinese;

/**
 判断字符串包含汉字
 */
- (BOOL)jj_isIncludeChinese;

/**
 判断字符串为有效的手机号
 */
- (BOOL)jj_isValidatePhone;

/**
 判断字符串为有效的邮箱
 */
- (BOOL)jj_isValidateEmail;

/**
 判断字符串为有效的身份证号码
 目前验证第二代身份证号码
 */
- (BOOL)jj_isValidateIDCardNumber;

/**
 去掉所有的空格和换行
 */
- (NSString *)jj_trimAllWhitespaceAndNewLine;

/**
 去掉所有的换行
 */
- (NSString *)jj_trimAllNewLine;

/**
 去掉头尾空格和换行
 */
- (NSString *)jj_trimWhitespaceAndNewLine;

/**
 去掉头尾空格
 */
- (NSString *)jj_trimWhitespace;

@end

@interface NSString (JJURL)

- (NSDictionary *)jj_extractURLQueryParams;

- (NSString *)jj_buildURLWithQueryParams:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END

