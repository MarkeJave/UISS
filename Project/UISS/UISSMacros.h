//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#ifndef UISS_UISSMacros_h
#define UISS_UISSMacros_h

#ifndef UISS_DEBUG
#if DEBUG
#define UISS_DEBUG 1
#endif
#endif

#ifndef UISS_LOG_ENABLED
#if UISS_DEBUG
#define UISS_LOG_ENABLED 1
#endif
#endif

#if UISS_LOG_ENABLED
#define UISS_LOG(s, ...) NSLog(@"UISS - %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define UISS_LOG(...)
#endif

#define UISSErrorsAdd(errorsPtr, error)  if (*errorsPtr) { if (error) { [*errorsPtr arrayByAddingObject:error]; }} else { *errorsPtr = @[error]; }
#define UISSErrorsAdds(errorsPtr, errors)  if (*errorsPtr) { if (errors) { [*errorsPtr arrayByAddingObjectsFromArray:errors]; }} else { *errorsPtr = [errors copy]; }

#endif
