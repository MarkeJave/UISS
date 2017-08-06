//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UISSParser.h"

extern NSString *const UISSStyleWillDownloadNotification;
extern NSString *const UISSStyleDidDownloadNotification;

extern NSString *const UISSStyleWillParseDataNotification;
extern NSString *const UISSStyleDidParseDataNotification;

extern NSString *const UISSStyleWillParseDictionaryNotification;
extern NSString *const UISSStyleDidParseDictionaryNotification;

@interface UISSStyle : NSObject

@property (nonatomic, copy, readonly) NSURL *URL;

@property (nonatomic, copy, readonly) NSData *data;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)styleWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL;

+ (instancetype)styleWithData:(NSData *)data;
- (instancetype)initWithData:(NSData *)data;

- (NSArray *)parseForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom withConfig:(UISSConfig *)config errors:(NSArray **)errorsPtr;

- (NSArray *)propertySettersForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;

@end
