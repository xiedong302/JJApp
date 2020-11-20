//
//  JJTAFReachability.m
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import "JJTAFReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const JJTAFReachabilityChangeNotification = @"com.iosapp.jj.reachability.notification";

typedef void (^JJTAFReachabilityStatusBlock)(JJTAFReachabilityStatus status);

static JJTAFReachabilityStatus JJTAFReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    JJTAFReachabilityStatus status = JJTAFReachabilityStatusUnknow;
    if (isNetworkReachable == NO) {
        status = JJTAFReachabilityStatusNotReachable;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = JJTAFReachabilityStatusReachableViaWWAN;
    } else {
        status = JJTAFReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void JJPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, JJTAFReachabilityStatusBlock block) {
    JJTAFReachabilityStatus status = JJTAFReachabilityStatusForFlags(flags);
    
    NSLog(@"[JJTAFReachability] JJPostReachabilityStatusChange : %zd", status);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block(status);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JJTAFReachabilityChangeNotification object:@(status)];
    });
}

static void JJTAFReachabilityCallBack(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    JJPostReachabilityStatusChange(flags, (__bridge JJTAFReachabilityStatusBlock)info);
}

static const void * JJTAFReachabilityRetainCallBack(const void *info) {
    return Block_copy(info);
}

static void JJTAFReachabilityReleaseCallBack(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface JJTAFReachability()

@property (nonatomic, assign, readonly) SCNetworkReachabilityRef reachability;

@property (nonatomic, assign) JJTAFReachabilityStatus status;

@end
@implementation JJTAFReachability

- (instancetype)init {
    if (self = [super init]) {
        _status = JJTAFReachabilityStatusUnknow;
        
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
        
        NSLog(@"[JJTAFReachability] start");
        
        __weak typeof(self) weakSelf = self;
        //在main queue回调
        JJTAFReachabilityStatusBlock callBack = ^(JJTAFReachabilityStatus status) {
            __strong JJTAFReachability *strongSelf = weakSelf;
            
            if (strongSelf) {
                strongSelf.status = status;
            }
        };
        
        SCNetworkReachabilityContext content = {0, (__bridge void *)callBack, JJTAFReachabilityRetainCallBack, JJTAFReachabilityReleaseCallBack, NULL};
        SCNetworkReachabilitySetCallback(_reachability, JJTAFReachabilityCallBack, &content);
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
    NSLog(@"[JJTAFReachability] dealloc");
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    CFRelease(self.reachability);
}

+ (instancetype)sharedInstance {
    static JJTAFReachability *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJTAFReachability alloc] init];
    });
    return instance;
}

+ (JJTAFReachabilityStatus)status {
    return [JJTAFReachability sharedInstance].status;
}

+ (BOOL)isReachable {
    return [[JJTAFReachability sharedInstance] isReachable];
}
- (BOOL)isReachable {
    return (self.status == JJTAFReachabilityStatusReachableViaWWAN ||
            self.status == JJTAFReachabilityStatusReachableViaWiFi);
}
@end
