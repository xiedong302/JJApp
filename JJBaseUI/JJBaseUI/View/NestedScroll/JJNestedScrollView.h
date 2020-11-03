//
//  JJNestedScrollView.h
//  JJBaseUI
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJNestedScrollView : UIScrollView

- (void)addTopView:(UIView *)topView bottomView:(UIView *)bottomView;

@end

NS_ASSUME_NONNULL_END
