//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSRectValueConverter.h"

@interface UISSRectValueConverterTests : XCTestCase

@property(nonatomic, strong) UISSRectValueConverter *converter;

@end

@implementation UISSRectValueConverterTests

- (void)setUp; {
    self.converter = [[UISSRectValueConverter alloc] init];
}

- (void)tearDown; {
    self.converter = nil;
}

- (void)testRectAsArray; {
    id value = @[@1.0f,
            @2.0f,
            @3.0f,
            @4.0f];
    id converted = [self.converter convertValue:value];
    XCTAssertEqual(converted, [NSValue valueWithCGRect:CGRectMake(1, 2, 3, 4)], @"");

    NSString *code = [self.converter generateCodeForValue:value];
    XCTAssertEqual(code, @"CGRectMake(1.0, 2.0, 3.0, 4.0)", @"");
}

@end
