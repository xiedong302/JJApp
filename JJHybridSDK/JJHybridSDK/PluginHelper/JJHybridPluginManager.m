//
//  JJHybridPluginManager.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import "JJHybridPluginManager.h"
#import "JJHybridPlugin.h"
#import "JJHybridPluginEvent.h"
#import "JJHybridPluginResult.h"
#import "JJHybridEngine.h"
#import "JJHybridJSON.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

//MARK: - JJHybridPlugin
@interface JJHybridPlugin (JJHybridPluginManager)

- (void)initialize:(JJHybridPluginManager *)manager;

@end

//MARK: - JJHybridEventHandlePlugin
@interface JJHybridEventHandlePlugin : JJHybridPlugin

@end

@implementation JJHybridEventHandlePlugin

- (instancetype)init {
    return [super initWithName:@"JJEvent"];
}

- (BOOL)execute:(NSString *)callbackId action:(NSString *)action args:(NSDictionary *)args {
    return YES;
}

@end

//MARK: - JJHybridPluginManager
@interface JJHybridPluginManager ()

@property (nonatomic, weak) JJHybridEngine *engine;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *plugins;

@end
@implementation JJHybridPluginManager

- (instancetype)initWithEngine:(JJHybridEngine *)engine {
    self = [super init];
    if (self) {
        __weak JJHybridEngine *weakEngine = engine;
        _engine = weakEngine;
        _queue = [NSOperationQueue mainQueue];
        _plugins = [NSMutableDictionary dictionaryWithCapacity:4];
        
        [_queue setName:@"JJHybridPluginManager"];
        [_queue setMaxConcurrentOperationCount:1];
        
        JJHybridEventHandlePlugin *eventPlugin = [[JJHybridEventHandlePlugin alloc] init];
        
        [self addPlugin:eventPlugin];
        
    }
    return self;
}

- (void)addPlugin:(JJHybridPlugin *)plugin {
    [self.queue addOperationWithBlock:^{
        [self.plugins setObject:plugin forKey:plugin.pluginName];
        
        [plugin initialize:self];
    }];
}

- (void)sendPluginResult:(JJHybridPluginResult *)result {
    NSString *js = [result encode];
    
    [self.queue addOperationWithBlock:^{
        [self.engine executeJavascript:js completionHandler:nil];
    }];
}

- (void)sendPluginEvent:(JJHybridPluginEvent *)event {
    NSString *js = [event encode];
    
    [self.queue addOperationWithBlock:^{
        [self.engine executeJavascript:js completionHandler:nil];
    }];
}

- (void)presentViewController:(UIViewController *)controller {
    [self.engine presentViewController:controller];
}

- (void)onJsRequest:(NSString *)request {
    NSArray *array = [JJHybridJSON toJSONObject:request];
        
    [self.queue addOperationWithBlock:^{
       
        NSString *callbackId = @"";
        
        @try {
            if (!array || array.count < 2) {
                [NSException raise:NSInvalidArgumentException format:@"Bad request argument : %@", request];
            }
            
            NSString *cmdStr = array[0];
            NSDictionary *args = array[1];
            
            NSString *service = nil;
            NSString *action = nil;
            
            if (cmdStr && cmdStr.length > 0) {
                NSArray *cmds = [cmdStr componentsSeparatedByString:@"."];
                
                if (cmds && cmds.count >=2) {
                    service = cmds[0];
                    action = cmds[1];
                }
            }
            
            if (args) {
                callbackId = [NSString stringWithFormat:@"%@", [args objectForKey:@"callbackId"]];
            }
            
            if (!service || service.length < 0) {
                [NSException raise:NSInvalidArgumentException format:@"Service name is empty"];
            }
            
            if (!action || action.length < 0) {
                [NSException raise:NSInvalidArgumentException format:@"Action name is empty"];
            }
            
            JJHybridPlugin *plugin = [self.plugins objectForKey:service];
            
            if (!plugin) {
                [NSException raise:NSInvalidArgumentException format:@"Service not found : %@",service];
            }
            
            if (!callbackId || callbackId.length < 0) {
                [NSException raise:NSInvalidArgumentException format:@"callbackId is empty"];
            }
            
            if (![plugin execute:callbackId action:action args:args]) {
                [NSException raise:NSInvalidArgumentException format:@"Action not found : %@",action];
            }
            
        } @catch (NSException *exception) {
            [self sendPluginResult:[JJHybridPluginResult error:callbackId message:exception.reason]];
        }
    }];
}


- (void)reset {
    [self.queue cancelAllOperations];
}

- (void)handleViewAppear {
    [self.queue addOperationWithBlock:^{
        for (JJHybridPlugin *plugin in self.plugins.objectEnumerator) {
            [plugin viewDidAppear];
        }
    }];
}

- (void)handleViewDisappear {
    [self.queue addOperationWithBlock:^{
        for (JJHybridPlugin *plugin in self.plugins.objectEnumerator) {
            [plugin viewDisappear];
        }
    }];
}

- (void)dealloc {
    [self reset];
}

@end

#pragma clang diagnostic pop
