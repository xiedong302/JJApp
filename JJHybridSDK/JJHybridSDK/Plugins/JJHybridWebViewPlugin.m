//
//  JJHybridWebViewPlugin.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridWebViewPlugin.h"
#import "JJHybridView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

//MARK: - Extension
@interface JJHybridView (JJHybridWebViewPlugin)

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSString *)icon alignmentLeft:(BOOL)alignmentLeft;

@end

@interface JJHybridWebViewPlugin ()

@property (nonatomic, weak) JJHybirdView *hybridView;

@end
@implementation JJHybridWebViewPlugin

- (instancetype)initWithHybridView:(JJHybirdView *)hybridView {
    
    _hybridView = hybridView;
    
    return [super initWithName:@"JJWebView"];
}


- (BOOL)execute:(NSString *)callbackId action:(NSString *)action args:(NSDictionary *)args {
    if ([action compare:@"setTitle"] == NSOrderedSame) {
        NSString *title = [args objectForKey:@"title"];
        NSString *subtitle = [args objectForKey:@"subTitle"];
        NSString *iconURL = [args objectForKey:@"icon"];
        BOOL alignmentLeft = [args[@"left"] boolValue];
        
//        [self.hybridView setTitle:title subtitle:subtitle icon:iconURL alignmentLeft:alignmentLeft];
        
        [self sendSuccessResult:callbackId data:nil];
    } else if ([action compare:@"setMenu"] == NSOrderedSame) {
        NSArray * array = [args objectForKey:@"items"];

        if(array) {
            NSMutableArray * items = [NSMutableArray arrayWithCapacity:4];
            
            for(NSDictionary * dict in array) {
                NSString * itemId = [dict objectForKey:@"id"];
                NSString * title = [dict objectForKey:@"title"];
                NSString * icon = [dict objectForKey:@"icon"];

                if(itemId && itemId.length > 0 && title && title.length > 0) {
                    JJHybridViewMenuItem * item = [[JJHybridViewMenuItem alloc] init];
                    item.itemId = itemId;
                    item.title = title;
                    item.icon = icon;

                    [items addObject:item];
                }
            }

            if(items) {
//                [self.hybridView setMenu:items];

                [self sendSuccessResult:callbackId data:nil];

                return true;
            }
        }

        [self sendErrorResult:callbackId message:@"set menu failed"];
    }
    return YES;
}

- (void)sendMenuEvent:(NSString *)itemId {
    if (itemId && itemId.length > 0) {
        [self sendEvent:@"menu" data:@{@"id" : itemId}];
    }
}

- (void)sendVisibleEvent {
    [self sendEvent:@"visible" data:nil];
}

- (void)sendInvisibleEvent {
    [self sendEvent:@"invisible" data:nil];
}

- (void)sendOnLoadEvent {
    [self sendEvent:@"onload" data:nil];
}
@end

#pragma clang diagnostic pop
