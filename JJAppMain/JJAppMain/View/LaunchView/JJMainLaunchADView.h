//
//  JJMainLaunchADView.h
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JJMainLaunchADView;
@protocol JJMainLaunchADViewDelegate <NSObject>

- (void)launchADView:(JJMainLaunchADView *)view openURL:(NSString *)url;

@end

//启动广告
@interface JJMainLaunchADView : UIView

@property (nonatomic, weak) id<JJMainLaunchADViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
