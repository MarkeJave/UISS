//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSParser.h"
#import "UISSPropertySetter.h"
#import "UISSError.h"

@interface UISSParserTests : XCTestCase

@property(nonatomic, strong) UISSParser *parser;

@end

@implementation UISSParserTests

#pragma mark - Groups

- (void)testGroups; {
    NSDictionary *dictionary = @{@"UIToolbar" : @{@"tintColor" : @"yellow"}};
    dictionary = @{@"@Group" : dictionary};

    NSArray *errors = [NSArray array];

    NSArray *propertySetters = [self.parser parseDictionary:dictionary errors:&errors];

    XCTAssertEqual(errors.count, 0, @"expected no errors");
    XCTAssertEqual(propertySetters.count, (NSUInteger) 1, @"expected one property setter");

    UISSPropertySetter *propertySetter = [propertySetters lastObject];
    XCTAssertEqual(propertySetter.group, @"Group", @"");
    XCTAssertEqual(propertySetter.containment.count, (NSUInteger) 0, @"");
}

#pragma mark - Errors

- (void)testInvalidAppearanceDictionary; {
    NSDictionary *dictionary = @{@"UIToolbar" : @"Invalid dictionary"};
    NSArray *errors = [NSArray array];

    [self.parser parseDictionary:dictionary errors:&errors];

    XCTAssertEqual(errors.count, (NSUInteger) 1, @"expected one error");
    NSError *error = errors.lastObject;
    XCTAssertEqual(error.code, UISSInvalidAppearanceDictionaryError, @"");
    XCTAssertEqual((error.userInfo)[UISSInvalidAppearanceDictionaryErrorKey], dictionary, @"");
}

- (void)testUnknownClassNameWithoutContainment; {
    NSDictionary *dictionary = @{@"UnknownClass" : @{@"tintColor" : @"yellow"}};
    NSArray *errors = [NSArray array];

    [self.parser parseDictionary:dictionary errors:&errors];

    XCTAssertEqual(errors.count, (NSUInteger) 1, @"expected one error");
    NSError *error = errors.lastObject;
    XCTAssertEqual(error.code, UISSUnknownClassError, @"");
    XCTAssertEqual((error.userInfo)[UISSInvalidClassNameErrorKey], @"UnknownClass", @"");
}

- (void)testInvalidAppearanceContainerClass; {
    NSDictionary *dictionary = @{@"UIToolbar" : @{@"tintColor" : @"yellow"}};
    dictionary = @{@"UIBarButtonItem" : dictionary};
    NSArray *errors = [NSArray array];

    [self.parser parseDictionary:dictionary errors:&errors];

    XCTAssertEqual(errors.count, (NSUInteger) 1, @"expected one error");
    NSError *error = errors.lastObject;
    XCTAssertEqual(error.code, UISSInvalidAppearanceContainerClassError, @"");
    XCTAssertEqual((error.userInfo)[UISSInvalidClassNameErrorKey], @"UIBarButtonItem", @"");
}

- (void)testInvalidAppearanceClass; {
    NSDictionary *dictionary = @{@"NSString" : @{@"tintColor" : @"yellow"}};
    NSArray *errors = [NSArray array];

    [self.parser parseDictionary:dictionary errors:&errors];

    XCTAssertEqual(errors.count, (NSUInteger) 1, @"expected one error");
    NSError *error = errors.lastObject;
    XCTAssertEqual(error.code, UISSInvalidAppearanceClassError, @"");
    XCTAssertEqual((error.userInfo)[UISSInvalidClassNameErrorKey], @"NSString", @"");
}

- (void)testInvalidAppearanceClassInContainer; {
    NSDictionary *dictionary = @{@"UIBadToolbar" : @{@"tintColor" : @"yellow"}};
    dictionary = @{@"UIPopoverController" : dictionary};
    NSArray *errors = [NSArray array];

    [self.parser parseDictionary:dictionary errors:&errors];

    XCTAssertEqual(errors.count, (NSUInteger) 1, @"expected one error");
    NSError *error = errors.lastObject;
    XCTAssertEqual(error.code, UISSUnknownClassError, @"");
    XCTAssertEqual((error.userInfo)[UISSInvalidClassNameErrorKey], @"UIBadToolbar", @"");
}

#pragma mark - Invocations

- (void)testToolbarTintColor; {
    NSDictionary *dictionary = @{@"UIToolbar" : @{@"tintColor" : @"yellow"}};

    [self parserTestWithDictionary:dictionary assertionsAfterInvoke:^(NSInvocation *invocation) {
        XCTAssertEqual(invocation.target, [UIToolbar appearance], @"expected target to be UIToolbar appearance proxy");
        XCTAssertEqual(invocation.selector, @selector(setTintColor:), @"");

        UIColor *color;
        [invocation getArgument:&color atIndex:2];
        XCTAssertEqual(color, [UIColor yellowColor], @"");
    }];
}

- (void)testLabelShadowOffset; {
    NSDictionary *dictionary = @{@"UILabel" : @{@"shadowOffset" : @1.0f}};

    [self parserTestWithDictionary:dictionary assertionsAfterInvoke:^(NSInvocation *invocation) {
        XCTAssertEqual(invocation.target, [UILabel appearance], @"expected target to be UILabel appearance proxy");
        XCTAssertEqual(invocation.selector, @selector(setShadowOffset:), @"");

        CGSize shadowOffset;
        [invocation getArgument:&shadowOffset atIndex:2];
        XCTAssertTrue(shadowOffset.width == 1 && shadowOffset.height == 1, @"");
        
        XCTAssertTrue([[UILabel appearance] shadowOffset].width == 1 && [[UILabel appearance] shadowOffset].height == 1, @"");
    }];
}

- (void)testButtonTitleColorForState; {
    NSDictionary *dictionary = @{@"UIButton" : @{@"titleColor:highlighted" : @"green"}};


    [self parserTestWithDictionary:dictionary assertionsAfterInvoke:^(NSInvocation *invocation) {
        XCTAssertEqual([[UIButton appearance] titleColorForState:UIControlStateHighlighted], [UIColor greenColor], @"");
    }];
}

- (void)testSimpleContainment; {
    NSDictionary *buttonDictionary = @{@"UIButton" : @{@"titleColor:highlighted" : @"green"}};
    NSDictionary *containmentDictionary = @{@"UINavigationController" : buttonDictionary};


    [self parserTestWithDictionary:containmentDictionary assertionsAfterInvoke:^(NSInvocation *invocation) {
        UIColor *buttonColor = [[UIButton appearanceWhenContainedIn:[UINavigationController class],
                                                                    nil] titleColorForState:UIControlStateHighlighted];
        XCTAssertEqual(buttonColor, [UIColor greenColor], @"");
    }];
}

- (void)testContainment; {
    NSDictionary *dictionary = @{@"UIButton" : @{@"titleColor:highlighted" : @"yellow"}};
    dictionary = @{@"UIImageView" : dictionary};
    dictionary = @{@"UINavigationController" : dictionary};

    [self parserTestWithDictionary:dictionary assertionsAfterInvoke:^(NSInvocation *invocation) {
        UIColor *buttonColor = [[UIButton appearanceWhenContainedIn:[UIImageView class], [UINavigationController class],
                                                                    nil] titleColorForState:UIControlStateHighlighted];
        XCTAssertEqual(buttonColor, [UIColor yellowColor], @"");
    }];
}

#pragma mark - Helper Methods

- (void)parserTestWithDictionary:(NSDictionary *)dictionary assertionsAfterInvoke:(void (^)(NSInvocation *))assertions; {
    UISSParser *parser = [[UISSParser alloc] init];

    NSMutableArray *invokedInvocations = [NSMutableArray array];

    NSArray *propertySetters = [parser parseDictionary:dictionary];
    for (UISSPropertySetter *propertySetter in propertySetters) {
        NSInvocation *invocation = propertySetter.invocation;
        if (invocation) {
            [invocation invoke];
            [invokedInvocations addObject:invocation];
            assertions(invocation);
        }
    }

    XCTAssertTrue([invokedInvocations count], @"expected at least one invocation");
}

#pragma mark - Setup

- (void)setUp; {
    self.parser = [[UISSParser alloc] init];
}

- (void)tearDown; {
    self.parser = nil;
}

@end

