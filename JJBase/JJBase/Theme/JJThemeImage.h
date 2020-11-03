//
//  JJThemeImage.h
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 动态图片
 */
@interface JJThemeImage : NSProxy

+ (instancetype)imageWithModuleName:(NSString *)moduleName imageName:(NSString *)imageName cacheable:(BOOL)cacheables;

+ (instancetype)imageWithColorModuleName:(NSString *)moduleName colorName:(NSString *)colorName;

@end

NS_ASSUME_NONNULL_END
