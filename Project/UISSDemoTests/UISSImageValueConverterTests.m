//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSImageValueConverter.h"

@interface UISSImageValueConverterTests : XCTestCase

@property(nonatomic, strong) UISSImageValueConverter *converter;

@end

@implementation UISSImageValueConverterTests

- (void)testNullImage; {
    UIImage *image = [self.converter convertValue:[NSNull null]];
    XCTAssertNil(image, @"");

    NSString *code = [self.converter generateCodeForValue:[NSNull null]];
    XCTAssertEqual(code, @"nil", @"");
}

- (void)testSimleImageAsString; {
    UIImage *image = [self.converter convertValue:@"background"];

    XCTAssertNotNil(image, @"");
    XCTAssertEqual(image, [UIImage imageNamed:@"background"], @"");

    NSString *code = [self.converter generateCodeForValue:@"background"];
    XCTAssertEqual(code, @"[UIImage imageNamed:@\"background\"]", @"");
}

- (void)testResizableWithEdgeInsetsDefinedInSubarray; {
    id value = @[@"background", @[@1.0f, @2.0f, @3.0f, @4.0f]];

    UIImage *image = [self.converter convertValue:value];

    XCTAssertNotNil(image, @"");
    XCTAssertEqual([NSValue valueWithUIEdgeInsets:image.capInsets], [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(1, 2, 3, 4)], @"");

    NSString *code = [self.converter generateCodeForValue:value];
    XCTAssertEqual(code, @"[[UIImage imageNamed:@\"background\"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 2.0, 3.0, 4.0)]", @"");
}

- (void)testResizableDefinedInOneArray; {
    UIImage *image = [self.converter convertValue:@[@"background", @1.0f, @2.0f, @3.0f, @4.0f]];

    XCTAssertNotNil(image, @"");
    XCTAssertEqual([NSValue valueWithUIEdgeInsets:image.capInsets], [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(1, 2, 3, 4)], @"");
}

- (void)setUp; {
    self.converter = [[UISSImageValueConverter alloc] init];
}

- (void)tearDown; {
    self.converter = nil;
}

@end
