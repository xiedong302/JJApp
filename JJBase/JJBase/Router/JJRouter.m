//
//  JJRouter.m
//  JJBase
//
//  Created by xiedong on 2020/10/21.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJRouter.h"
#import "JJRouterPlaceholderUtil.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

NSString * const KJJRouterParamURL = @"__KJJRouterParamURL";
NSString * const KJJRouterParamClass = @"__KJJRouterParamClass";
NSString * const KJJRouterParamHandler = @"__KJJRouterParamHandler";

void JJRouterNavigate(NSString *url) {
    [JJRouter navigate:url];
}

@interface JJRouter()

@property (nonatomic, weak) id<JJRouterDelegate> delegate;
@property (nonatomic, strong) NSDictionary *routerDic;

@end
@implementation JJRouter

+ (instancetype)instance {
    static JJRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[JJRouter alloc] init];
    });
    return router;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"JJRouterConfig" withExtension:@"plist"];
        if (url) {
            _routerDic = [NSDictionary dictionaryWithContentsOfURL:url];
            
            if (!_routerDic) {
                JJTagLog(@"JJRouter", @"JJRouterConfig.plist load failed");
            }
        } else {
            JJTagLog(@"JJRouter",@"JJRouterConfig.plist not found");
        }
    }
    return self;
}

//MARK: public
+ (void)registerDelegate:(id<JJRouterDelegate>)delegate {
    NSAssert(NSThread.mainThread, @"Must be called in main thread");
    
    [JJRouter instance].delegate = delegate;
}

+ (void)showViewController:(UIViewController *)controller {
    [JJRouter showViewController:controller present:NO];
}

+ (void)showViewController:(UIViewController *)controller present:(BOOL)present {
    if (NSThread.isMainThread) {
        __strong id<JJRouterDelegate> delegate = [JJRouter instance].delegate;
        
        if (delegate && [delegate respondsToSelector:@selector(showViewController:present:)]) {
            [delegate showViewController:controller present:present];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong id<JJRouterDelegate> delegate = [JJRouter instance].delegate;
            
            if (delegate && [delegate respondsToSelector:@selector(showViewController:present:)]) {
                [delegate showViewController:controller present:present];
            }
        });
    }
}

+ (UIViewController *)visibleViewController {
    NSAssert(NSThread.mainThread, @"Must be called in main thread");
    
    if (!NSThread.isMainThread) {
        
        JJTagLog(@"JJRouter", @"visibleViewController called in thread: %@", NSThread.currentThread);
        
        return nil;
    }
    
    __strong id<JJRouterDelegate> delegate = [JJRouter instance].delegate;
    if (delegate && [delegate respondsToSelector:@selector(visibleViewController)]) {
        return [delegate visibleViewController];
    }
    
    return nil;
}


+ (UIViewController *)rootViewController {
    NSAssert(NSThread.mainThread, @"Must be called in main thread");
    
    if (!NSThread.isMainThread) {
        
        JJTagLog(@"JJRouter", @"rootViewController called in thread: %@", NSThread.currentThread);
        
        return nil;
    }
    
    __strong id<JJRouterDelegate> delegate = [JJRouter instance].delegate;
    if (delegate && [delegate respondsToSelector:@selector(rootViewController)]) {
        return [delegate rootViewController];
    }
    
    return nil;
}

+ (void)navigate:(NSString *)URLString {
    [JJRouter navigate:URLString withHandler:nil];
}

+ (void)navigate:(NSString *)URLString withHandler:(JJRouterHandler)handler {
    if (NSThread.isMainThread) {
        [[JJRouter instance] navigate:URLString withHandler:handler];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[JJRouter instance] navigate:URLString withHandler:handler];
        });
    }
}

+ (BOOL)canNavigate:(NSString *)URLString {
    if (!IsValidateString(URLString)) {
        return NO;
    }
    
    URLString = [URLString jj_trimWhitespaceAndNewLine];
    
    return [URLString hasPrefix:@"jjapp"] || [JJRouterPlaceholderUtil hasPlaceholder:URLString];
}

//MARK: private

- (void)navigate:(NSString *)URLString withHandler:(JJRouterHandler)handler {
    if (!IsValidateString(URLString)) {
        JJTagLog(@"JJRouter", @"Invalid url string : %@",URLString);
        return;
    }
    
    URLString  = [URLString jj_trimWhitespaceAndNewLine];
    
    JJTagLog(@"JJRouter", @"Raw url : %@",URLString);
    
    URLString = [self convertURLIfNeeded:URLString];
    
    JJTagLog(@"JJRouter", @"Navigate url : %@",URLString);
    
    NSURL *URLToNavigate = [NSURL URLWithString:URLString];
    
    if (!URLToNavigate) {
        JJTagLog(@"JJRouter", @"Invalid url : %@",URLToNavigate);
        return;
    }
    
    BOOL patternFound = NO;
    NSDictionary *dict = nil;
    
    for (NSString *pattern in self.routerDic) {
        NSRange range = [URLString rangeOfString:pattern options:NSCaseInsensitiveSearch | NSRegularExpressionSearch];
        
        if (range.location != NSNotFound) {
            patternFound = YES;
            dict = [self.routerDic objectForKey:pattern];
            
            break;
        }
    }
    
    if (!patternFound) {
        JJTagLog(@"JJRouter", @"No pattern for url : %@",URLString);
        return;
    }
    
    if (!IsValidateDict(dict)) {
        JJTagLog(@"JJRouter", @"Invalid router config for url : %@",URLString);
        return;
    }
    
    NSString *classString = [dict objectForKey:@"Class"];
    NSString *typeString = [dict objectForKey:@"Type"];
    
    JJTagLog(@"JJRouter", @"Router class: %@, type : %@",classString, typeString);
    
    if (!IsValidateString(classString)) {
        JJTagLog(@"JJRouter", @"Invalid class string %@",classString);
        return;
    }
    
    Class cls = NSClassFromString(classString);
    
    if (!cls) {
        JJTagLog(@"JJRouter", @"Class : %@ not found",classString);
        return;
    }
        
    //0-默认，创建对应View Controller来展示
    //1-dispatch, 根据参数返回一个View Controller来展示
    //2-custom, 自定义处理， 不一定是展示View Controller，可能会跳转到外部
    int navigationType = 0;
    if (IsValidateString(typeString)) {
        if ([typeString compare:@"default" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            navigationType = 0;
        } else if ([typeString compare:@"dispatch" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            navigationType = 1;
        } else if ([typeString compare:@"custom" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            navigationType = 2;
        }
    }
    
    NSDictionary *params = [URLString jj_extractURLQueryParams];
    NSDictionary *defaultParam = @{KJJRouterParamURL : URLToNavigate, KJJRouterParamClass : cls};
    
    if (handler) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:defaultParam];
        [tmp setObject:[handler copy] forKey:KJJRouterParamHandler];
        defaultParam = [tmp copy];
    }
    
    if (IsValidateDict(params)) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:params];
        [tmp addEntriesFromDictionary:defaultParam];
        params = [tmp copy];
    } else {
        params = defaultParam;
    }
    
    JJTagLog(@"JJRouter", @"Navigate param : %@",params);
    
    if (0 == navigationType) {
        [self navigateAsViewController:params];
    } else if (1 == navigationType) {
        id target = [[cls alloc] init];
        
        if ([target respondsToSelector:@selector(handleRouterDispatch:)]) {
            cls = [target handleRouterDispatch:params];
            
            if (cls) {
                JJTagLog(@"JJRouter", @"Dispatch is new class : %@",cls);
                
                NSMutableArray *tmp = [params mutableCopy];
                [tmp setValue:cls forKey:KJJRouterParamClass];
                params = [tmp copy];
            }
            
            [self navigateAsViewController:params];
        } else {
            JJTagLog(@"JJRouter", @"Class : %@ not responds to 'handleRouterDispatch:'",cls);
        }
    } else if (2 == navigationType) {
        id target = [[cls alloc] init];
        
        if ([target respondsToSelector:@selector(handleRouterCustom:)]) {
            [target handleRouterCustom:params];
        } else {
            JJTagLog(@"JJRouter", @"Class : %@ not responds to 'handleRouterCustom:'",cls);
        }
    }
}

- (NSString *)convertURLIfNeeded:(NSString *)URLString {
    if ([JJRouterPlaceholderUtil hasPlaceholder:URLString]) {
        URLString = [JJRouterPlaceholderUtil buildFullURL:URLString];
    }
    
    return URLString;
}

- (UIViewController *)navigateAsViewController:(NSDictionary *)params {
    Class cls = params[KJJRouterParamClass];
    
    if ([cls isSubclassOfClass:UIViewController.class]) {
        __strong id<JJRouterDelegate> delegate = self.delegate;
        
        if (!delegate) {
            JJTagLog(@"JJRouter", @"Router delegate not found");
            return nil;
        }
        
        if (![delegate respondsToSelector:@selector(showViewController:present:)]) {
            JJTagLog(@"JJRouter", @"Router delegate not responds to ‘showViewController:present:’");
            return nil;
        }
        
        UIViewController *vcToNavigate = nil;
        if ([delegate respondsToSelector:@selector(viewControllerForParams:)]) {
            vcToNavigate = [delegate viewControllerForParams:params];
        }
        
        if (!vcToNavigate) {
            vcToNavigate = [[cls alloc] init];
            JJTagLog(@"JJRouter", @"Create view controller %@",vcToNavigate);
        } else {
            JJTagLog(@"JJRouter", @"Go view controller %@",vcToNavigate);
        }
        
        if ([vcToNavigate respondsToSelector:@selector(handleRouter:)]) {
            [vcToNavigate handleRouter:params];
        }
        
        [delegate showViewController:vcToNavigate present:NO];
        
        return vcToNavigate;
    } else {
        JJTagLog(@"JJRouter", @"Class : %@ is not a UIViewController",cls);
    }
    
    return nil;
}


@end

@implementation NSObject (JJRouter)

- (void)handleRouter:(NSDictionary *)params {}

- (void)handleRouterCustom:(NSDictionary *)params {}

- (Class)handleRouterDispatch:(NSDictionary *)params {return  nil;}

@end


#pragma clang diagnostic pop
