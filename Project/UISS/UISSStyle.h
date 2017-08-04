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

@property (nonatomic, strong, readonly) NSURL *URL;

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) NSDictionary *dictionary;

@property (nonatomic, strong, readonly) NSArray *propertySettersPad;
@property (nonatomic, strong, readonly) NSArray *propertySettersPhone;

@property (nonatomic, strong, readonly) NSMutableArray *errors;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

+ (instancetype)styleWithURL:(NSURL *)URL;
- (instancetype)initWithURL:(NSURL *)URL;

+ (instancetype)styleWithData:(NSData *)data;
- (instancetype)initWithData:(NSData *)data;

- (BOOL)downloadData;
- (BOOL)parseData;
- (BOOL)parseDictionaryForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom withConfig:(UISSConfig *)config;

- (NSArray *)propertySettersForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;

@end
