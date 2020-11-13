//
//  JJThemeManager.h
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kJJThemeDidChangeNotification;

@interface JJThemeManager : NSObject

+ (BOOL)isDarkTheme;

+ (void)changeTheme:(nullable NSString *)themeName;

@end

NS_ASSUME_NONNULL_END
