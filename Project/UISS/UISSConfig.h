//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UISSArgumentValueConverter, UISSDictionaryPreprocessor;

@interface UISSConfig : NSObject

@property(nonatomic, strong, readonly) NSArray<UISSArgumentValueConverter> *propertyValueConverters;
@property(nonatomic, strong, readonly) NSArray<UISSArgumentValueConverter> *axisParameterValueConverters;
@property(nonatomic, strong, readonly) NSArray<UISSDictionaryPreprocessor> *preprocessors;

+ (UISSConfig *)defaultConfig;

+ (instancetype)configWithPropertyValueConverters:(NSArray<UISSArgumentValueConverter> *)propertyValueConverters axisParameterValueConverters:(NSArray<UISSArgumentValueConverter> *)axisParameterValueConverters preprocessors:(NSArray *)preprocessors;
- (instancetype)initWithPropertyValueConverters:(NSArray<UISSArgumentValueConverter> *)propertyValueConverters axisParameterValueConverters:(NSArray<UISSArgumentValueConverter> *)axisParameterValueConverters preprocessors:(NSArray<UISSDictionaryPreprocessor> *)preprocessors;

#pragma mark - Default

+ (NSArray<UISSArgumentValueConverter> *)defaultPropertyValueConverters;
+ (NSArray<UISSArgumentValueConverter> *)defaultAxisParameterValueConverters;
+ (NSArray<UISSDictionaryPreprocessor> *)defaultPreprocessors;

@end
