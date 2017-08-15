//
//  NSError+UISS.m
//  UISS
//
//  Created by 徐 林峰 on 2017/8/7.
//  Copyright © 2017年 57things. All rights reserved.
//

#import "NSError+UISS.h"

@implementation NSError (UISS)

+ (NSError *)errorWithUnderlyingError:(NSError *)error;{
    NSParameterAssert(error);
    return [NSError errorWithDomain:[error domain] code:[error code] userInfo:@{NSUnderlyingErrorKey: error}];
}

- (NSError *)errorByAddingUnderlyingError:(NSError *)error;{
    NSParameterAssert(error);
    return [NSError errorWithDomain:[self domain] code:[self code] userInfo:@{NSLocalizedFailureReasonErrorKey: [self userInfo] ?: @{}, NSUnderlyingErrorKey: error}];
}

@end
