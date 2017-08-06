//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UISSCodeGenerator.h"
#import "UISSPropertySetter.h"

@interface UISSCodeGeneratorTests : XCTestCase

@property(nonatomic, strong) UISSCodeGenerator *codeGenerator;

@end

@implementation UISSCodeGeneratorTests

- (void)testCodeGenerationWithGroups; {
    UISSPropertySetter *propertySetter = [[UISSPropertySetter alloc] init];
    propertySetter.group = @"Group";
    propertySetter.appearanceClass = [UIToolbar class];

    UISSProperty *property = [[UISSProperty alloc] init];
    property.name = @"tintColor";
    property.value = @"green";

    propertySetter.property = property;

    NSArray *errors = nil;

    NSString *code = [self.codeGenerator generateCodeForPropertySetters:@[propertySetter] errors:&errors];

    XCTAssertNotNil(code, @"");
    XCTAssertEqual(errors && errors.count, (NSUInteger) 0, @"");

    NSString *expectedCode = [NSString stringWithFormat:@"// Group\n%@\n", [propertySetter generatedCode]];
    XCTAssertEqual(code, expectedCode, @"");
}

- (void)setUp; {
    self.codeGenerator = [[UISSCodeGenerator alloc] init];
}

- (void)tearDown; {
    self.codeGenerator = nil;
}

@end
