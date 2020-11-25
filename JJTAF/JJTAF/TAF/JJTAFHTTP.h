//
//  JJTAFHTTP.h
//  JJTAF
//
//  Created by xiedong on 2020/11/23.
//

#import <Foundation/Foundation.h>
#import "JJTAFJSONObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JJTAFHTTPRequestBody <NSObject>

- (NSURLSessionTask *)createSessionTask:(NSURLSession *)session request:(NSMutableURLRequest *)request;

@end

//MARK: - JJTAFHTTPRequestDataBody
@interface JJTAFHTTPRequestDataBody : NSObject <JJTAFHTTPRequestBody>

+ (instancetype)dataBodyWithData:(NSData *)data;

+ (instancetype)dataBodyWithFile:(NSURL *)file;

@end

//MARK: - JJTAFHTTPRequestFormBody

@interface JJTAFHTTPRequestFormBody : NSObject <JJTAFHTTPRequestBody>

- (void)add:(NSString *)name value:(NSString *)value;

- (void)addEncode:(NSString *)name value:(NSString *)value;

@end

//MARK: - JJTAFHTTPRequestJSONBody
@interface JJTAFHTTPRequestJSONBody : NSObject <JJTAFHTTPRequestBody>

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

//MARK: - JJTAFHTTPRequestMultipartBody
@interface JJTAFHTTPRequestMultipartBody : NSObject <JJTAFHTTPRequestBody>

- (void)add:(NSString *)name value:(NSString *)value;

- (void)add:(NSString *)name data:(NSData *)data;

- (void)add:(NSString *)name file:(NSURL *)file;

@end

//MARK: - JJTAFHTTPReuqest
@interface JJTAFHTTPReuqest : NSObject

+ (instancetype)get:(NSString *)URLString;

+ (instancetype)get:(NSString *)URLString timeout:(NSTimeInterval)timeout;

+ (instancetype)post:(NSString *)URLString body:(id<JJTAFHTTPRequestBody>)body;

+ (instancetype)post:(NSString *)URLString body:(id<JJTAFHTTPRequestBody>)body timeout:(NSTimeInterval)timeout;

- (NSURL *)getURL;

/**
 * @abstract
 * 添加到Header，会被encode
 */
- (void)addHeader:(NSString *)name value:(NSString *)value;

/**
 * @abstract
 * 添加已被encode到Header
 */
- (void)addEncodeHeader:(NSString *)name value:(NSString *)value;

/**
 * @abstract
 * 添加到Header，会被encode
 */
- (void)addHeaders:(NSDictionary *)headers;

/**
 * @abstract
 * 添加Path,会被encode，支持a/b/c这样的多级形式
 */
- (void)addPath:(NSString *)pathSegment;

/**
 * @abstract
 * 添加query，会被encode
 */
- (void)addQueryParamter:(NSString *)name value:(NSString *)value;

@end

//MARK: - JJTAFHTTPResponse
@interface JJTAFHTTPResponse : NSObject

@property (nonatomic, assign, readonly) int code;

@property (nonatomic, copy, readonly) NSString *contentType;

@property (nonatomic, assign, readonly) long contentLength;

- (BOOL)isSuccessful;

- (NSError *)error;

- (NSString *)getHeader:(NSString *)name;

- (NSArray *)getHeaders:(NSString *)name;

- (NSDictionary *)allHeaders;

- (NSData *)data;

- (NSString *)string;

- (JJTAFJSONObject *)jsonObject;

- (JJTAFJSONArray *)jsonArray;

@end

//MARK: - JJTAFHTTPClientURLRewriter
@protocol JJTAFHTTPClientURLRewriter <NSObject>

@optional

- (NSString *)httpClientHandleURL:(NSString *)URLString;

@end

//MARK: - JJTAFHTTPClient
typedef NS_ENUM(NSInteger, JJTAFHTTPClientSSLChallengeMode) {
    JJTAFHTTPClientSSLChallengeModeNone, // 忽略
    JJTAFHTTPClientSSLChallengeModeSimple, // 不校验host
    JJTAFHTTPClientSSLChallengeModeFull // 正常校验
};

typedef void (^JJTAFHTTPHandler)(JJTAFHTTPResponse *response);

@interface JJTAFHTTPClient : NSObject

@property (nonatomic, assign) BOOL enableRedirect; // 默认YES

@property (nonatomic, assign) JJTAFHTTPClientSSLChallengeMode sslChallengeMode; // 默认JJTAFHTTPClientSSLChallengeModeFull

/**
 * @abstract
 * return HTTPClient, handler queue 为 main queue， 禁止缓存，允许重定向，JJTAFHTTPClientSSLChallengeModeNone
 */
+ (instancetype)defaultHTTPClient;

/**
 * @abstract
 * 设置全局的JJTAFHTTPClientURLRewriter
 */
- (void)setURLRewriter:(id<JJTAFHTTPClientURLRewriter>)URLRewriter;

/**
 * @abstract
 * 使用传递进来的handler queue来创建一个HTTPClient
 *
 * @param queue
 * handler queue
 *
 * @param enableCache
 * 是否允许缓存
 */
- (instancetype)initWithHandlerQueue:(dispatch_queue_t)queue enableCache:(BOOL)enableCache;

/**
 * @abstract
 * 发送数据请求，这里有一个要特别注意的限制，同一个request，不要sendRequest多次
 * 这是因为HTTPClient内部没有对Request做深度copy，对象就会复用，部分类型的请求可能会跪
 */
- (void)sendRequest:(JJTAFHTTPReuqest *)request handle:(JJTAFHTTPHandler)handler;

/**
 * @abstract
 * HTTPClient不在使用的时候，需要调用invalidate，不然可能会泄漏，NSURLSession的bug
 * 一般在dealloc里面撸一下就可以了， UI组件里面切记要调用
 *
 * @param cancelPendingTasks
 * 是否取消还没执行的请求
 */
- (void)invalidate:(BOOL)cancelPendingTasks;

@end

//MARK: - JJTAFHTTPDownloader
@class JJTAFHTTPDownloader;

@protocol JJTAFHTTPDownloaderDelegate <NSObject>

- (void)httpDownloader:(JJTAFHTTPDownloader *)downloader didUpdateProgress:(int)progress;

- (void)httpDownloader:(JJTAFHTTPDownloader *)downloader didFinishWithError:(NSError *)error;

@end

@interface JJTAFHTTPDownloader : NSObject

@property (nonatomic, weak) id<JJTAFHTTPDownloaderDelegate> delegate; // 主线程调用
@property (nonatomic, copy, readonly) NSString *downloadURL; // 下载地址
@property (nonatomic, copy, readonly) NSString *savePath; // 保存路径
@property (nonatomic, assign, readonly) int progress; // 1 ~ 100

/**
 * @abstract
 * 创建一个JJTAFHTTPDownloader
 *
 * @param downloadURL
 * 下载地址
 *
 * @param savePath
 * 保存路径
 */
- (instancetype)initWithURL:(NSString *)downloadURL toPath:(NSString *)savePath;

- (void)start;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
