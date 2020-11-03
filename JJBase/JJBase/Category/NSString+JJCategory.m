//
//  NSString+JJCategory.m
//  JJBase
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "NSString+JJCategory.h"

@implementation NSString (JJCategory)


+ (BOOL)jj_isEqual:(NSString *)a to:(NSString *)b {
    if (a == nil && b == nil) return YES;
    
    if ([a isKindOfClass:[NSNull class]] && [b isKindOfClass:[NSNull class]]) return YES;
    
    if ([a isEqualToString:@""] && [b isEqualToString:@""]) return YES;
    
    if ([a isEqualToString:@"null"] && [b isEqualToString:@"null"]) return YES;
    
    if ([a isEqualToString:b]) return YES;
    
    return NO;
}

+ (BOOL)jj_isEqualIgnoreCase:(NSString *)a to:(NSString *)b {
    if (a == nil && b == nil) return YES;
    if (a == nil || b == nil) return NO;
    
    if ([a isKindOfClass:[NSNull class]] && [b isKindOfClass:[NSNull class]]) return YES;
    
    if ([a isEqualToString:@""] && [b isEqualToString:@""]) return YES;
    
    if ([a isEqualToString:@"null"] && [b isEqualToString:@"null"]) return YES;
    
    if ([[a lowercaseString] isEqualToString:[b lowercaseString]]) return YES;
    
    return NO;
}

- (BOOL)jj_isChinese {
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@",match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)jj_isIncludeChinese {
    for (int i = 0; i < [self length]; i++) {
        int a = [self characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) { //判断是否为中文
            return YES;
        }
    }
    return NO;
}

- (BOOL)jj_isValidatePhone {
    if (!self || self.length < 11) {
        return NO;
    }
    
    NSString *match = @"(^[1]([3|4|5|7|8][0-9]{1})[0-9]{8}$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@",match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)jj_isValidateEmail {
    if (!self) return NO;
    
    NSString *match = @"(^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@",match];
    return [predicate evaluateWithObject:self];
}

- (BOOL)jj_isValidateIDCardNumber {
    if (!self || self.length < 18) {
        return NO;
    }
        
    NSMutableArray *IDArray = [NSMutableArray array];
    // 遍历身份证字符串,存入数组中
    for (int i = 0; i < 18; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        [IDArray addObject:subString];
    }
    // 系数数组
    NSArray *coefficientArray = [NSArray arrayWithObjects:@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2", nil];
    // 余数数组
    NSArray *remainderArray = [NSArray arrayWithObjects:@"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", nil];
    // 每一位身份证号码和对应系数相乘之后相加所得的和
    int sum = 0;
    for (int i = 0; i < 17; i++) {
        int coefficient = [coefficientArray[i] intValue];
        int ID = [IDArray[i] intValue];
        sum += coefficient * ID;
    }
    // 这个和除以11的余数对应的数
    NSString *str = remainderArray[(sum % 11)];
    // 身份证号码最后一位
    NSString *string = [self substringFromIndex:17];
    // 如果这个数字和身份证最后一位相同,则符合国家标准,返回YES
    if ([str isEqualToString:string]) {
        
        NSString *birthdayYer = [self substringWithRange:NSMakeRange(6, 4)];
        NSString *birthdayMan = [self substringWithRange:NSMakeRange(10, 2)];
        NSString *birthdayDay = [self substringWithRange:NSMakeRange(12, 2)];
        if ([birthdayYer intValue]<1900||[birthdayMan intValue]==0||[birthdayMan intValue]>12||[birthdayDay intValue]==0||[birthdayDay intValue]>31) {
            return NO;
        }
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)jj_trimAllWhitespaceAndNewLine {
    if (self == nil) {
        return @"";
    }
    
    //去掉空格
    NSString *str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //去掉换行
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return str;
}

- (NSString *)jj_trimAllNewLine {
    if (self == nil) {
        return @"";
    }
    
    //去掉换行
    NSString *str = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return str;
}

- (NSString *)jj_trimWhitespaceAndNewLine {
    if (self == nil) {
        return @"";
    }
    
    //去掉首尾空格和首尾换行
    NSString *str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return str;
}

- (NSString *)jj_trimWhitespace {
    if (self == nil) {
        return @"";
    }
    
    //去掉首尾空格
    NSString *str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return str;
}

@end

@implementation NSString (JJURL)

NSString * const JJURLSeparate = @"?";
NSString * const JJURLParamLink = @"&";
NSString * const JJURLParamKeyValue = @"=";

- (NSDictionary *)jj_extractURLQueryParams {
    NSArray *array = [self componentsSeparatedByString:JJURLSeparate];
    if (array.count <= 1) {
        return @{};
    }
    
    NSString *params = [array objectAtIndex:1];
    NSArray *paramArray = [params componentsSeparatedByString:JJURLParamLink];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:paramArray.count];
    [paramArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyValue = [obj componentsSeparatedByString:JJURLParamKeyValue];
        if (keyValue.count == 2) {
            NSString *key = [keyValue objectAtIndex:0];
            NSString *value = [keyValue objectAtIndex:1];
            if (key && value) {
                [dic setObject:value forKey:key];
            }
        }
    }];

    return dic;
}

- (NSString *)jj_buildURLWithQueryParams:(NSDictionary *)dic {
    //格式 url?key1=value1&key2=value2;
    __block NSString *url = [self stringByAppendingString:JJURLSeparate];
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *keyValue = [NSString stringWithFormat:@"%@%@%@%@",key,JJURLParamKeyValue,obj,JJURLParamLink];
        url = [url stringByAppendingString:keyValue];
    }];
    return [url substringToIndex:url.length - 1];
}

@end
