//
//  JJTAFCallStackMonitor.m
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//

#import "JJTAFCallStackMonitor.h"
#import "JJTAFCallStackCore.h"

//MARK: - JJTAFCallStackMonitorConfig
@implementation JJTAFCallStackMonitorConfig

+ (instancetype)defaultConfig {
    static JJTAFCallStackMonitorConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[JJTAFCallStackMonitorConfig alloc] init];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        self.maxCPUUsage = 80;
    }
    return self;
}

@end
//MARK: - JJTAFCallStackModel
@interface JJTAFCallStackModel : NSObject

@property (nonatomic, copy) NSString *stackStr;             // 完整堆栈信息
@property (nonatomic, assign) BOOL isStuck;                 // 是否卡主
@property (nonatomic, assign) NSTimeInterval dataString;    // 可展示信息

@end

@implementation JJTAFCallStackModel

- (NSString *)description {
    return [NSString stringWithFormat:@"%f | %@",_dataString, _stackStr];
}

@end

//MARK: - JJTAFCallStackMonitor
@interface JJTAFCallStackMonitor ()
{
    int timeoutCount;
    CFRunLoopObserverRef runLoopObserver;
    @public
    dispatch_semaphore_t dispatchSemaphore;
    CFRunLoopActivity runLoopActivity;
}

@property (nonatomic, assign) BOOL isMonitoring;

@property (nonatomic, strong) dispatch_queue_t myQueue;

@property (nonatomic, strong) dispatch_source_t cpuMonitorTimer;

@property (nonatomic, strong) JJTAFCallStackMonitorConfig *config;

@end

@implementation JJTAFCallStackMonitor

+ (instancetype)shareInstance {
    static JJTAFCallStackMonitor *monitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[JJTAFCallStackMonitor alloc] init];
    });
    return monitor;
}

- (instancetype)init {
    if (self = [super init]) {
        _myQueue = dispatch_queue_create("JJTAFCallStackMonitor", DISPATCH_QUEUE_SERIAL);
        
        _cpuMonitorTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _myQueue);
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_source_set_event_handler(_cpuMonitorTimer, ^{
            __strong JJTAFCallStackMonitor *strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf updateCPUInfo];
            }
        });
        
        dispatch_resume(_cpuMonitorTimer);
    }
    return self;
}

- (void)start:(JJTAFCallStackMonitorConfig *)config  {
    if (!config) {
        config = [JJTAFCallStackMonitorConfig defaultConfig];
    }
    self.config = config;
    self.isMonitoring = YES;
    
    //监测卡顿
    if (runLoopObserver) {
        return;
    }
    dispatchSemaphore = dispatch_semaphore_create(0); //Dispatch Semaphore保证同步
    //创建一个观察者
    CFRunLoopObserverContext context = {0,(__bridge void*)self, NULL, NULL};
    runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallBack, &context);
    //将观察者调价到主线程runloop的common模式下观察
    CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
    
    //创建子线程监控
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_myQueue, ^{
        
        __strong JJTAFCallStackMonitor *strongSelf = weakSelf;
        
        [strongSelf monitorRunloopObserver];
    });
}

- (void)monitorRunloopObserver {
    //子线程开启一个持续的loop用来进行监控
    while (YES) {
        long semaphoreWait = dispatch_semaphore_wait(dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, 80 * NSEC_PER_MSEC));
        if (semaphoreWait != 0) {
            if (!runLoopObserver) {
                timeoutCount = 0;
                dispatchSemaphore = 0;
                runLoopActivity = 0;
                return;
            }
            //两个runloop的状态， BeforeSources和AfterWaiting这两个状态区间加减能够监测到是否卡顿
            if (runLoopActivity == kCFRunLoopBeforeSources || runLoopActivity == kCFRunLoopAfterWaiting) {
                // 出现三次结果
                if (++timeoutCount < 3) {
                    continue;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    NSString *stackStr = [JJTAFCallStackCore callStackWithType:JJTAFCallStackTypeMain];
                    JJTAFCallStackModel *model = [[JJTAFCallStackModel alloc] init];
                    model.stackStr = stackStr;
                    model.isStuck = YES;
                    
                    NSLog(@"%@",stackStr);
                });
            } // end activity
        } // end semaphore wait
        timeoutCount = 0;
    } // end while
}

- (void)stop {
    self.isMonitoring = NO;
   
    dispatch_source_cancel(self.cpuMonitorTimer);
    
    if (!runLoopObserver) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
    CFRelease(runLoopObserver);
    runLoopObserver = NULL;
}

static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    JJTAFCallStackMonitor *monitor = (__bridge JJTAFCallStackMonitor *)info;
    monitor->runLoopActivity = activity;
    
    dispatch_semaphore_t semaphore = monitor->dispatchSemaphore;
    dispatch_semaphore_signal(semaphore);
}

//MARK: - CPU info

- (void)updateCPUInfo {
    thread_act_array_t threads;
    mach_msg_type_number_t threadCount = 0;
    const task_t thisTask = mach_task_self();
    kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
    if (kr != KERN_SUCCESS) {
        return;
    }
    
    for (int i = 0; i < threadCount; i++) {
        thread_info_data_t threadInfo;
        thread_basic_info_t threadBaseInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
            threadBaseInfo = (thread_basic_info_t)threadInfo;
            if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
                integer_t cpuUsage = threadBaseInfo->cpu_usage / 10;
                if (cpuUsage > self.config.maxCPUUsage) {
                    //cup 消耗大于设置值时打印和记录堆栈
                    NSString *reStr = JJTAFStackOfThread(threads[i]);
                    JJTAFCallStackModel *model = [[JJTAFCallStackModel alloc] init];
                    model.stackStr = reStr;
                    //记录数据库中
                    NSLog(@"CPU useage overload thread stack：\n%@",reStr);
                }
            }
        }
    }
}


uint64_t memoryFootprint() {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (result != KERN_SUCCESS)
        return 0;
    return vmInfo.phys_footprint;
}


//MARK: - Public
+ (void)start:(JJTAFCallStackMonitorConfig *)config {
    [[JJTAFCallStackMonitor shareInstance] start:config];
}

+ (void)stop {
    [[JJTAFCallStackMonitor shareInstance] stop];
}
@end
