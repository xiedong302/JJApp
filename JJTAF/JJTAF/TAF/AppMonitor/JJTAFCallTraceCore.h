//
//  JJTAFCallTraceCore.h
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//  函数调用追踪 在cpu arm64可用

#ifndef JJTAFCallTraceCore_h
#define JJTAFCallTraceCore_h

#include <stdio.h>
#include <objc/objc.h>

typedef struct {
    __unsafe_unretained Class cls;
    SEL sel;
    uint64_t time; // us (1/1000 ms)
    int depth;
} JJTAFCallRecord;


extern void JJTAF_callTraceStart(void);
extern void JJTAF_callTraceStop(void);
extern void JJTAF_callTraceConfigMinTime(uint64_t us); // default 1000
extern void JJTAF_callTraceConfigMaxDepth(int depth); //default 3
extern JJTAFCallRecord * JJTAF_getCallTraceRecords(int *num);

extern void JJTAF_clearCallTraceRecords(void);

#endif /* JJTAFCallTraceCore_h */
