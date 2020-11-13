//
//  JJTimer.m
//  JJBase
//
//  Created by xiedong on 2020/11/13.
//

#import "JJTimer.h"

@interface JJTimer ()

@property (nonatomic, strong) NSMutableDictionary *timerDict;

@end

@implementation JJTimer
//MARK: - LifeCircle
- (instancetype)init {
    if (self = [super init]) {
        self.timerDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

+ (instancetype)sharedTimer {
    static JJTimer *timer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [[JJTimer alloc] init];
    });
    return timer;
}
//MARK: - Private
- (void)scheduleTimerWithIndentifier:(NSString *)identifier timeInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue repeat:(BOOL)repeat block:(dispatch_block_t)block {
    if (!identifier) {
        return;
    }
    if (!queue) {
        queue = dispatch_get_main_queue();
    }
    dispatch_source_t timer = self.timerDict[identifier];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        self.timerDict[identifier] = timer;
    }
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval * NSEC_PER_SEC, 0);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        block();
        
        if (!repeat) {
            __strong JJTimer *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf cancelTiemrWithIndentifier:identifier];
            }
        }
    });
}

- (void)cancelTiemrWithIndentifier:(NSString *)identifier {
    dispatch_source_t timer = self.timerDict[identifier];
    
    if (!timer) {
        return;
    }
    
    [self.timerDict removeObjectForKey:identifier];
    dispatch_source_cancel(timer);
}

//MARK: - Public
+ (void)scheduleTimerWithIndentifier:(NSString *)identifier timeInterval:(NSTimeInterval)timeInterval repeat:(BOOL)repeat block:(dispatch_block_t)block {
    [self scheduleTimerWithIndentifier:identifier timeInterval:timeInterval queue:dispatch_get_main_queue() repeat:repeat block:block];
}

+ (void)scheduleTimerWithIndentifier:(NSString *)identifier timeInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue repeat:(BOOL)repeat block:(dispatch_block_t)block {
    [[JJTimer sharedTimer] scheduleTimerWithIndentifier:identifier timeInterval:interval queue:queue repeat:repeat block:block];
}

+ (void)cancelTiemrWithIndentifier:(NSString *)identifier {
    [[JJTimer sharedTimer] cancelTiemrWithIndentifier:identifier];
}
@end
