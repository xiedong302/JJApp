//
//  JJTAFHandler.m
//  JJTAF
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#include <sys/sysctl.h>
#include <sys/time.h>

#import "JJTAFHandler.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wnonnull"

//MARK: - JJTAFHandlerMessage
@interface JJTAFHandlerMessage : NSObject

@property (nonatomic, assign) uint64_t msgId;
@property (nonatomic, strong) id object;

//For sendMessage
@property (nonatomic, assign) int what;

//For postBlock
@property (nonatomic, copy) post_block_t block;
@property (nonatomic, copy) NSString *blockKey;

//For postSelector
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, assign) uint64_t triggerTime;

@property (nonatomic, strong) JJTAFHandlerMessage *next;

@end

@implementation JJTAFHandlerMessage
@end

//MARK: - JJTAFHandler
@interface JJTAFHandler()

@property (nonatomic, weak) id<JJTAFHandlerDelegate> delegate;

//单向链表结构
@property (nonatomic, strong) JJTAFHandlerMessage *messages;

@property (nonatomic, assign) uint64_t messageId;

@property (nonatomic, strong) dispatch_queue_t myQueue;

@property (nonatomic, strong) dispatch_source_t myTimer;

@property (nonatomic, strong) NSMutableString *reuseLogString;

- (void)log:(NSString *)format,... NS_FORMAT_FUNCTION(1, 2);

@end

@implementation JJTAFHandler {
    void *myQueueSpecific;
}

+ (instancetype)mainHandlerWithDelegate:(id<JJTAFHandlerDelegate>)delegate {
    return [[JJTAFHandler alloc] initWithSerialQueue:dispatch_get_main_queue() delegate:delegate];
}

- (instancetype)initWithName:(NSString *)name delegate:(id<JJTAFHandlerDelegate>)delegate {
    if (!name || name.length <= 0) {
        name = @"JJTAFHandler";
    }
    return [self initWithSerialQueue:dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL) delegate:delegate];
}

- (instancetype)initWithSerialQueue:(dispatch_queue_t)queue delegate:(id<JJTAFHandlerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        _messageId = 0;
        
        _myQueue = queue;
        
        myQueueSpecific = &myQueueSpecific;
        
        void * nonNullUnusedPointer = (__bridge void *)self;
        
        dispatch_queue_set_specific(_myQueue, myQueueSpecific, nonNullUnusedPointer, NULL);
        
        _myTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _myQueue);
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_source_set_event_handler(_myTimer, ^{
            __strong JJTAFHandler *strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf dequeueMessage];
            }
        });
        
        dispatch_resume(_myTimer);
        
        _reuseLogString = [NSMutableString stringWithCapacity:256];
        
        _debugMode = NO;
        
    }
    return self;
}

- (void)dealloc {
    [self log:@"[JJTAFHandler] dealloc"];
    
    dispatch_source_cancel(_myTimer);
    
    if (dispatch_get_specific(myQueueSpecific)) {
        self.messages = nil;
    } else {
        dispatch_sync(self.myQueue, ^{
            self.messages = nil;
        });
    }
}

//MARK: - Public
- (void)sendMessage:(int)what {
    [self sendMessageDelayed:what delayMills:0];
}

- (void)sendMessage:(int)what object:(id)anObject {
    [self sendMessageDelayed:what object:anObject delayMills:0];
}

- (void)sendMessageDelayed:(int)what delayMills:(uint64_t)delayTime {
    [self sendMessageDelayed:what object:nil delayMills:delayTime];
}

- (void)sendMessageDelayed:(int)what object:(id)anObject delayMills:(uint64_t)delayTime {
    JJTAFHandlerMessage *message = [[JJTAFHandlerMessage alloc] init];
    message.what = what;
    message.object = anObject;
    message.triggerTime = [self getTriggerTime:delayTime];
    
    [self enqueueMessage:message];
}

- (void)postBlock:(post_block_t)block forKey:(NSString *)key {
    [self postBlockDelayed:block forKey:key delayMills:0];
}

- (void)postBlockDelayed:(post_block_t)block forKey:(NSString *)key delayMills:(uint64_t)delayTime {
    if (block) {
        JJTAFHandlerMessage *message = [[JJTAFHandlerMessage alloc] init];
        message.block = block;
        message.blockKey = key;
        message.triggerTime = [self getTriggerTime:delayTime];
        
        [self enqueueMessage:message];
    }
}

- (void)postSelector:(id)target selector:(SEL)selector {
    [self postSelectorDelayed:target selector:selector delayMills:0];
}

- (void)postSelector:(id)target selector:(SEL)selector object:(id)anObject {
    [self postSelectorDelayed:target selector:selector object:anObject delayMills:0];
}

- (void)postSelectorDelayed:(id)target selector:(SEL)selector delayMills:(uint64_t)delayTime {
    [self postSelectorDelayed:target selector:selector object:nil delayMills:delayTime];
}

- (void)postSelectorDelayed:(id)target selector:(SEL)selector object:(id)anObject delayMills:(uint64_t)delayTime {
    if (target && selector) {
        JJTAFHandlerMessage *message = [[JJTAFHandlerMessage alloc] init];
        message.target = target;
        message.selector = selector;
        message.object = anObject;
        message.triggerTime = [self getTriggerTime:delayTime];
        
        [self enqueueMessage:message];
    }
}

- (void)removeMessage:(int)what {
    dispatch_async(self.myQueue, ^{
        [self log:@"[JJTAFHandler] removeMessage %i",what];
        
        JJTAFHandlerMessage *current = self.messages;
        //移除前面的
        while (current && current.what == what) {
            self.messages = current.next;
            current = current.next;
        }
        
        JJTAFHandlerMessage *next = nil;
        //移除后面的
        while (current) {
            next = current.next;
            
            if (next && next.what == what) {
                current.next = next.next;
                continue;
            }
            
            current = next;
        }
        
        [self scheduleNextTimer];
    });
}

- (void)removeBlockWithKey:(NSString *)key {
    if (!key) {
        return;
    }
    
    dispatch_async(self.myQueue, ^{
        [self log:@"[JJTAFHandler] removeBlockWithKey %@",key];
        
        JJTAFHandlerMessage *current = self.messages;
        
        //移除前面的
        while (current && current.blockKey && [current.blockKey isEqualToString:key]) {
            self.messages = current.next;
            current = current.next;
        }
        
        JJTAFHandlerMessage *next = nil;
        
        //移除后面的
        while (current) {
            next = current.next;
            
            if (next && next.blockKey && [next.blockKey isEqualToString:key]) {
                current.next = next.next;
                continue;
            }
            
            current = next;
        }
        
        [self scheduleNextTimer];
    });
}

- (void)removeSelector:(id)target selector:(SEL)selector {
    if (!target || !selector) {
        return;
    }
    
    dispatch_async(self.myQueue, ^{
        [self log:@"[JJTAFHandler] removeSelector %s : %s", object_getClassName(target), sel_getName(selector)];
        
        JJTAFHandlerMessage *current = self.messages;
        
        NSString *selectorName = NSStringFromSelector(selector);
        NSString *mySelectorName = nil;
        
        //移除前面的
        while (current && current.target && current.selector) {
            mySelectorName = NSStringFromSelector(current.selector);
            
            if (current.target == target && [mySelectorName isEqualToString:selectorName]) {
                self.messages = current.next;
                current = current.next;
            } else {
                break;
            }
        }
        
        JJTAFHandlerMessage *next = nil;
        
        //移除后面的
        while (current) {
            next = current.next;
            
            if (next && next.target && next.selector) {
                mySelectorName = NSStringFromSelector(next.selector);
                
                if (next.target == target && [mySelectorName isEqualToString:selectorName]) {
                    current.next = next.next;
                    continue;
                }
            }
            
            current = next;
        }
        
        [self scheduleNextTimer];
    });
}

- (void)removeAll {
    dispatch_async(self.myQueue, ^{
        [self log:@"[JJTAFHandler] removeAll"];
        self.messages = nil;
    });
}
//MARK: - Private
- (uint64_t)getTriggerTime:(uint64_t)delayTime {
    uint64_t now = [self systempJJtime];
    
    return now + delayTime;
}

- (uint64_t)systempJJtime {
    uint64_t jjtime = 0;
    
    struct timeval now;
    struct timeval tz;
    gettimeofday(&now, &tz);
    
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        jjtime = (uint64_t)
            ((now.tv_sec - boottime.tv_sec) * 1000.0 +
            (now.tv_usec - boottime.tv_usec) / 1000.0);
    }
    return jjtime;
}

- (void)enqueueMessage:(JJTAFHandlerMessage *)message {
    dispatch_async(self.myQueue, ^{
        message.msgId = self.messageId++;
        
        [self log:@"[JJTAFHandler] enqueueMessage %"PRIu64" trigger at %"PRIu64, message.msgId, message.triggerTime];
        
        JJTAFHandlerMessage *prev = nil;
        JJTAFHandlerMessage *current = self.messages;
        
        if (!current || message.triggerTime == 0 || message.triggerTime < current.triggerTime) {
            message.next = current;
            self.messages = message;
        } else {
            for (; ;) {
                prev = current;
                current = current.next;
                
                if (!current || message.triggerTime < current.triggerTime) {
                    break;
                }
            }
            
            prev.next = message;
            message.next = current;
        }
        
        [self scheduleNextTimer];
    });
}

- (void)dequeueMessage {
    JJTAFHandlerMessage *current = self.messages;
    
    if (current) {
        [self log:@"[JJTAFHandler] dequeueMessage"];
        
        uint64_t now = [self systempJJtime];
        
        if (current.triggerTime <= now) {
            [self log:@"[JJTAFHandler] dequeueMassage %"PRIu64, current.msgId];
            
            if (current.target && current.selector) {
                __strong id strongTarget = current.target;
                
                if (strongTarget && [strongTarget respondsToSelector:current.selector]) {
                    [strongTarget performSelector:current.selector withObject:current.object];
                }
            } else if (current.block) {
                current.block();
            } else {
                __strong id<JJTAFHandlerDelegate> strongDelegate = self.delegate;
                
                if (strongDelegate && [strongDelegate respondsToSelector:@selector(handleMessage:object:)]) {
                    [strongDelegate handleMessage:current.what object:current.object];
                }
            }
            
            self.messages = current.next;
        }
        
        [self scheduleNextTimer];
    }
}

- (void)scheduleNextTimer {
    [self printQueue];
    
    JJTAFHandlerMessage *current = self.messages;
    
    if (current) {
        uint64_t now = [self systempJJtime];
        uint64_t delay = MAX(0, current.triggerTime - now);
        
        //如果delay的值很小的话，直接dequeue
        //这么做的原因是为了避免频繁enqueue导致timer一直被reset，消息持续无法执行
        if (delay <= 10) {
            dispatch_async(self.myQueue, ^{
                [self dequeueMessage];
            });
        } else {
            dispatch_source_set_timer(self.myTimer, dispatch_walltime(NULL, delay * NSEC_PER_MSEC), DISPATCH_TIME_FOREVER, 0);
        }
    }
}

- (void)printQueue {
    if (!self.debugMode) {
        return;
    }
    
    NSMutableString *queueInfo = self.reuseLogString;
    
    JJTAFHandlerMessage *current = self.messages;
    
    [queueInfo setString:@"{ "];
    
    while (current) {
        if (current.block) {
            [queueInfo appendFormat:@"(id: %"PRIu64" key: %@ time: %"PRIu64")", current.msgId, current.blockKey, current.triggerTime];
        } else {
            [queueInfo appendFormat:@"(id: %"PRIu64" key: %i time: %"PRIu64")", current.msgId, current.what, current.triggerTime];
        }
        
        current = current.next;
        
        if (current) {
            [queueInfo appendString:@" -> "];
        }
    }
    
    [queueInfo appendString:@" }"];
    
    [self log:@"[JJTAFHandler] %@",queueInfo];
}

- (void)log:(NSString *)format, ... {
    if (!self.debugMode) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    
    NSLogv(format, args);
    
    va_end(args);
}

@end

#pragma clang diagnostic pop

