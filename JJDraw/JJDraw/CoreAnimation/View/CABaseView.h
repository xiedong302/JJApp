//
//  CABaseView.h
//  JJDraw
//
//  Created by xiedong on 2020/10/27.
//

#import <JJBaseUI/JJBaseUI.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT CGFloat jj_angleToRadians(CGFloat angle);

@interface CABaseView : JJView

- (void)startAnimation;

- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
