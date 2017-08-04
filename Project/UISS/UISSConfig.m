//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISSConfig.h"
#import "UISSColorValueConverter.h"
#import "UISSImageValueConverter.h"
#import "UISSFontValueConverter.h"
#import "UISSTextAttributesValueConverter.h"
#import "UISSSizeValueConverter.h"
#import "UISSPointValueConverter.h"
#import "UISSEdgeInsetsValueConverter.h"
#import "UISSRectValueConverter.h"
#import "UISSOffsetValueConverter.h"
#import "UISSIntegerValueConverter.h"
#import "UISSUIntegerValueConverter.h"
#import "UISSFloatValueConverter.h"
#import "UISSBarMetricsValueConverter.h"
#import "UISSControlStateValueConverter.h"
#import "UISSSegmentedControlSegmentValueConverter.h"
#import "UISSToolbarPositionValueConverter.h"
#import "UISSSearchBarIconValueConverter.h"
#import "UISSUserInterfaceIdiomPreprocessor.h"
#import "UISSVariablesPreprocessor.h"
#import "UISSDisabledKeysPreprocessor.h"
#import "UISSTextAlignmentValueConverter.h"

@interface UISSConfig ()

@property(nonatomic, strong) NSArray<UISSArgumentValueConverter> *propertyValueConverters;
@property(nonatomic, strong) NSArray<UISSArgumentValueConverter> *axisParameterValueConverters;
@property(nonatomic, strong) NSArray<UISSDictionaryPreprocessor> *preprocessors;

@end

@implementation UISSConfig

+ (UISSConfig *)defaultConfig;
{
    static UISSConfig *defaultConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultConfig = [[UISSConfig alloc] init];
    });
    
    return defaultConfig;
}

+ (instancetype)configWithPropertyValueConverters:(NSArray<UISSArgumentValueConverter> *)propertyValueConverters axisParameterValueConverters:(NSArray<UISSArgumentValueConverter> *)axisParameterValueConverters preprocessors:(NSArray<UISSDictionaryPreprocessor> *)preprocessors;{
    return [[self alloc] initWithPropertyValueConverters:propertyValueConverters axisParameterValueConverters:axisParameterValueConverters preprocessors:preprocessors];
}

- (instancetype)initWithPropertyValueConverters:(NSArray<UISSArgumentValueConverter> *)propertyValueConverters axisParameterValueConverters:(NSArray<UISSArgumentValueConverter> *)axisParameterValueConverters preprocessors:(NSArray<UISSDictionaryPreprocessor> *)preprocessors;{
    if (self = [super init]) {
        self.propertyValueConverters = propertyValueConverters;
        self.axisParameterValueConverters = axisParameterValueConverters;
        self.preprocessors = preprocessors;
    }
    return self;
}


- (id)init {
    if (self = [super init]) {
        self.propertyValueConverters = [[self class] defaultPropertyValueConverters];
        self.axisParameterValueConverters = [[self class] defaultAxisParameterValueConverters];
        self.preprocessors = [[self class] defaultPreprocessors];
    }
    
    return self;
}


+ (NSArray<UISSArgumentValueConverter> *)defaultPropertyValueConverters {
    return [NSArray<UISSArgumentValueConverter> arrayWithObjects:
            [[UISSColorValueConverter alloc] init],
            [[UISSImageValueConverter alloc] init],
            [[UISSFontValueConverter alloc] init],
            [[UISSTextAttributesValueConverter alloc] init],
            
            [[UISSSizeValueConverter alloc] init],
            [[UISSPointValueConverter alloc] init],
            [[UISSEdgeInsetsValueConverter alloc] init],
            [[UISSRectValueConverter alloc] init],
            [[UISSOffsetValueConverter alloc] init],
            
            [[UISSTextAlignmentValueConverter alloc] init],
            
            [[UISSIntegerValueConverter alloc] init],
            [[UISSUIntegerValueConverter alloc] init],
            [[UISSFloatValueConverter alloc] init],
            nil];
}

+ (NSArray<UISSArgumentValueConverter> *)defaultAxisParameterValueConverters {
    return [NSArray<UISSArgumentValueConverter> arrayWithObjects:
            [[UISSBarMetricsValueConverter alloc] init],
            [[UISSControlStateValueConverter alloc] init],
            [[UISSSegmentedControlSegmentValueConverter alloc] init],
            [[UISSToolbarPositionValueConverter alloc] init],
            [[UISSSearchBarIconValueConverter alloc] init],
            
            [[UISSIntegerValueConverter alloc] init],
            [[UISSUIntegerValueConverter alloc] init],
            nil];
}

+ (NSArray<UISSDictionaryPreprocessor> *)defaultPreprocessors {
    return [NSArray<UISSDictionaryPreprocessor> arrayWithObjects:
            [[UISSDisabledKeysPreprocessor alloc] init],
            [[UISSUserInterfaceIdiomPreprocessor alloc] init],
            [[UISSVariablesPreprocessor alloc] init],
            nil];
}

@end
