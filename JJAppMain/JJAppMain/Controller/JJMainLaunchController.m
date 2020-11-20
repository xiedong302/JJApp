//
//  JJMainLaunchController.m
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJMainLaunchController.h"
#import "JJMainLaunchGuideView.h"
#import "JJMainLaunchADView.h"

#include <stdint.h>
#include <stdio.h>
#include <sanitizer/coverage_interface.h>
#import <dlfcn.h>
#import <libkern/OSAtomic.h>

@interface JJMainLaunchController ()<JJMainLaunchADViewDelegate,JJMainLaunchGuideViewDelegate>

@property (nonatomic, strong) JJMainLaunchGuideView *guideView;

@property (nonatomic, strong) JJMainLaunchADView *adView;

@end

@implementation JJMainLaunchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *launchScreenView = [self launchScreenView];
    launchScreenView.frame = self.view.bounds;
    
    [self.view addSubview:launchScreenView];
    
    [self showLaunchView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [JJTAFMonitorTime stopMonitoringTimer];
}

- (void)showLaunchView {
    if ([JJMainLaunchGuideView needShowGuide]) {
        self.guideView = [[JJMainLaunchGuideView alloc] init];
        self.guideView.frame = self.view.frame;
        self.guideView.delegate = self;
        
        [self.view addSubview:self.guideView];
    } else {
        self.adView = [[JJMainLaunchADView alloc] init];
        self.adView.frame = self.view.frame;
        self.adView.delegate = self;
        
        [self.view addSubview:self.adView];
    }
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    
    // 启动屏如果设置为YES， 两个问题：
    // 1. statusBar从LaunchScreen去换过来的时候会闪一下
    // 2. 后续的页面，主要是首页，会跳动一下
    return NO;;
}

//MARK: - JJMainLaunchADViewDelegate
- (void)launchADView:(JJMainLaunchADView *)view openURL:(NSString *)url {
    [self openURL:url];
}

//MARK: - JJMainLaunchGuideViewDelegate
- (void)launchGuideView:(JJMainLaunchGuideView *)view openURL:(NSString *)url {
    [self openURL:url];
}

//MARK: - private
- (UIView *)launchScreenView {
    UIStoryboard *launch = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *controller = [launch instantiateInitialViewController];
    return controller.view;
}

- (void)openURL:(NSString *)url {
    __strong id<JJMainLaunchControllerDelegate> delegate = self.delegate;
    
    if (delegate && [delegate respondsToSelector:@selector(launchController:openURL:)]) {
        [delegate launchController:self openURL:url];
    }
}

//MARK: - Clang

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSMutableArray <NSString *> *symbolNames = [NSMutableArray array];
    
    while (YES) {
        SYNode * node = OSAtomicDequeue(&symbolList, offsetof(SYNode, next));
        if (node == NULL) {
            break;;
        }
        
        Dl_info info;
        dladdr(node->pc, &info);
        NSString *name = @(info.dli_sname);
        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
        NSString *symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
        [symbolNames addObject:symbolName];
    }
    
    //取反
    NSEnumerator *emt = [symbolNames reverseObjectEnumerator];
    //去重
    NSMutableArray <NSString *> *funcs = [NSMutableArray arrayWithCapacity:symbolNames.count];
    NSString *name;
    while (name = [emt nextObject]) {
        if (![funcs containsObject:name]) {
            [funcs addObject:name];
        }
    }
    
    //去掉自己
    [funcs removeObject:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    //将数组变成字符串
    NSString *funcStr = [funcs componentsJoinedByString:@"\n"];
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:@"JJAppMain.order"];
    NSData *fileContents = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
    NSLog(@"%@",funcStr);
}

//原子队列
static OSQueueHead symbolList = OS_ATOMIC_QUEUE_INIT;
//定义符号结构体
typedef struct {
    void *pc;
    void *next;
}SYNode;

// This callback is inserted by the compiler as a module constructor
// into every DSO. 'start' and 'stop' correspond to the
// beginning and end of the section with the guards for the entire
// binary (executable or DSO). The callback will be called at least
// once per DSO and may be called multiple times with the same parameters.
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
  static uint64_t N;  // Counter for the guards.
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);
  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}

// This callback is inserted by the compiler on every edge in the
// control flow (some optimizations apply).
// Typically, the compiler will emit the code like this:
//    if(*guard)
//      __sanitizer_cov_trace_pc_guard(guard);
// But for large functions it will emit a simple call:
//    __sanitizer_cov_trace_pc_guard(guard);
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
  if (!*guard) return;  // Duplicate the guard check.
  // If you set *guard to 0 this code will not be called again for this edge.
  // Now you can get the PC and do whatever you want:
  //   store it somewhere or symbolize it and print right away.
  // The values of `*guard` are as you set them in
  // __sanitizer_cov_trace_pc_guard_init and so you can make them consecutive
  // and use them to dereference an array or a bit vector.
  void *PC = __builtin_return_address(0);
    
    SYNode *node = malloc(sizeof(SYNode));
    *node = (SYNode){PC,NULL};
    //进入
    OSAtomicEnqueue(&symbolList, node, offsetof(SYNode, next));
    
//  char PcDescr[1024];
  // This function is a part of the sanitizer run-time.
  // To use it, link with AddressSanitizer or other sanitizer.
//  __sanitizer_symbolize_pc(PC, "%p %F %L", PcDescr, sizeof(PcDescr));
//  printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
    
    //打印信息
//    Dl_info info;
//    dladdr(PC, &info);
//    printf("fnam:%s \n fbase:%p \n sname:%s \n saddr:%p \n",
//               info.dli_fname,
//               info.dli_fbase,
//               info.dli_sname,
//               info.dli_saddr);
}
@end
