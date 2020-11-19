//
//  JJTAFFMDBHelper.m
//  JJTAF
//
//  Created by xiedong on 2020/11/18.
//

#import "JJTAFFMDBHelper.h"

//MARK: - JJTAFFMDBThread

#define MAX_THREAD_POOL_SIZE (3)

@interface JJTAFFMDBThread : NSObject

@property (nonatomic, strong, readonly) NSThread *thread;
@property (nonatomic, assign, readonly) BOOL standalone;
@property (nonatomic, assign) NSInteger referenceCount;

@end

@implementation JJTAFFMDBThread {
    //volatile 保证多个线程可以访问同一个内存空间
    volatile BOOL _cancelled;
}

- (instancetype)initWithThread:(NSThread *)thread standalone:(BOOL)standalone {
    if (self = [super init]) {
        _thread = thread;
        _standalone = standalone;
        _referenceCount = 1;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[JJTAFFMDBThread] Dealloc: %@",self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@[%@,%@,%@]",_thread.name,@(_referenceCount),@(_standalone),@(_cancelled)];
}

//MARK: - Public
- (void)dispatchAsync:(dispatch_block_t)block {
    if (!_cancelled && _referenceCount > 0) {
        [self performSelector:@selector(runBlock:)
                     onThread:_thread
                   withObject:block
                waitUntilDone:NO
                        modes:[self modes]];
    }
}

- (void)dispatchSync:(dispatch_block_t)block {
    if (!_cancelled && _referenceCount > 0) {
        [self performSelector:@selector(runBlock:)
                     onThread:_thread
                   withObject:block
                waitUntilDone:NO
                        modes:[self modes]];
    }
}

- (void)cancel {
    _cancelled = YES;
    
    [self performSelector:@selector(runBlock:)
                 onThread:_thread
               withObject:^{
                    NSLog(@"[JJTAFFMDBThreadPool] Cancel:%@",self);
                    [NSThread.currentThread cancel];
                }
            waitUntilDone:NO
                    modes:[self modes]];
}

//MARK: - Private
- (NSArray *)modes {
    static NSArray *modes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modes = @[NSDefaultRunLoopMode];
    });
    return modes;
}

- (void)runBlock:(dispatch_block_t)block {
    if (block) {
        block();
    }
}

@end

//MARK: - JJTAFFMDBThreadPool

@interface JJTAFFMDBThreadPool : NSObject

@end

@implementation JJTAFFMDBThreadPool {
    int _threadIndex;
    NSMutableArray *_threads;
    dispatch_semaphore_t _lock;
}

+ (instancetype)instance {
    static JJTAFFMDBThreadPool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJTAFFMDBThreadPool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _threadIndex = 0;
        _threads = [NSMutableArray arrayWithCapacity:MAX_THREAD_POOL_SIZE];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (JJTAFFMDBThread *)obtain {
    return [self obtain:NO];
}

- (JJTAFFMDBThread *)obtain:(BOOL)standalone {
    JJTAFFMDBThread *thread = nil;
    
    // 选取策略
    // 1. 线程数<MAX_THREAD_POOL_SIZE,创建新线程
    // 2. 线程数>=MAX_THREAD_POOL_SIZE, 选取referenceCount最少的
    // 3. standalone=YES， 独占模式，这个线程的referenceCount只能为1，所以总会创建新线程
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    
    dispatch_semaphore_signal(_lock);
    
    return thread;
}

@end

//MARK: - JJTAFFMDBHelper

@implementation JJTAFFMDBHelper

@end
