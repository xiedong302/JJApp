//
//  JJHybridPluginEvent.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridPluginEvent.h"
#import "JJHybridJSON.h"

@implementation JJHybridPluginEvent

- (instancetype)initWithPluginName:(NSString *)plugin action:(NSString *)action data:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _plugin = [plugin copy];
        _action = [action copy];
        _data = data;
    }
    return self;
}

- (NSString *)encode {
    NSString *js = @"javascript:window.nativeFireEvent(";
    
    js = [js stringByAppendingString:@"'"];
    js = [js stringByAppendingString:self.plugin];
    js = [js stringByAppendingString:@"'"];
    js = [js stringByAppendingString:@","];
    
    js = [js stringByAppendingString:@"'"];
    
    NSMutableDictionary *json;
    if (self.data) {
        json = [NSMutableDictionary dictionaryWithDictionary:self.data];
    } else {
        json = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    if (self.action) {
        [json setValue:self.action forKey:@"action"];
    }
    
    js = [js stringByAppendingString:[JJHybridJSON dictionaryToJSON:json]];
    js = [js stringByAppendingString:@"'"];
    
    js = [js stringByAppendingString:@")"];
    
    return js;
}
@end
