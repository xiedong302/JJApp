//
//  JJTAFMonitorManager.m
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//

#import "JJTAFMonitorManager.h"
#import "JJTAFCallTraceMonitor.h"
#import "JJTAFCallStackMonitor.h"

//MARK: - JJTAFMonitorConfig
@interface JJTAFMonitorConfig : NSObject

@property (nonatomic, assign) int maxDepth; // 最大的深度 default 3

@property (nonatomic, assign) uint64_t minTimeCost; // 最小的时间间隔 default 200ms

@property (nonatomic, assign) int maxCPUUsage; // default 80

@end

@implementation JJTAFMonitorConfig

+ (instancetype)defaultConfig {
    static JJTAFMonitorConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[JJTAFMonitorConfig alloc] init];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        self.maxDepth = 3;
        self.minTimeCost = 200;
        self.maxCPUUsage = 80;
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"JJTAFMonitorConfig" withExtension:@"plist"];
        if (url) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url];
            
            if (dict) {
                id value = [dict valueForKey:@"maxDepth"];
                if (value) {
                    self.maxDepth = [value intValue];
                }
                
                value = [dict valueForKey:@"minTimeCost"];
                if (value) {
                    self.minTimeCost = [value longLongValue];
                }
                
                value = [dict valueForKey:@"maxCPUUsage"];
                if (value) {
                    self.maxCPUUsage = [value intValue];
                }
            }
        }
    }
    return self;
}

@end
//MARK: - JJTAFMonitorManager

@interface JJTAFMonitorManager ()

@property (nonatomic, strong) JJTAFMonitorConfig *config;

@end

@implementation JJTAFMonitorManager

+ (instancetype)defaultManager {
    static JJTAFMonitorManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JJTAFMonitorManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.config = [JJTAFMonitorConfig defaultConfig];
    }
    return self;
}

//MARK: - Private
- (void)startLagMonitor {
    JJTAFCallStackMonitorConfig *stackConfig = [JJTAFCallStackMonitorConfig defaultConfig];
    stackConfig.maxCPUUsage = self.config.maxCPUUsage;
    [JJTAFCallStackMonitor start:stackConfig];
}

- (void)stopLagMonitor {
    [JJTAFCallStackMonitor stop];
}

- (void)startCallTraceMonitor {
    JJTAFCallTraceMonitorConfig *traceConfig = [JJTAFCallTraceMonitorConfig defaultConfig];
    traceConfig.maxDepth = self.config.maxDepth;
    traceConfig.minTimeCost = self.config.minTimeCost;
    [JJTAFCallTraceMonitor start:traceConfig];
}

- (void)stopCallTraceMonitor {
    [JJTAFCallTraceMonitor stopSaveAndClean];
}

//MARK: - Public

+ (void)startLagMonitor {
    [[JJTAFMonitorManager defaultManager] startLagMonitor];
}

+ (void)stopLagMonitor {
    [[JJTAFMonitorManager defaultManager] stopLagMonitor];
}

+ (void)startCallTraceMonitor {
    [[JJTAFMonitorManager defaultManager] startCallTraceMonitor];
}

+ (void)stopCallTraceMonitor {
    [[JJTAFMonitorManager defaultManager] stopCallTraceMonitor];
}

@end
