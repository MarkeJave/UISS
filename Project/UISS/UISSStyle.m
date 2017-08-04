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

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong) NSArray *propertySettersPad;
@property (nonatomic, strong) NSArray *propertySettersPhone;

@property (nonatomic, strong) NSMutableArray *errors;

@end

@implementation UISSStyle

+ (instancetype)styleWithURL:(NSURL *)URL;{
    return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL;{
    if (self = [super init]) {
        self.errors = [NSMutableArray array];
        self.URL = URL;
    }
    return self;
}

+ (instancetype)styleWithData:(NSData *)data;{
    return [[self alloc] initWithData:data];
}

- (instancetype)initWithData:(NSData *)data;{
    if (self = [super init]) {
        self.errors = [NSMutableArray array];
        self.data = data;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setURL:(NSURL *)URL {
    if (_URL != URL) {
        _URL = URL;

        self.data = nil;
    }
}

- (void)setData:(NSData *)data {
    if (_data != data) {
        _data = data;

        self.dictionary = nil;
        [self.errors removeAllObjects];
    }
}

- (void)setDictionary:(NSDictionary *)dictionary {
    if (_dictionary != dictionary) {
        _dictionary = dictionary;

        self.propertySettersPad = nil;
        self.propertySettersPhone = nil;
    }
}

- (NSArray *)propertySettersForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom {
    switch (userInterfaceIdiom) {
        case UIUserInterfaceIdiomPad:
            return self.propertySettersPad;
        default: // UIUserInterfaceIdiomPhone
            return self.propertySettersPhone;
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

- (BOOL)downloadData {
    [self postNotificationName:UISSStyleWillDownloadNotification];

    BOOL downloadedNewStyle = NO;

    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:self.URL
                                         options:(NSDataReadingOptions) 0
                                           error:&error];

    if (error) {
        [self.errors addObject:error];
    } else {
        if (data && [data isEqualToData:self.data] == NO) {
            self.data = data;
            downloadedNewStyle = YES;
        }
    }

    [self postNotificationName:UISSStyleDidDownloadNotification];

    return downloadedNewStyle;
}

- (BOOL)parseData {
    if (self.data == nil) {
        if ([self downloadData] == NO) {
            return NO;
        }
    }

    [self postNotificationName:UISSStyleWillParseDataNotification];

    BOOL dataParsed = NO;

    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];

    if (error) {
        [self.errors addObject:error];
    } else {
        self.dictionary = dictionary;
        dataParsed = YES;
    }

    [self postNotificationName:UISSStyleDidParseDataNotification];

    return dataParsed;
}

- (BOOL)parseDictionaryForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom withConfig:(UISSConfig *)config {
    NSArray *propertySetters = [self propertySettersForUserInterfaceIdiom:userInterfaceIdiom];

    if (propertySetters) {
        return NO;
    }

    if (self.dictionary == nil) {
        if ([self parseData] == NO) {
            return NO;
        }
    }

    [self postNotificationName:UISSStyleWillParseDictionaryNotification];

    BOOL dictionaryParsed = NO;

    UISSParser *parser = [[UISSParser alloc] init];
    parser.userInterfaceIdiom = userInterfaceIdiom;
    parser.config = config;

    propertySetters = [parser parseDictionary:self.dictionary errors:self.errors];

    if (propertySetters) {
        [self setPropertySetters:propertySetters forUserInterfaceIdiom:userInterfaceIdiom];
        dictionaryParsed = YES;
    }

    [self postNotificationName:UISSStyleDidParseDictionaryNotification];

    return dictionaryParsed;
}

#pragma mark - Notifications on Main Thread

- (void)postNotificationName:(NSString *)name {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
    });
}

@end
