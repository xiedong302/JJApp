//
//  JJTAFReachability.h
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const JJTAFReachabilityChangeNotification;

#define JJTAFNetworkReachable ([JJTAFReachability isReachable])
#define JJTAFNetworkNotReachable (![JJTAFReachability isReachable])

typedef NS_ENUM(NSInteger, JJTAFReachabilityStatus) {
    JJTAFReachabilityStatusUnknow           = -1, //未知，刚初始化的时候会是这个状态
    JJTAFReachabilityStatusNotReachable     = 0,  //没有网络
    JJTAFReachabilityStatusReachableViaWWAN = 1,  //移动网络
    JJTAFReachabilityStatusReachableViaWiFi = 2,  //WiFi网络
};

@interface JJTAFReachability : NSObject

+ (instancetype)sharedInstance;

+ (JJTAFReachabilityStatus)status;

+ (BOOL)isReachable;
@end

NS_ASSUME_NONNULL_END
