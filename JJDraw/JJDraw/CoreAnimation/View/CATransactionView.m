//
//  CATransactionView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/27.
//

#import "CATransactionView.h"

@interface CATransactionView()

@property (nonatomic, strong) CALayer *sublayer;
@end

@implementation CATransactionView

- (void)setupView {
    
    self.sublayer = [CALayer layer];
    self.sublayer.backgroundColor = UIColor.redColor.CGColor;
    self.sublayer.frame = CGRectMake(10, 10, 50, 50);
    [self.layer addSublayer:self.sublayer];
}

- (void)startAnimation {
    //begin a new transaction
    [CATransaction begin];
    
    [CATransaction setAnimationDuration:2.0];
    
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    self.sublayer.backgroundColor = [UIColor orangeColor].CGColor;
    
    [CATransaction setCompletionBlock:^{
       
        //rotate the layer 90 degrees
        CGAffineTransform transfrom = self.sublayer.affineTransform;
        transfrom = CGAffineTransformRotate(transfrom, M_PI_2);
        self.sublayer.affineTransform = transfrom;
    }];
    
    //commit the transaction
    [CATransaction commit];
}

@end
