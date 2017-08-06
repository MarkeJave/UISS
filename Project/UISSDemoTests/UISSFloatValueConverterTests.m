//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSFloatValueConverter.h"

@interface UISSFloatValueConverterTests : XCTestCase

@property(nonatomic, strong) UISSFloatValueConverter *converter;

@end

@implementation UISSFloatValueConverterTests

- (void)setUp; {
    self.converter = [[UISSFloatValueConverter alloc] init];
    self.converter.precision = 4;
}

- (void)tearDown; {
    self.converter = nil;
}

- (void)testConversionFromNumber; {
    id value = [self.converter convertValue:@0.5f];
    XCTAssertTrue([value isKindOfClass:[NSValue class]], @"");

    CGFloat floatValue = 0;
    [value getValue:&floatValue];

    XCTAssertEqual(floatValue, 0.5f, @"");
}

- (void)testGeneratedCodeFromString; {
    XCTAssertEqual([self.converter generateCodeForValue:@"1.123"], @"1.1230", @"");
}

- (void)testGeneratedCodeFromNumber; {
    XCTAssertEqual([self.converter generateCodeForValue:[NSNumber numberWithFloat:1.123]], @"1.1230", @"");
}

@end
