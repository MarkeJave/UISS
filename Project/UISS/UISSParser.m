//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISSParser.h"

#import "UISSConfig.h"
#import "UISSDictionaryPreprocessor.h"
#import "UISSPropertySetter.h"
#import "UISSError.h"
#import "UISSParserContext.h"

@interface UISSParser ()

@property (nonatomic, strong) UISSConfig *config;
@property (nonatomic, assign) UIUserInterfaceIdiom userInterfaceIdiom;
@property (nonatomic, strong) NSString *groupPrefix;

@end

@implementation UISSParser

+ (instancetype)parserWithConfig:(UISSConfig *)config;{
    return [[self alloc] initWithConfig:config];
}

+ (instancetype)parserWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;{
    return [[self alloc] initWithConfig:config userInterfaceIdiom:userInterfaceIdiom];
}

+ (instancetype)parserWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom groupPrefix:(NSString *)groupPrefix;{
    return [[self alloc] initWithConfig:config userInterfaceIdiom:userInterfaceIdiom groupPrefix:groupPrefix];
}

- (instancetype)initWithConfig:(UISSConfig *)config{
    return [self initWithConfig:config userInterfaceIdiom:[[UIDevice currentDevice] userInterfaceIdiom]];
}

- (instancetype)initWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom;{
    return [self initWithConfig:config userInterfaceIdiom:userInterfaceIdiom groupPrefix:UISS_PARSER_DEFAULT_GROUP_PREFIX];
}

- (instancetype)initWithConfig:(UISSConfig *)config userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom groupPrefix:(NSString *)groupPrefix;{
    NSParameterAssert(config);
    self = [super init];
    if (self) {
        self.config = config;
        self.userInterfaceIdiom = userInterfaceIdiom;
        self.groupPrefix = groupPrefix;
    }

    return self;
}

- (id)propertySetterForKey:(NSString *)key withValue:(id)value context:(UISSParserContext *)context {
    UISSPropertySetter *propertySetter = [[UISSPropertySetter alloc] init];

    propertySetter.appearanceClass = context.appearanceStack.lastObject;
    propertySetter.containment = [context.appearanceStack subarrayWithRange:NSMakeRange(0, context.appearanceStack.count - 1)];

    NSArray *keyParts = [key componentsSeparatedByString:@":"];

    NSString *name = [keyParts objectAtIndex:0];

    UISSProperty *property = [[UISSProperty alloc] init];
    property.name = name;
    property.value = value;

    propertySetter.property = property;
    propertySetter.group = context.groupsStack.lastObject;

    NSMutableArray *axisParameters = [NSMutableArray array];

    for (NSUInteger idx = 1; idx < keyParts.count; idx++) {
        UISSAxisParameter *axisParameter = [[UISSAxisParameter alloc] init];
        axisParameter.value = [keyParts objectAtIndex:idx];
        [axisParameters addObject:axisParameter];
    }

    propertySetter.axisParameters = axisParameters;

    return propertySetter;
}

- (void)processClass:(Class)class object:(id)object context:(UISSParserContext *)context; {
    if ([class conformsToProtocol:@protocol(UIAppearance)] || [class conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        Class currentContainer = context.appearanceStack.lastObject;

        if (currentContainer == nil || [currentContainer conformsToProtocol:@protocol(UIAppearanceContainer)]) {
            UISS_LOG(@"component: %@", NSStringFromClass(class));

            if ([object isKindOfClass:[NSDictionary class]]) {
                [context.appearanceStack addObject:class];
                [self parseDictionary:object context:context];
                [context.appearanceStack removeLastObject];
            } else {
                [context addErrorWithCode:UISSInvalidAppearanceDictionaryError
                                   object:[NSDictionary dictionaryWithObject:object forKey:NSStringFromClass(class)]
                                      key:UISSInvalidAppearanceDictionaryErrorKey];
            }
        } else {
            [context addErrorWithCode:UISSInvalidAppearanceContainerClassError
                               object:NSStringFromClass(currentContainer)
                                  key:UISSInvalidClassNameErrorKey];
        }
    } else {
        [context addErrorWithCode:UISSInvalidAppearanceClassError
                           object:NSStringFromClass(class)
                              key:UISSInvalidClassNameErrorKey];
    }
}

- (void)processPropertyWithKey:(NSString *)key value:(id)value context:(UISSParserContext *)context; {
    if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[key characterAtIndex:0]]) {
        // first letter capitalized so I guess this supposed to be a class
        [context addErrorWithCode:UISSUnknownClassError object:key key:UISSInvalidClassNameErrorKey];
    } else {
        Class currentClass = context.appearanceStack.lastObject;

        if (currentClass == nil) {
            [context addErrorWithCode:UISSUnknownClassError object:key key:UISSInvalidClassNameErrorKey];
        } else if ([context.appearanceStack.lastObject conformsToProtocol:@protocol(UIAppearance)] == NO) {
            [context addErrorWithCode:UISSInvalidAppearanceClassError object:NSStringFromClass(currentClass)
                                  key:UISSInvalidClassNameErrorKey];
        } else {
            UISS_LOG(@"property: %@", key);
            [context.propertySetters addObject:[self propertySetterForKey:key withValue:value context:context]];
        }
    }
}

- (void)processKey:(NSString *)key object:(id)object context:(UISSParserContext *)context; {
    if ([key hasPrefix:self.groupPrefix]) {
        [context.groupsStack addObject:[key substringFromIndex:[self.groupPrefix length]]];
        [self parseDictionary:object context:context];
        [context.groupsStack removeLastObject];
    } else {
        Class class = NSClassFromString(key);

        if (class) {
            [self processClass:class object:object context:context];
        } else {
            [self processPropertyWithKey:key value:object context:context];
        }
    }
}

- (void)parseDictionary:(NSDictionary *)dictionary context:(UISSParserContext *)context; {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self processKey:key object:obj context:context];
    }];
}

#pragma mark - Public

- (NSArray *)parseDictionary:(NSDictionary *)dictionary errors:(NSArray **)errorsPtr; {
    UISSParserContext *context = [[UISSParserContext alloc] init];

    for (id <UISSDictionaryPreprocessor> preprocessor in [[self config] preprocessors]) {
        dictionary = [preprocessor preprocess:dictionary userInterfaceIdiom:[self userInterfaceIdiom]];
    }

    [self parseDictionary:dictionary context:context];
    UISSErrorsAdds(errorsPtr, [context errors]);

    return [context propertySetters];
}

- (NSArray *)parseDictionary:(NSDictionary *)dictionary; {
    return [self parseDictionary:dictionary errors:nil];
}

@end
