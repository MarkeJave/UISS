//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSTextAttributesValueConverter.h"

@interface UISSTextAttributesValueConverterTests : XCTestCase

@property(nonatomic, strong) UISSTextAttributesValueConverter *converter;

@end

@implementation UISSTextAttributesValueConverterTests

- (void)testTextAttributesWithFont; {
    [self testValue:@{@"font" : @14.0f}
       expectedCode:[NSString stringWithFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14.0], UITextAttributeFont, nil]"]
        assertBlock:^(NSDictionary *attributes) {
            UIFont *font = attributes[UITextAttributeFont];
            XCTAssertEqual(font, [UIFont systemFontOfSize:14], @"");
        }];
}

- (void)testTextAttributesWithTextColor; {
    [self testValue:@{@"textColor" : @"orange"}
       expectedCode:[NSString stringWithFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor], UITextAttributeTextColor, nil]"]
        assertBlock:^(NSDictionary *attributes) {
            UIColor *color = attributes[UITextAttributeTextColor];
            XCTAssertEqual(color, [UIColor orangeColor], @"");
        }];
}

- (void)testTextAttributesWithTextShadowColor; {
    [self testValue:@{@"textShadowColor" : @"gray"}
       expectedCode:[NSString stringWithFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextShadowColor, nil]"]
        assertBlock:^(NSDictionary *attributes) {
            UIColor *color = attributes[UITextAttributeTextShadowColor];
            XCTAssertEqual(color, [UIColor grayColor], @"");
        }];
}

- (void)testTextAttributesWithTextShadowOffset; {
    [self testValue:@{@"textShadowOffset" : @[@2.0f]}
       expectedCode:[NSString stringWithFormat:@"[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithUIOffset:UIOffsetMake(2.0, 2.0)], UITextAttributeTextShadowOffset, nil]"]
        assertBlock:^(NSDictionary *attributes) {
            XCTAssertNotNil(attributes[UITextAttributeTextShadowOffset], @"");
            XCTAssertEqual(attributes[UITextAttributeTextShadowOffset], [NSValue valueWithUIOffset:UIOffsetMake(2, 2)], @"");
        }];
}

- (void)testValue:(id)value expectedCode:(NSString *)expectedCode assertBlock:(void (^)(NSDictionary *))assertBlock; {
    NSDictionary *attributes = [self.converter convertValue:value];
    XCTAssertNotNil(attributes, @"");
    assertBlock(attributes);

    NSString *code = [self.converter generateCodeForValue:value];
    XCTAssertEqual(code, expectedCode, @"");
}

- (void)setUp; {
    self.converter = [[UISSTextAttributesValueConverter alloc] init];
}

- (void)tearDown; {
    self.converter = nil;
}

@end
