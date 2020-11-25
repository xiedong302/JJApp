//
//  JJTAFCallLib.h
//  JJTAF
//
//  Created by xiedong on 2020/11/24.
//

#import <Foundation/Foundation.h>
#include <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

#include <mach/task.h>
#include <mach/vm_map.h>
#include <mach/mach_init.h>
#include <mach/thread_act.h>
#include <mach/thread_info.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/sysctl.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <dispatch/dispatch.h>

NS_ASSUME_NONNULL_BEGIN

// __LP64__ __arm64__ 这样的宏定义是在编译器里面定义的。
// https://github.com/llvm-mirror/clang/blob/0e261f7c4df17c1432f9cc031ae12e3cf5a19347/lib/Frontend/InitPreprocessor.cpp

#ifdef __LP64__
typedef struct mach_header_64       machHeaderByCPU;
typedef struct segment_command_64   segmentCommandByCPU;
typedef struct section_64           sectionByCPU;
typedef struct nlist_64             nlistByCPU;
#define LC_SEGMENT_ARCH_DEPENDENT   LC_SEGMENT_64

#else
typedef struct mach_header          machHeaderByCPU;
typedef struct segment_command      segmentCommandByCPU;
typedef struct section              sectionByCPU;
typedef struct nlist                nlistByCPU;
#define LC_SEGMENT_ARCH_DEPENDENT   LC_SEGMENT

#endif

#ifdef SEG_DATA_CONST
#define SEG_DATA_CONST "__DATA_CONST"
#endif
@interface JJTAFCallLib : NSObject

@end

NS_ASSUME_NONNULL_END
