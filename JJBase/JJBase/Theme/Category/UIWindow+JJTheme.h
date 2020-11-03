//
//  UIWindow+JJTheme.h
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (JJTheme)

- (void)jjtheme_windowThemeDidUpdate; //避免和UIView的重名

@end

NS_ASSUME_NONNULL_END
