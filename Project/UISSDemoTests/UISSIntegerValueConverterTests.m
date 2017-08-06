//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSIntegerValueConverter.h"

@interface UISSIntegerValueConverterTests : XCTestCase

@property(nonatomic, strong) UISSIntegerValueConverter *converter;

@end

@implementation UISSIntegerValueConverterTests

- (void)setUp; {
    self.converter = [[UISSIntegerValueConverter alloc] init];
}

- (void)tearDown; {
    self.converter = nil;
}

- (void)testUnsignedInteger; {
    id value = [self.converter convertValue:@10U];
    XCTAssertTrue([value isKindOfClass:[NSValue class]], @"");

    NSUInteger unsignedIntegerValue = 0;
    [value getValue:&unsignedIntegerValue];

    XCTAssertEqual(unsignedIntegerValue, (NSUInteger) 10, @"");
}

- (void)testInteger; {
    id value = [self.converter convertValue:@-10];
    XCTAssertTrue([value isKindOfClass:[NSValue class]], @"");

    NSInteger integerValue = 0;
    [value getValue:&integerValue];

    XCTAssertEqual(integerValue, (NSInteger) -10, @"");
}

@end
