//
//  JJBaseMacro.h
//  JJBase
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#ifndef JJBaseMacro_h
#define JJBaseMacro_h

#define WeakSelf __weak typeof(self) weakSelf = self;

#define IsValidateString(str) (str && [str isKindOfClass:[NSString class]] && [str length] > 0)

#define IsValidateArray(array) (array && [array isKindOfClass:[NSArray class]] && [array count] > 0)

#define IsValidateDict(dict) (dict && [dict isKindOfClass:[NSDictionary class]] && [dict count] > 0)

#define IsValidateNumber(num) (num && [num isKindOfClass:[NSNumber class]])

#endif /* JJBaseMacro_h */
