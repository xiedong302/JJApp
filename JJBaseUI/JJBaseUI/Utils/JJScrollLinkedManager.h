//
//  JJScrollLinkedManager.h
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJScrollLinkedManager : NSObject

- (void)addScrollView:(UIScrollView *)scrollView;

- (void)removeScrollView:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
