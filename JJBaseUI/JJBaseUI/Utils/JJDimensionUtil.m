//
//  JJDimensionUtil.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJDimensionUtil.h"

@implementation JJDimensionUtil

+ (BOOL)isUILandscape {
    return UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
    UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationLandscapeRight;
}
+ (CGFloat)scaleWidth:(CGFloat)width {
    if ([JJDimensionUtil isUILandscape]) {
        if (UIScreen.mainScreen.bounds.size.width >= 667.0f) {
            return width;
        }
        
        //标准分辨率一下的才缩放
        return width * UIScreen.mainScreen.bounds.size.width / 667.0f;
    }
    else {
        if (UIScreen.mainScreen.bounds.size.width >= 375.0f) {
            return width;
        }
        
        //标准分辨率一下的才缩放
        return width * UIScreen.mainScreen.bounds.size.width / 375.0f;
    }
}

+ (CGFloat)scaleHeight:(CGFloat)height {
    if ([JJDimensionUtil isUILandscape]) {
        if (UIScreen.mainScreen.bounds.size.height >= 375.0f) {
            return height;
        }
        
        //标准分辨率一下的才缩放
        return height * UIScreen.mainScreen.bounds.size.height / 375.0f;
    }
    else {
        if (UIScreen.mainScreen.bounds.size.height >= 667.0f) {
            return height;
        }
        
        //标准分辨率一下的才缩放
        return height * UIScreen.mainScreen.bounds.size.height / 667.0f;
    }
}
@end
