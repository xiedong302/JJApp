//
//  JJTAFMonitorTime.m
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import "JJTAFMonitorTime.h"
#import "JJTAFBacktraceManager.h"
#import <UIKit/UIKit.h>

#define kJJTAFMonitorTimerInterval 0.01 //监控的时间间隔， 建议0.01s最佳

@interface JJTAFMonitorTimeInfo : NSObject

@property (nonatomic, copy) NSString *functionName; // 方法名称
@property (nonatomic, assign) CGFloat consumeTime; // 消耗时间
@property (nonatomic, copy) NSString *functionAddress; // 方法地址
@property (nonatomic, assign) NSTimeInterval lastTime; // 记录上一次记录消耗时间值的时间
@end

@implementation JJTAFMonitorTimeInfo

@end

@interface JJTAFMonitorTime ()

@property (nonatomic, strong) dispatch_source_t monitoringTimer;    //监控定时器
@property (nonatomic, strong) NSMutableDictionary *callStackDict;   //调用堆栈map
@property (nonatomic, strong) NSArray *whiteList; //白名单
@end

@implementation JJTAFMonitorTime

+ (instancetype)sharedTimer {
    static JJTAFMonitorTime *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[JJTAFMonitorTime alloc] init];
    });
    return share;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.callStackDict = [NSMutableDictionary dictionary];
        
        self.monitoringTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        
        dispatch_source_set_timer(self.monitoringTimer, dispatch_walltime(NULL, 0), kJJTAFMonitorTimerInterval * NSEC_PER_SEC, 0);
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_source_set_event_handler(self.monitoringTimer, ^{
            __strong JJTAFMonitorTime *strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf handleMainThreadCallStack];
            }
            
        });
    }
    return self;
}

- (void)handleMainThreadCallStack {
    // key-方法调用地址 value-方法调动名称
    NSDictionary *mainThreadCallStack = [JJTAFBacktraceManager jj_backtraceMapOfMainThread];
    for (NSString *funcAddress in mainThreadCallStack.allKeys) {
        NSString *funcName = [mainThreadCallStack objectForKey:funcAddress];
        JJTAFMonitorTimeInfo *info = [self.callStackDict objectForKey:funcAddress];
        if (!info) {
            info = [JJTAFMonitorTimeInfo new];
            info.functionName = funcName;
            info.functionAddress = funcAddress;
            info.consumeTime = kJJTAFMonitorTimerInterval;
            info.lastTime = [[NSDate date] timeIntervalSince1970];
            [self.callStackDict setObject:info forKey:funcAddress];
        } else {
            NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval time = currentTime - info.lastTime;
            info.consumeTime = info.consumeTime + time;
            info.lastTime = currentTime;
        }
    }
}

//MARK: - Private
- (void)startMonitoringTimer {
    dispatch_resume(self.monitoringTimer);
}

- (void)stopMonitoringTimer {
    dispatch_source_cancel(self.monitoringTimer);
    [self logAllCallStack];
}

- (void)logAllCallStack {
    NSMutableString *resultString = [NSMutableString stringWithString:@""];
    for (NSString *key in self.callStackDict.allKeys) {
        JJTAFMonitorTimeInfo *info = [self.callStackDict objectForKey:key];
        if (info && info.functionName && info.consumeTime > kJJTAFMonitorTimerInterval && [self chechMonitorWhiteList:info.functionName]) {
            [resultString appendFormat:@"%@的耗时为：%.3fs \n\n",info.functionName, info.consumeTime];
        }
    }
    
    NSLog(@"[JJTAFMonitorTime] Monitor main thread call stack \n\n%@",resultString);
}

- (BOOL)chechMonitorWhiteList:(NSString *)funcName {
    
    BOOL bWhite = NO;
    
    for (NSString *obj in self.whiteList) {
        if ([funcName containsString:obj]) {
            bWhite = YES;
            break;;
        }
    }
    
    return bWhite;
}

//MARK: - Getter & Setter
- (NSArray *)whiteList {
    if (!_whiteList) {
//        _whiteList = JJRArray(@"monitorWhiteList.json");
    }
    return _whiteList;
}
//MARK: - Public
+ (void)startMonitoringTimer {
    [[JJTAFMonitorTime sharedTimer] startMonitoringTimer];
}

+ (void)stopMonitoringTimer {
    [[JJTAFMonitorTime sharedTimer] stopMonitoringTimer];
}



@end
