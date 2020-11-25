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
@implementation JJTAFMonitorManager

+ (void)startMonitor:(JJTAFMonitorConfig *)config {
    if (!config) {
        config = [JJTAFMonitorConfig defaultConfig];
    }
    JJTAFCallTraceMonitorConfig *traceConfig = [JJTAFCallTraceMonitorConfig defaultConfig];
    traceConfig.maxDepth = config.maxDepth;
    traceConfig.minTimeCost = config.minTimeCost;
    [JJTAFCallTraceMonitor start:traceConfig];
    
    JJTAFCallStackMonitorConfig *stackConfig = [JJTAFCallStackMonitorConfig defaultConfig];
    stackConfig.maxCPUUsage = config.maxCPUUsage;
    [JJTAFCallStackMonitor start:stackConfig];
}

+ (void)stopMonitor {
    [JJTAFCallTraceMonitor stopSaveAndClean];
    [JJTAFCallStackMonitor stop];
}

@end
