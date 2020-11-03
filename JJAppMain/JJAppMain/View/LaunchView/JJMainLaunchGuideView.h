//
//  JJMainLaunchGuideView.h
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JJMainLaunchGuideView;
@protocol JJMainLaunchGuideViewDelegate <NSObject>

- (void)launchGuideView:(JJMainLaunchGuideView *)view openURL:(NSString *)url;

@end

//启动引导view
@interface JJMainLaunchGuideView : UIView

@property (nonatomic, weak) id<JJMainLaunchGuideViewDelegate> delegate;

+ (BOOL)needShowGuide;

@end

NS_ASSUME_NONNULL_END
