//
//  NSError+UISS.h
//  UISS
//
//  Created by 徐 林峰 on 2017/8/7.
//  Copyright © 2017年 57things. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSErrorAddingUnderlyingError(errorPtr, error)   (errorPtr ? (*errorPtr ? error : [*errorPtr errorByAddingUnderlyingError:error]) : (void))

@interface NSError (UISS)

+ (NSError *)errorWithUnderlyingError:(NSError *)error;

- (NSError *)errorByAddingUnderlyingError:(NSError *)error;

@end
