//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSOffsetValueConverter.h"

@interface UISSOffsetValueConverterTests : XCTestCase

@property(nonatomic, strong) UISSOffsetValueConverter *converter;

@end

@implementation UISSOffsetValueConverterTests

- (void)setUp; {
    self.converter = [[UISSOffsetValueConverter alloc] init];
}

- (void)tearDown; {
    self.converter = nil;
}

- (void)testOffsetAsArray; {
    [self testValue:@[@1.0f, @2.0f]
     expectedOffset:UIOffsetMake(1, 2) expectedCode:@"UIOffsetMake(1.0, 2.0)"];

    [self testValue:@[@1.2f, @2.5f]
     expectedOffset:UIOffsetMake(1.2, 2.5) expectedCode:@"UIOffsetMake(1.2, 2.5)"];
}

- (void)testOffsetAsNumber; {
    [self testValue:@1.0f expectedOffset:UIOffsetMake(1, 1) expectedCode:@"UIOffsetMake(1.0, 1.0)"];
}

- (void)testValue:(id)value expectedOffset:(UIOffset)expectedOffset expectedCode:(NSString *)expectedCode; {
    id converted = [self.converter convertValue:value];
    XCTAssertEqual(converted, [NSValue valueWithUIOffset:expectedOffset], @"");

    NSString *code = [self.converter generateCodeForValue:value];
    XCTAssertEqual(code, expectedCode, @"");
}

@end
