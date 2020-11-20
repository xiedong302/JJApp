//
//  JJTAFFMDBHelper.m
//  JJTAF
//
//  Created by xiedong on 2020/11/18.
//

#import "JJTAFFMDBHelper.h"

//MARK: - JJTAFFMDBThread

#define MAX_THREAD_POOL_SIZE (3)

@interface JJTAFFMDBThread : NSObject

@property (nonatomic, strong, readonly) NSThread *thread;
@property (nonatomic, assign, readonly) BOOL standalone;
@property (nonatomic, assign) NSInteger referenceCount;

@end

@implementation JJTAFFMDBThread {
    //volatile 保证多个线程可以访问同一个内存空间
    volatile BOOL _cancelled;
}

- (instancetype)initWithThread:(NSThread *)thread standalone:(BOOL)standalone {
    if (self = [super init]) {
        _thread = thread;
        _standalone = standalone;
        _referenceCount = 1;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"[JJTAFFMDBThread] Dealloc: %@",self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@[%@,%@,%@]",_thread.name,@(_referenceCount),@(_standalone),@(_cancelled)];
}

//MARK: - Public
- (void)dispatchAsync:(dispatch_block_t)block {
    if (!_cancelled && _referenceCount > 0) {
        [self performSelector:@selector(runBlock:)
                     onThread:_thread
                   withObject:block
                waitUntilDone:NO
                        modes:[self modes]];
    }
}

- (void)dispatchSync:(dispatch_block_t)block {
    if (!_cancelled && _referenceCount > 0) {
        [self performSelector:@selector(runBlock:)
                     onThread:_thread
                   withObject:block
                waitUntilDone:YES
                        modes:[self modes]];
    }
}

- (void)cancel {
    _cancelled = YES;
    
    [self performSelector:@selector(runBlock:)
                 onThread:_thread
               withObject:^{
                    NSLog(@"[JJTAFFMDBThreadPool] Cancel:%@",self);
                    [NSThread.currentThread cancel];
                }
            waitUntilDone:NO
                    modes:[self modes]];
}

//MARK: - Private
- (NSArray *)modes {
    static NSArray *modes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modes = @[NSDefaultRunLoopMode];
    });
    return modes;
}

- (void)runBlock:(dispatch_block_t)block {
    if (block) {
        block();
    }
}

@end

//MARK: - JJTAFFMDBThreadPool

@interface JJTAFFMDBThreadPool : NSObject

@end

@implementation JJTAFFMDBThreadPool {
    int _threadIndex;
    NSMutableArray *_threads;
    dispatch_semaphore_t _lock;
}

+ (instancetype)instance {
    static JJTAFFMDBThreadPool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJTAFFMDBThreadPool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _threadIndex = 0;
        _threads = [NSMutableArray arrayWithCapacity:MAX_THREAD_POOL_SIZE];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (JJTAFFMDBThread *)obtain {
    return [self obtain:NO];
}

- (JJTAFFMDBThread *)obtain:(BOOL)standalone {
    JJTAFFMDBThread *thread = nil;
    
    // 选取策略
    // 1. 线程数<MAX_THREAD_POOL_SIZE,创建新线程
    // 2. 线程数>=MAX_THREAD_POOL_SIZE, 选取referenceCount最少的
    // 3. standalone=YES， 独占模式，这个线程的referenceCount只能为1，所以总会创建新线程
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if (_threads.count >= MAX_THREAD_POOL_SIZE) {
        for (JJTAFFMDBThread *temp in _threads) {
            if (temp.standalone) {
                continue;
            }
            
            if (!thread || thread.referenceCount > temp.referenceCount) {
                thread = temp;
            }
        }
    }
    
    if (thread) {
        thread.referenceCount += 1;
    }
    
    if (!thread) {
        NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(threadStart:) object:nil];
        t.name = [NSString stringWithFormat:@"JJTAFFMDBThread[%d]",_threadIndex++];
        if (@available(iOS 8.0, *)) {
            t.qualityOfService = NSQualityOfServiceBackground;
        } else {
            t.threadPriority = 0.3;
        }
        [t start];
        
        thread = [[JJTAFFMDBThread alloc] initWithThread:t standalone:standalone];
        
        NSLog(@"[JJTAFFMDBThreadPool] Create thread: %@",thread);
        
        [_threads addObject:thread];
        
        NSLog(@"[JJTAFFMDBThreadPool] Obtain pool count: %@",@(_threads.count));
    }
    
    dispatch_semaphore_signal(_lock);
    
    NSLog(@"[JJTAFFMDBThreadPool] Obtain thread: %@", thread);
    
    return thread;
}

- (void)release:(JJTAFFMDBThread *)thread {
    NSLog(@"[JJTAFFMDBThreadPool] Release thread: %@",thread);
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if (thread.referenceCount - 1 <= 0) {
        [thread cancel];
        
        [_threads removeObject:thread];
        
        NSLog(@"[JJTAFFMDBThreadPool] Release pool count: %@",@(_threads.count));
    }
    
    thread.referenceCount -= 1;
    
    dispatch_semaphore_signal(_lock);
}

- (void)threadStart:(id)__unused object {
    @autoreleasepool {
        NSThread *thread = NSThread.currentThread;
        NSRunLoop *runLoop = NSRunLoop.currentRunLoop;
        
        NSLog(@"[JJTAFFMDBThreadPool] Thread start: %@",thread.name);
        
        NSPort *stubPort = [NSMachPort port];
        
        [runLoop addPort:stubPort forMode:NSDefaultRunLoopMode];
        
        while (!thread.isCancelled) {
            NSLog(@"[JJTAFFMDBThreadPool] Thread run: %@",thread.name);
            
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
        }
        
        [runLoop removePort:stubPort forMode:NSDefaultRunLoopMode];
        
        NSLog(@"[JJTAFFMDBThreadPool] Thread quit: %@",thread.name);
    }
}

@end

//MARK: - JJTAFFMDBHelper

@interface JJTAFFMDBHelper ()

@property (nonatomic, copy) NSString *dbName;
@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, assign) int newVersion;

@property (nonatomic, strong) FMDatabase *myDatabase;

@end

@implementation JJTAFFMDBHelper {
    JJTAFFMDBThread *_myThread;
}

//MARK: - Init
- (instancetype)initWithName:(NSString *)dbName version:(int)version {
    return [self initWithName:dbName version:version standalone:NO];
}

- (instancetype)initWithName:(NSString *)dbName version:(int)version standalone:(BOOL)standalone {
    self = [super init];
    
    if (self) {
        if (!dbName || dbName.length <= 0) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"dbName is Empty" userInfo:nil];
        }
        
        if (version <= 0) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"version is <= 0" userInfo:nil];
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        BOOL isDir = NO;
        BOOL isExits = NO;
        
        NSString *dbDir = [docDir stringByAppendingPathComponent:@"databases"];
        
        isExits = [fileManager fileExistsAtPath:dbDir isDirectory:&isDir];
        
        if (!isExits || !isDir) {
            [fileManager createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *dbPath = [dbDir stringByAppendingPathComponent:dbName];
        
        
        _dbName = [dbName copy];
        _dbPath = [dbPath copy];
        _newVersion = version;
        
        _myThread = [[JJTAFFMDBThreadPool instance] obtain:standalone];
    }
    return self;
}

- (void)dealloc {
    [self close];
    
    [[JJTAFFMDBThreadPool instance] release:_myThread];
}

//MARK: - Public
- (int)databaseOnAdjustVersion:(FMDatabase *)db {
    // Implement in child
    return 0;
}

- (BOOL)databaseOnCreate:(FMDatabase *)db {
    // Implement in child
    return YES;
}

- (BOOL)databaseOnUpgrade:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
    // Implement in child
    return YES;
}

- (BOOL)databaseOnDowngrade:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
    // Implement in child
    return YES;
}

- (void)databaseOnOpenError:(NSString *)dbPath {
    // Implement in child
}

- (void)inDatabase:(__attribute__((noescape)) void (^)(FMDatabase * _Nonnull))block {
    dispatch_block_t myBlock = ^{
        FMDatabase *db = [self openDatabase];
        
        if (db) {
            block(db);
            
            if ([db hasOpenResultSets]) {
                NSException *e = [NSException exceptionWithName:@"JJTAFFMDBHelperException" reason:@"ResultSet not close" userInfo:nil];
                
                @throw e;
            }
        }
    };
    
    if (NSThread.currentThread == _myThread.thread) {
        myBlock();
    } else {
        [_myThread dispatchSync:myBlock];
    }
}

- (void)inTransaction:(__attribute__((noescape)) void (^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    dispatch_block_t myBlock = ^{
        FMDatabase *db = [self openDatabase];
        
        if (db) {
            if ([db beginTransaction]) {
                BOOL shouldRollback = NO;
                
                block(db, &shouldRollback);
                
                if ([db hasOpenResultSets]) {
                    NSException *e = [NSException exceptionWithName:@"JJTAFFMDBHelperException" reason:@"ResultSet not close" userInfo:nil];
                    
                    @throw e;
                }
                
                if (shouldRollback) {
                    [db rollback];
                } else {
                    [db commit];
                }
            }
        }
    };
    
    if (NSThread.currentThread == _myThread.thread) {
        myBlock();
    } else {
        [_myThread dispatchSync:myBlock];
    }
}

- (void)close {
    dispatch_block_t myBlock = ^{
        FMDatabase *db = self.myDatabase;
        self.myDatabase = nil;
        
        if (db) {
            [db close];
        }
    };
    
    if (NSThread.currentThread == _myThread.thread) {
        myBlock();
    } else {
        [_myThread dispatchSync:myBlock];
    }
}

- (BOOL)setVersion:(int)version {
    __block BOOL result = NO;
    
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        /**
         PRAGMA schema_version;
         PRAGMA schema_version = integer ;
         PRAGMA user_version;
         PRAGMA user_version = integer ;
         schema和user version是在数据库文件头40，60字节处的32位整数（大端表示）。
         schema版本由sqlite内部维护，当schema改变时，就会增加该值。显式改变该值非常危险。
         user版本可以被应用程序使用。
         */
        result = [db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d;",version]];
    }];
    
    return result;
}
//MARK: - Private
- (FMDatabase *)openDatabase {
    if (!self.myDatabase) {
        NSString *dbPath = self.dbPath;
        
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
        
        // 测试数据库是否损坏
        BOOL success = [db open] && [db goodConnection];
        if (success) {
            // 检查版本
            int oldVersion = 0;
            int newVersion = self.newVersion;
            
            FMResultSet *set = [db executeQuery:@"PRAGMA user_version;"];
            
            if (set) {
                if ([set next]) {
                    oldVersion = [set intForColumnIndex:0];
                }
                
                [set close];
            }
            
            NSLog(@"[JJTAFFMDBHelper] Open database %@ with version (%d,%d)",dbPath, oldVersion, newVersion);
            
            // 一段兼容逻辑
            // 如果数据库有数据，但是版本号为0，给一个机会让外部重置一下版本
            if (oldVersion == 0) {
                BOOL needAdjust = NO;
                
                FMResultSet *set = [db executeQuery:@"SELECT COUNT(*) FROM sqlite_master WHERE type = 'table';"];
                
                if (set) {
                    if ([set next]) {
                        needAdjust = [set intForColumnIndex:0] > 0;
                    }
                    
                    [set close];
                }
                
                if (needAdjust) {
                    int adjustVersion = [self databaseOnAdjustVersion:db];
                    
                    if (adjustVersion > 0) {
                        if ([db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d;",adjustVersion]]) {
                            oldVersion = adjustVersion;
                        } else {
                            NSLog(@"[JJTAFFMDBHelper] Adjust database %@ failed", dbPath);
                            
                            [db close];
                            
                            return nil;
                        }
                    }
                }
            }
            
            if (oldVersion != newVersion) {
                if ([db beginTransaction]) {
                    BOOL result = YES;
                    
                    if (oldVersion == 0) {
                        result = [self databaseOnCreate:db];
                    } else if (oldVersion < newVersion) {
                        result = [self databaseOnUpgrade:db oldVersion:oldVersion newVersion:newVersion];
                    } else {
                        result = [self databaseOnDowngrade:db oldVersion:oldVersion newVersion:newVersion];
                    }
                    
                    if (result) {
                        result = [db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d;",newVersion]];
                    }
                    
                    if (result) {
                        [db commit];
                    } else {
                        NSLog(@"[JJTAFFMDBHelper] Open database %@ failed",dbPath);
                        
                        // 这里失败了不删库，因为数据库本身是好的，只是这次请求跪了
                        [db rollback];
                        [db close];
                        
                        return nil;
                    }
                }
            }
            self.myDatabase = db;
        } else {
            NSLog(@"[JJTAFFMDBHelper] Database %@ corrupted", dbPath);
            
            [db close];
            
            // sudo rm -rf, 跑路
            [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
            
            [self databaseOnOpenError:dbPath];
            
            return nil;
        }
    }
    
    return self.myDatabase;
}

@end
