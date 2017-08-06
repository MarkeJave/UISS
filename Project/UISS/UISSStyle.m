//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISSStyle.h"

NSString *const UISSStyleWillDownloadNotification = @"UISSStyleWillDownloadNotification";
NSString *const UISSStyleDidDownloadNotification = @"UISSStyleDidDownloadNotification";

NSString *const UISSStyleWillParseDataNotification = @"UISSStyleWillParseDataNotification";
NSString *const UISSStyleDidParseDataNotification = @"UISSStyleDidParseDataNotification";

NSString *const UISSStyleWillParseDictionaryNotification = @"UISSStyleWillParseDictionaryNotification";
NSString *const UISSStyleDidParseDictionaryNotification = @"UISSStyleDidParseDictionaryNotification";

@interface UISSStyle ()

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSData *data;

@property (nonatomic, assign) BOOL downloadCompleted;
@property (nonatomic, assign) BOOL parseCompleted;

@property (nonatomic, copy) NSDictionary *dictionary;

@property (nonatomic, copy) NSArray *propertySettersPad;
@property (nonatomic, copy) NSArray *propertySettersPhone;

@end

@implementation UISSStyle

+ (instancetype)styleWithURL:(NSURL *)URL;{
    return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL;{
    NSParameterAssert(URL);
    
    if (self = [super init]) {
        self.URL = URL;
    }
    return self;
}

+ (instancetype)styleWithData:(NSData *)data;{
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data;{
    NSParameterAssert(data);
    
    if (self = [super init]) {
        self.data = data;
    }
    return self;
}

- (NSArray *)propertySettersForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom {
    switch (userInterfaceIdiom) {
        case UIUserInterfaceIdiomPad:
            return [self propertySettersPad];
        default: // UIUserInterfaceIdiomPhone
            return [self propertySettersPhone];
    }
}

- (void)setPropertySetters:(NSArray *)propertySetters forUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom {
    switch (userInterfaceIdiom) {
        case UIUserInterfaceIdiomPad:
            self.propertySettersPad = propertySetters;
            break;
        default: // UIUserInterfaceIdiomPhone
            self.propertySettersPhone = propertySetters;
            break;
    }
}

#pragma mark - Parsing

- (BOOL)downloadDataWithError:(NSError **)error {
    if ([self downloadCompleted] || (![self URL] && [self data])) return YES;
    
    [self postNotificationName:UISSStyleWillDownloadNotification];

    NSData *data = [NSData dataWithContentsOfURL:[self URL]
                                         options:(NSDataReadingOptions) 0
                                           error:error];

    if (!*error && data) {
        self.data = data;
        self.downloadCompleted = YES;
    }

    [self postNotificationName:UISSStyleDidDownloadNotification];

    return [self downloadCompleted];
}

- (BOOL)parseDataWithError:(NSError **)error {
    if (![self data]) return NO;
    if ([self parseCompleted]) return YES;

    [self postNotificationName:UISSStyleWillParseDataNotification];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[self data]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:error];

    if (!*error) {
        self.dictionary = dictionary;
        self.parseCompleted = YES;
    }

    [self postNotificationName:UISSStyleDidParseDataNotification];

    return [self parseCompleted];
}

- (NSArray *)parseForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom withConfig:(UISSConfig *)config errors:(NSArray **)errors; {
    NSArray *propertySetters = [self propertySettersForUserInterfaceIdiom:userInterfaceIdiom];
    if (propertySetters) return propertySetters;
    
    if (![self dictionary]) {
        NSError *downloadError = nil;
        if (![self downloadDataWithError:&downloadError] && downloadError) {
            UISSErrorsAdd(errors, downloadError);
        }
        
        NSError *parseError = nil;
        if (![self parseDataWithError:&parseError] && parseError) {
            UISSErrorsAdd(errors, parseError);
        }
    }
    
    if (![self dictionary]) return nil;

    [self postNotificationName:UISSStyleWillParseDictionaryNotification];

    UISSParser *parser = [UISSParser parserWithConfig:config userInterfaceIdiom:userInterfaceIdiom];
    
    propertySetters = [parser parseDictionary:[self dictionary] errors:errors];
    if (propertySetters) {
        [self setPropertySetters:propertySetters forUserInterfaceIdiom:userInterfaceIdiom];
    }

    [self postNotificationName:UISSStyleDidParseDictionaryNotification];

    return propertySetters;
}

#pragma mark - Notifications on Main Thread

- (void)postNotificationName:(NSString *)name {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
    });
}

@end
