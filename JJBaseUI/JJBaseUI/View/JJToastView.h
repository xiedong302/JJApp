//
//  JJToastView.h
//  JJBaseUI
//
//  Created by xiedong on 2020/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 简单提示view，例如操作成功或者失败，自动消失
 * 可以在任意线程调用
 */
@interface JJToastView : NSObject

+ (void)show:(NSString *)text;

+ (void)show:(NSString *)text icon:(UIImage *)icon;

+ (void)show:(NSString *)text icon:(UIImage *)icon time:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
