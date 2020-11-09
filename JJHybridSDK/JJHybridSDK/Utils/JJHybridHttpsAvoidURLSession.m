//
//  JJHybridHttpsAvoidURLSession.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridHttpsAvoidURLSession.h"

@interface JJHybridHttpsAvoidURLSession ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end
@implementation JJHybridHttpsAvoidURLSession

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 30;
        
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}
+ (instancetype)sharedSession {
    static JJHybridHttpsAvoidURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[JJHybridHttpsAvoidURLSession alloc] init];
    });
    return session;
}

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nonnull, NSURLResponse * _Nonnull, NSError * _Nonnull))completionHandler {
    return [self.session dataTaskWithURL:url completionHandler:completionHandler];;
}

//MARK: - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if (completionHandler) {
        NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    
}
@end
