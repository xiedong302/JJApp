//
//  JJTAFMonitorManager.m
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//

#import "JJTAFMonitorManager.h"
#import "JJTAFCallTraceCore.h"
#import <objc/runtime.h>

//MARK: - JJTAFCallTraceTimeCostModel

@interface JJTAFCallTraceTimeCostModel : NSObject

@property (nonatomic, copy) NSString *className;        // 类名
@property (nonatomic, copy) NSString *methodName;       // 方法名
@property (nonatomic, copy) NSString *path;             // 路径
@property (nonatomic, assign) BOOL isClassMethod;       // 是否是类方法
@property (nonatomic, assign) NSTimeInterval timeCost;  // 时间消耗
@property (nonatomic, assign) NSUInteger callDepth;     // Call 层级
@property (nonatomic, assign) BOOL lastCall;            // 是否是最后一个Call
@property (nonatomic, assign) NSUInteger frequency;     //  访问频次

@property (nonatomic, strong) NSArray<JJTAFCallTraceTimeCostModel *> *subCosts;

- (NSString *)des;

@end

@implementation JJTAFCallTraceTimeCostModel

- (NSString *)des {
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"depth %2d, ",(int)_callDepth];
    [str appendFormat:@"timeCost(ms) %.2f,",_timeCost * 1000.0];
    for (NSUInteger i = 0; i < _callDepth; i++) {
        [str appendString:@"  "];
    }
    [str appendFormat:@"%s[%@ %@]",(_isClassMethod ? "+" : "-"), _className, _methodName];
    
    return str;
}

@end
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
    }
    return self;
}

@end

//MARK: - JJTAFMonitorManager
@implementation JJTAFMonitorManager

+ (void)start:(JJTAFMonitorConfig *)config {
    if (!config) {
        config = [JJTAFMonitorConfig defaultConfig];
    }
    
    JJTAF_callTraceConfigMinTime(config.minTimeCost * 1000);
    JJTAF_callTraceConfigMaxDepth(config.maxDepth);
    JJTAF_callTraceStart();
}

+ (void)stopSaveAndClean {
    [self stop];
    [self save];
    [self clean];
}

+ (void)stop {
    JJTAF_callTraceStop();
}

+ (void)save {
    NSMutableString *mStr = [NSMutableString new];
    NSArray <JJTAFCallTraceTimeCostModel *> *arr = [self loadRecords];
    for (JJTAFCallTraceTimeCostModel *model in arr) {
        // 记录方法路径
        model.path = [NSString stringWithFormat:@"[%@ %@]",model.className, model.methodName];
        [self appendRecord:model to:mStr];
    }
    
    NSLog(@"%@", mStr);
}

+ (void)appendRecord:(JJTAFCallTraceTimeCostModel *)cost to:(NSMutableString *)mStr {
    [mStr appendFormat:@"%@\npath=%@\n",[cost des], cost.path];
    if (cost.subCosts.count < 1) {
        cost.lastCall = YES;
        
        // 记录到某个位置 如 DB
        
    } else {
        for (JJTAFCallTraceTimeCostModel *subCost in cost.subCosts) {
            if ([subCost.className isEqualToString:NSStringFromClass(self)]) {
                break;
            }
            // 记录方法的子方法的路径
            subCost.path = [NSString stringWithFormat:@"%@ - [%@ %@]",cost.path, subCost.className, subCost.methodName];
            [self appendRecord:subCost to:mStr];
        }
    }
}

+ (void)clean {
    JJTAF_clearCallTraceRecords();
}

+ (NSArray<JJTAFCallTraceTimeCostModel *> *)loadRecords {
    NSMutableArray <JJTAFCallTraceTimeCostModel *> *arr = [NSMutableArray array];
    int num = 0;
    JJTAFCallRecord *records = JJTAF_getCallTraceRecords(&num);
    for (int i = 0; i < num; i++) {
        JJTAFCallRecord *rd = &records[i];
        JJTAFCallTraceTimeCostModel *model = [JJTAFCallTraceTimeCostModel new];
        model.className = NSStringFromClass(rd->cls);
        model.methodName = NSStringFromSelector(rd->sel);
        model.isClassMethod = class_isMetaClass(rd->cls);
        model.timeCost = (double)rd->time / 1000000.0;
        model.callDepth = rd->depth;
        [arr addObject:model];
    }
    NSUInteger count = arr.count;
    for (NSUInteger i = 0; i < count; i++) {
        JJTAFCallTraceTimeCostModel *model = arr[i];
        if (model.callDepth > 0) {
            [arr removeObjectAtIndex:i];
            // 不需要循环，直接设置下一个，然后判断好边界就行
            for (NSUInteger j = i; j < count - 1; j++) {
                // 下一个深度小的话就开始将后面的递归的往 sub array里添加
                if (arr[j].callDepth + 1 == model.callDepth) {
                    NSMutableArray *sub = (NSMutableArray *)arr[i].subCosts;
                    if (!sub) {
                        sub = [NSMutableArray array];
                        arr[j].subCosts = sub;
                    }
                    [sub insertObject:model atIndex:0];
                }
            }
            i--;
            count--;
        }
    }
    return arr;
}

@end
