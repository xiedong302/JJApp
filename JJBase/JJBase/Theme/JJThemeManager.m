//
//  JJThemeManager.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJThemeManager.h"
#import "JJBundleResource.h"
#import "UIApplication+JJTheme.h"

NSString * const kJJThemeDidChangeNotification = @"JJThemeDidChangeNotification";

static NSString * __currentThemeName = nil;

@implementation JJThemeManager

+ (BOOL)isDarkTheme {
    return [__currentThemeName isEqualToString:@"Dark"];
}

+ (void)changeTheme:(NSString *)themeName {
    //themeName: nil / Dark
    __currentThemeName = themeName;
    
    [JJBundleResource setOverrideSuffix:themeName];
    
    [UIApplication.sharedApplication jjtheme_themeDidUpdate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJJThemeDidChangeNotification object:themeName];
    
}

@end
