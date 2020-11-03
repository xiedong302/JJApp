//
//  CAPositionView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/27.
//

#import "CAPositionView.h"

@implementation CAPositionView

- (void)setupView {
    self.backgroundColor = UIColor.redColor;
}
- (void)startAnimation {
    CABasicAnimation *animatin = [CABasicAnimation animation];
    animatin.keyPath = @"position.y"; //position.x
    animatin.toValue = @400;
    animatin.duration = 1;
    
    //解决动画恢复到初始位置
    animatin.removedOnCompletion = NO;
    animatin.fillMode = kCAFillModeForwards;
    animatin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addAnimation:animatin forKey:nil];
}
@end
