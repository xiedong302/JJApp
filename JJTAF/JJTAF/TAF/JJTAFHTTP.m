//
//  JJTAFHTTP.m
//  JJTAF
//
//  Created by xiedong on 2020/11/23.
//

#import "JJTAFHTTP.h"

//MARK: - AFNetworking hack

@interface JJTAFHTTPBodyPart : NSObject
@property (nonatomic, assign) NSStringEncoding stringEncode;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, copy) NSString *boundary;
@property (nonatomic, strong) id body;
@property (nonatomic, assign) unsigned long long bodyContentLength;
@property (nonatomic, strong) NSInputStream *inputStream;

@property (nonatomic, assign) BOOL hasInitialBoundary;
@property (nonatomic, assign) BOOL hasFinalBoundary;

@property (nonatomic, assign, readonly, getter=hasBytesAvailable) BOOL bytesAvailable;
@property (nonatomic, assign, readonly) unsigned long long contentLength;

- (NSInteger)read:(uint8_t)buffer maxLength:(NSUInteger)length;

@end

