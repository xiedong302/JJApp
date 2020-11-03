//
//  JJLogger.m
//  JJBase
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJLogger.h"
#import "JJHandler.h"
#import "JJFileUploader.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#pragma clang diagnostic ignored "-Wnonnull"

void JJTagLog(NSString *identifier, NSString *format, ...) {
    va_list args; //定义一个指向个数可变的参数列表指针
    
    va_start(args, format); //得到第一个可变参数的地址
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    
    [JJLogger logForIdentifier:identifier message:msg toFile:NO];
    
    va_end(args); //置空
}

void JJTagLogFile(NSString *identifier, NSString *format, ...) {
    va_list args; //定义一个指向个数可变的参数列表指针
    
    va_start(args, format); //得到第一个可变参数的地址
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    
    [JJLogger logForIdentifier:identifier message:msg toFile:YES];
    
    va_end(args); //置空
}

//MARK: - JJLoggerObject
@interface JJLoggerObject : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *msg;

@end

@implementation JJLoggerObject

@end

//MARK: - JJLoggerObject

static BOOL _debuggable = NO;

@implementation JJLogger {
    JJHandler *_handler;
    NSMutableDictionary *_logCache;
    NSMutableString *_cacheString;
    NSDateFormatter *_dateFormatter;
    NSUInteger _totalLogCount;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _handler = [[JJHandler alloc] initWithName:@"JJLoggerHandler" delegate:nil];
        _logCache = [NSMutableDictionary dictionaryWithCapacity:8];
        _cacheString = [NSMutableString stringWithCapacity:256];
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        _totalLogCount = 0;
    }
    
    return self;
}

+ (instancetype)shared {
    static JJLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[JJLogger alloc] init];
    });
    
    return logger;
}

//MARK: - Public
+ (void)logForIdentifier:(NSString *)identifier message:(NSString *)msg toFile:(BOOL)toFile {
    [[JJLogger shared] logForIdentifier:identifier message:msg toFile:toFile];
}

+ (void)uploadForIdentifier:(NSString *)identifier {
    [[JJLogger shared] uploadForIdentifier:identifier];
}

+ (NSString *)logFilePathForIdentifier:(NSString *)identifier {
    return [[JJLogger shared] logFilePathForIdentifier:identifier createFile:NO];
}

+ (void)setDebug:(BOOL)debuggable {
    _debuggable = debuggable;
}

//MARK: - Privete
- (void)logForIdentifier:(NSString *)identifier message:(NSString *)msg toFile:(BOOL)toFile {
    if (!identifier && identifier.length == 0) {
        identifier = @"JJLogger";
    }
    
    JJLog(@"[%@] %@",identifier, msg);
    
    if (_debuggable || toFile) {
        NSDate *date = [NSDate date];
        
        [_handler postBlock:^{
            
            NSMutableArray *list = [self->_logCache objectForKey:identifier];
            
            if (!list) {
                list = [NSMutableArray arrayWithCapacity:32];
                [self->_logCache setObject:list forKey:identifier];
            }
            
            JJLoggerObject *obj = [[JJLoggerObject alloc] init];
            obj.date = date;
            obj.msg = msg;
            
            [list addObject:obj];
            
            self->_totalLogCount++;
            
            if (list.count >= 32 || self->_totalLogCount >= 256) {
                [self writeLog];
            }
            
            [self->_handler removeBlockWithKey:@"WRITE_LOG"];
            [self->_handler postBlockDelayed:^{
                [self writeLog];
            } forKey:@"WRITE_LOG" delayMills:10 * 1000];
            
        } forKey:nil];
    }
}

- (void)uploadForIdentifier:(NSString *)identifier {
    [_handler postBlock:^{
        [self writeLog];
        
        NSString *path = [self logFilePathForIdentifier:identifier createFile:NO];
        
        [JJFileUploader uploadSync:identifier path:path uploadPath:@"app_upload_log"];
        
    } forKey:nil];
}

- (void)writeLog {
    NSMutableDictionary *logCache = _logCache;
    
    if (logCache.count > 0) {
        for (NSString *identifier in logCache) {
            NSMutableArray *logs = [logCache objectForKey:identifier];
            
            if (logs.count > 0) {
                [self writeLog:identifier logs:logs];
            }
            
            _totalLogCount -= logs.count;
            
            [logs removeAllObjects];
        }
        
        if (logCache.count >= 8) {
            [logCache removeAllObjects];
        }
    }
}

- (void)writeLog:(NSString *)identifier logs:(NSArray *)logs {
    NSString *path = [self logFilePathForIdentifier:identifier createFile:YES];
    
    JJLog(@"[JJLogger] Write log for : %@ %@", identifier, path);
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    
    if (fileHandle) {
        BOOL deleteLigFile = NO; //遇到异常情况删除日志文件
        
        @try {
            // trim 日志
            if (fileHandle.offsetInFile >= 500 * 1024) {
                JJLog(@"[JJLogger] Trim log file for : %@", identifier);
                
                [fileHandle seekToFileOffset:0];
                
                NSData *data = [fileHandle readDataToEndOfFile];
                //清空文件
                [fileHandle truncateFileAtOffset:0];
                
                if (data) {
                    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSArray *array = [content componentsSeparatedByString:@"\n"];
                    
                    if (array && array.count > 0) {
                        [fileHandle seekToFileOffset:0];
                        
                        //trim掉前2/3行
                        NSUInteger offset = array.count * 2 / 3;
                        array = [array subarrayWithRange:NSMakeRange(offset, array.count - offset)];
                        content = [array componentsJoinedByString:@"\n"];
                        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
                        [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                }
                [fileHandle seekToEndOfFile];
            } else {
                [fileHandle seekToEndOfFile];
            }
            
            for (JJLoggerObject *log in logs) {
                NSData *data = [self buildFullLogData:identifier message:log.msg date:log.date];
                [fileHandle writeData:data];
            }
        } @catch (NSException *exception) {
            JJLog(@"[JJLogger] Write log for : %@ failed", identifier);
            
            deleteLigFile = YES;
        } @finally {
            [fileHandle closeFile];
        }
        
        if (deleteLigFile) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

- (NSString *)logFilePathForIdentifier:(NSString *)identifier createFile:(BOOL)createFile {
    NSString *rootDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *loggerDir = [rootDir stringByAppendingPathComponent:@"jj_base_logger"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:loggerDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:loggerDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *logFilePath = [loggerDir stringByAppendingPathComponent:[identifier stringByAppendingString:@".log"]];
    
    if (createFile && ![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    }
    
    return logFilePath;
}

- (NSData *)buildFullLogData:(NSString *)identifier message:(NSString *)msg date:(NSDate *)date {
    [_cacheString setString:@""];
    [_cacheString appendFormat:@"%@ [%@] %@",[_dateFormatter stringFromDate:date], identifier, msg];
    [_cacheString appendFormat:@"\n"];
    
    return [_cacheString dataUsingEncoding:NSUTF8StringEncoding];
}
@end

#pragma clang diagnostic pop
