//
//  JJReachability.m
//  JJBase
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const JJReachabilityChangeNotification = @"com.iosapp.jj.reachability.notification";

typedef void (^JJReachabilityStatusBlock)(JJReachabilityStatus status);

static JJReachabilityStatus JJReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    JJReachabilityStatus status = JJReachabilityStatusUnknow;
    if (isNetworkReachable == NO) {
        status = JJReachabilityStatusNotReachable;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = JJReachabilityStatusReachableViaWWAN;
    } else {
        status = JJReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void JJPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, JJReachabilityStatusBlock block) {
    JJReachabilityStatus status = JJReachabilityStatusForFlags(flags);
    
    JJLog(@"[JJReachability] JJPostReachabilityStatusChange : %zd", status);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JJReachabilityChangeNotification object:@(status)];
    });
}

static void JJReachabilityCallBack(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    JJPostReachabilityStatusChange(flags, (__bridge JJReachabilityStatusBlock)info);
}

static const void * JJReachabilityRetainCallBack(const void *info) {
    return Block_copy(info);
}

static void JJReachabilityReleaseCallBack(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface JJReachability()

@property (nonatomic, assign, readonly) SCNetworkReachabilityRef reachability;

@property (nonatomic, assign) JJReachabilityStatus status;

@end
@implementation JJReachability

- (instancetype)init {
    if (self = [super init]) {
        _status = JJReachabilityStatusUnknow;
        
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000)
        struct sockaddr_in6 address;
        bzero(&address, sizeof(address));
        address.sin6_len = sizeof(address);
        address.sin6_family = AF_INET6;
#else
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
#endif
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&address);
        
        _reachability = CFRetain(reachability);
        
        CFRelease(reachability);
        
        JJLog(@"[JJReachability] start");
        
        __weak typeof(self) weakSelf = self;
        //在main queue回调
        JJReachabilityStatusBlock callBack = ^(JJReachabilityStatus status) {
            __strong JJReachability *strongSelf = weakSelf;
            
            if (strongSelf) {
                strongSelf.status = status;
            }
        };
        
        SCNetworkReachabilityContext content = {0, (__bridge void *)callBack, JJReachabilityRetainCallBack, JJReachabilityReleaseCallBack, NULL};
        SCNetworkReachabilitySetCallback(_reachability, JJReachabilityCallBack, &content);
        SCNetworkReachabilityScheduleWithRunLoop(_reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        
        //获取当前的网络状态
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SCNetworkReachabilityFlags flags;
            
            if (SCNetworkReachabilityGetFlags(self.reachability, &flags)) {
                JJPostReachabilityStatusChange(flags, callBack);
            }
        });
        
    }
    return self;
}

- (void)dealloc {
    JJLog(@"[JJReachability] dealloc");
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    CFRelease(self.reachability);
}

+ (instancetype)sharedInstance {
    static JJReachability *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJReachability alloc] init];
    });
    return instance;
}

+ (JJReachabilityStatus)status {
    return [JJReachability sharedInstance].status;
}

+ (BOOL)isReachable {
    return [[JJReachability sharedInstance] isReachable];
}
- (BOOL)isReachable {
    return (self.status == JJReachabilityStatusReachableViaWWAN ||
            self.status == JJReachabilityStatusReachableViaWiFi);
}
@end
