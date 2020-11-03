//
//  JJReachability.h
//  JJBase
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const JJReachabilityChangeNotification;

#define JJNetworkReachable ([JJReachability isReachable])
#define JJNetworkNotReachable (![JJReachability isReachable])

typedef NS_ENUM(NSInteger, JJReachabilityStatus) {
    JJReachabilityStatusUnknow           = -1, //未知，刚初始化的时候会是这个状态
    JJReachabilityStatusNotReachable     = 0,  //没有网络
    JJReachabilityStatusReachableViaWWAN = 1,  //移动网络
    JJReachabilityStatusReachableViaWiFi = 2,  //WiFi网络
};

@interface JJReachability : NSObject

+ (instancetype)sharedInstance;

+ (JJReachabilityStatus)status;

+ (BOOL)isReachable;
@end

NS_ASSUME_NONNULL_END
