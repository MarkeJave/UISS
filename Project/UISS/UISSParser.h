//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UISS_PARSER_DEFAULT_GROUP_PREFIX @"@"

@class UISSConfig;

@interface UISSParser : NSObject

@property (nonatomic, strong, readonly) UISSConfig *config;
@property (nonatomic, assign, readonly) UIUserInterfaceIdiom userInterfaceIdiom;
@property (nonatomic, strong, readonly) NSString *groupPrefix;

+ (instancetype)parserWithConfig:(UISSConfig *)config;
+ (instancetype)parserWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;
+ (instancetype)parserWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom groupPrefix:(NSString *)groupPrefix;

- (instancetype)initWithConfig:(UISSConfig *)config;
- (instancetype)initWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;
- (instancetype)initWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom groupPrefix:(NSString *)groupPrefix;

// returns array of PropertySetters
- (NSArray *)parseDictionary:(NSDictionary *)dictionary;
- (NSArray *)parseDictionary:(NSDictionary *)dictionary errors:(NSArray **)errors;

@end
