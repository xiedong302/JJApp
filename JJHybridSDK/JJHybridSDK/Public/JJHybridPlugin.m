//
//  JJHybridPlugin.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import "JJHybridPlugin.h"
#import "JJHybridPluginManager.h"
#import "JJHybridPluginResult.h"
#import "JJHybridPluginEvent.h"

@interface JJHybridPlugin ()

@property (nonatomic, weak) JJHybridPluginManager *pluginManager;

@end
@implementation JJHybridPlugin

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _pluginName = [name copy];
    }
    return self;
}

- (void)initialize:(JJHybridPluginManager *)manager {
    self.pluginManager = manager;
    
    [self onInit];
}

- (BOOL)execute:(NSString *)callbackId action:(NSString *)action args:(NSDictionary *)args {
    return NO;
}

- (void)sendSuccessResult:(NSString *)callbackId data:(NSDictionary *)data {
    [self.pluginManager sendPluginResult:[JJHybridPluginResult success:callbackId data:data]];
}

- (void)sendErrorResult:(NSString *)callbackId message:(NSString *)message {
    [self.pluginManager sendPluginResult:[JJHybridPluginResult error:callbackId message:message]];
}

- (void)sendEvent:(NSString *)action data:(NSDictionary *)data {
    [self.pluginManager sendPluginEvent:[[JJHybridPluginEvent alloc] initWithPluginName:self.pluginName action:action data:data]];
}

- (void)presentViewController:(UIViewController *)controller {
    [self.pluginManager presentViewController:controller];
}

- (void)onInit {}

- (void)viewDidAppear {}

- (void)viewDisappear {}

@end
