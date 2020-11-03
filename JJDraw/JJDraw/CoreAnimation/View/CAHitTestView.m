//
//  CAHitTestView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/27.
//

#import "CAHitTestView.h"

@implementation CAHitTestView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // 如果交互没有打开，或者透明度小于0.05 或者隐藏视图
    if (self.userInteractionEnabled == NO || self.alpha < 0.05 || self.hidden == YES) {
        return nil;
    }
    
    // 如果 touch 的point在self的bounds内
    if ([self pointInside:point withEvent:event]) {
        
        for (UIView *subView in self.subviews) {
            
            // 进行坐标转换
            CGPoint coverPoint = [subView convertPoint:point fromView:self];
            
            // 调用子视图的 hitTest 重复上面的步骤。 找到了 返回 hitTest view, 没找到返回有自身处理
            UIView *hitTestView = [subView hitTest:coverPoint withEvent:event];
            
            if (hitTestView) {
                return hitTestView;
            }
        }
        
        return self;
    }
    
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // get touch position relative to main view (获取相对于主视图的触摸位置)
    CGPoint point = [[touches anyObject] locationInView:self];
    
    // get touch layer
    CALayer *layer = [self.layer hitTest:point];
    
    NSLog(@"%@",layer);
}

@end
