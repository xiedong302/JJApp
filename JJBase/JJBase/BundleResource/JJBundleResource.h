//
//  JJBundleResource.h
//  JJBase
//
//  Created by xiedong on 2020/9/28.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  从bundle里面获取资源
 *
 * 1.支持缓存，字符串和颜色默认缓存
 * 2.支持国际化
 * 3.支持资源覆盖
 * 4.支持基本的资源匹配策略
 */
@interface JJBundleResource : NSObject

+ (NSString *)stringForName:(NSString *)name inBundle:(NSString *)bundleName;

+ (UIColor *)colorForName:(NSString *)name inBundle:(NSString *)bundleName;

+ (UIImage *)imageForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable;

+ (NSData *)dataForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable;

+ (NSArray *)arrayForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable;

+ (NSDictionary *)dictionaryForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable;

+ (NSString *)filePathForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable;

+ (NSString *)overrideSuffix;

+ (void)setOverrideSuffix:(NSString *)overrideSuffix;

+ (void)clearCache;

+ (void)setDebug:(BOOL)debuggable;

@end

NS_ASSUME_NONNULL_END
