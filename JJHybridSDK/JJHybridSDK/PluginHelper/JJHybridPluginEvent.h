//
//  JJHybridPluginEvent.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHybridPluginEvent : NSObject

@property (nonatomic, copy, readonly) NSString *plugin;
@property (nonatomic, copy, readonly) NSString *action;
@property (nonatomic, strong, readonly) NSDictionary *data;

- (instancetype)initWithPluginName:(NSString *)plugin action:(NSString *)action data:(NSDictionary *)data;

- (NSString *)encode;

@end

NS_ASSUME_NONNULL_END
