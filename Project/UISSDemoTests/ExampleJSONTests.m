//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISS.h"
#import <XCTest/XCTest.h>

@interface ExampleJSONTests : XCTestCase

@property(nonatomic, strong) UISS *uiss;

@end

@implementation ExampleJSONTests

- (void)setUp {
    [super setUp];

    NSURL *fileURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"example" withExtension:@"json"];
    self.uiss = [UISS defaultUISSWithURL:fileURL];
}

- (void)testGeneratedCodeForPad; {
    [self.uiss generateCodeForUserInterfaceIdiom:UIUserInterfaceIdiomPad
                                     codeHandler:^(NSString *code, NSArray *errors) {
                                         XCTAssertTrue(errors.count == 0, @"errors are unexpected");
                                         XCTAssertNotNil(code, @"");
                                         XCTAssertTrue([code rangeOfString:@"[[UINavigationBar appearance] setTintColor:[UIColor greenColor]];"].location != NSNotFound, @"");
                                     }];
}

- (void)testGeneratedCodeForPhone; {
    [self.uiss generateCodeForUserInterfaceIdiom:UIUserInterfaceIdiomPhone
                                     codeHandler:^(NSString *code, NSArray *errors) {
                                         XCTAssertTrue(errors.count == 0, @"errors are unexpected");
                                         XCTAssertNotNil(code, @"");
                                         XCTAssertTrue([code rangeOfString:@"[[UINavigationBar appearance] setTintColor:[UIColor redColor]];"].location != NSNotFound, @"");
                                     }];
}

- (void)testToolbarTintColor; {
    XCTAssertEqual([[UIToolbar appearance] tintColor], [UIColor yellowColor], @"");
}

- (void)testToolbarBackgroundImage; {
    UIImage *backgroundImage = [[UIToolbar appearance] backgroundImageForToolbarPosition:UIToolbarPositionAny
                                                                              barMetrics:UIBarMetricsDefault];
    XCTAssertNotNil(backgroundImage, @"");
    XCTAssertEqual([backgroundImage class], [UIImage class], @"bad property class");
}

- (void)testTabBarItemTitlePositionAdjustment; {
    NSValue *titlePositionAdjustment = [NSValue valueWithUIOffset:[[UITabBarItem appearance] titlePositionAdjustment]];
    XCTAssertEqual(titlePositionAdjustment, [NSValue valueWithUIOffset:UIOffsetMake(10, 10)], @"");
}

- (void)testNavigationBarTitleVerticalPositionAdjustment; {
    XCTAssertEqual(@([[UINavigationBar appearance] titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault]), @10.0f, @"");
}

- (void)testNavigationBarBackgroundImageForBarMetricsLandscapePhone; {
    XCTAssertNotNil([[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsLandscapePhone], @"");
}

- (void)testTabBarItemTitleTextAttributes; {
    UIFont *font = [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal][UITextAttributeFont];
    XCTAssertNotNil(font, @"");
    if (font) {
        XCTAssertEqual(font, [UIFont systemFontOfSize:24], @"");
    }
}

@end
