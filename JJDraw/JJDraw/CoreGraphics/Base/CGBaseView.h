//
//  CGBaseView.h
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import <JJBaseUI/JJBaseUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface CGBaseView : JJView

/**
 * 子类绘制调用此方法
 */
- (void)viewDrawRect:(CGRect)rect context:(CGContextRef)ctx;

/**
 * 子类通知重绘
 */
- (void)viewNotifiDisplayChanged;

@end

NS_ASSUME_NONNULL_END
