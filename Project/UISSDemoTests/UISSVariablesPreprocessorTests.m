//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSVariablesPreprocessor.h"

@interface UISSVariablesPreprocessorTests : XCTestCase

@property(nonatomic, strong) UISSVariablesPreprocessor *preprocessor;

@end

@implementation UISSVariablesPreprocessorTests

- (void)testSubstitutionWithRegularValue; {
    id value = @"test";
    XCTAssertEqual([self.preprocessor substituteValue:value], value, @"");
}

- (void)testSettingVariable; {
    NSString *name = @"test";
    id value = @"value";

    [self.preprocessor setVariableValue:value forName:name];

    XCTAssertEqual(value, [self.preprocessor getValueForVariableWithName:name], @"");
}

- (void)testSubstitutionOfAddedVariable; {
    NSString *name = @"test";
    id value = @"value";

    [self.preprocessor setVariableValue:value forName:name];

    XCTAssertEqual(value, [self.preprocessor substituteValue:@"$test"], @"");
}

- (void)testNestedVariables; {
    NSString *name1 = @"v1";
    NSString *name2 = @"v2";

    id v1 = @"value 1";
    id v2 = @{@"test" : @"$v1"};

    [self.preprocessor setVariableValue:v1 forName:name1];
    [self.preprocessor setVariableValue:v2 forName:name2];

    XCTAssertEqual(v1, [self.preprocessor getValueForVariableWithName:name2][@"test"], @"");
}

- (void)testNestedUnknownVariableShouldBeResolvedAsNull; {
    NSString *name = @"v";
    id value = @"$unknown";

    [self.preprocessor setVariableValue:value forName:name];
    XCTAssertEqual([self.preprocessor getValueForVariableWithName:name], [NSNull null], @"");
}

- (void)testNestedVariableCycle; {
    NSString *name = @"v";
    id value = @"$v";

    [self.preprocessor setVariableValue:value forName:name];
    XCTAssertEqual([self.preprocessor getValueForVariableWithName:name], [NSNull null], @"");
}

- (void)testAddingVariablesFromDictionary; {
    NSDictionary *dictionary = @{@"v1" : @"value1"};

    [self.preprocessor setVariablesFromDictionary:dictionary];
    XCTAssertEqual([self.preprocessor getValueForVariableWithName:@"v1"], @"value1", @"");
}

- (void)testAddingVariablesFromDictionaryWithNestedVariables; {
    NSDictionary *dictionary = @{@"v1" : @"value1",
            @"v2" : @"$v1"};

    [self.preprocessor setVariablesFromDictionary:dictionary];

    XCTAssertEqual([self.preprocessor getValueForVariableWithName:@"v2"], @"value1", @"");
}

- (void)testAddingVariablesFromDictionaryWithNestedVariablesCycle; {
    NSDictionary *dictionary = @{@"v1" : @"$v2",
            @"v2" : @"$v1"};

    [self.preprocessor setVariablesFromDictionary:dictionary];

    XCTAssertEqual([self.preprocessor getValueForVariableWithName:@"v1"], [NSNull null], @"");
    XCTAssertEqual([self.preprocessor getValueForVariableWithName:@"v2"], [NSNull null], @"");
}

- (void)testAddingVariablesFromDictionaryWithNestedVariablesCycleAndPredefiniedValue; {
    NSDictionary *dictionary = @{@"v1" : @"$v2",
            @"v2" : @"$v1"};

    id value = @"v";

    [self.preprocessor setVariableValue:value forName:@"v1"];
    [self.preprocessor setVariableValue:value forName:@"v2"];
    [self.preprocessor setVariablesFromDictionary:dictionary];

    XCTAssertEqual([self.preprocessor getValueForVariableWithName:@"v1"], value, @"");
    XCTAssertEqual([self.preprocessor getValueForVariableWithName:@"v2"], value, @"");
}

- (void)testPreprocessingDictionary; {
    NSDictionary *variablesDictionary = @{@"v1" : @"v1-value",
            @"v2" : @"v2-value"};

    NSDictionary *componentStyleDictionary = @{@"property1" : @"$v1",
            @"property2" : @"$v2"};

    NSDictionary *dictionary = @{@"Variables" : variablesDictionary,
            @"Component" : componentStyleDictionary};

    NSDictionary *preprocessed = [self.preprocessor preprocess:dictionary userInterfaceIdiom:UIUserInterfaceIdiomPhone];

    XCTAssertFalse([preprocessed.allKeys containsObject:@"Variables"], @"Variables dictionary should be removed");

    XCTAssertEqual(preprocessed[@"Component"][@"property1"], @"v1-value", @"");
    XCTAssertEqual(preprocessed[@"Component"][@"property2"], @"v2-value", @"");
}

- (void)setUp; {
    self.preprocessor = [[UISSVariablesPreprocessor alloc] init];
}

- (void)tearDown; {
    self.preprocessor = nil;
}

@end
