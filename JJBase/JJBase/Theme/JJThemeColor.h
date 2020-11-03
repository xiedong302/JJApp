//
//  JJThemeColor.h
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 动态颜色
 */
@interface JJThemeColor : NSProxy <NSCopying>

@property (nonatomic, readonly) NSString *moduleName;

@property (nonatomic, readonly) NSString *colorName;

+ (instancetype)colorWithModuleName:(NSString *)moduleName colorName:(NSString *)colorName;

@end

NS_ASSUME_NONNULL_END
