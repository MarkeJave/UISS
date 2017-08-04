//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISSDemoAppDelegate.h"

#if UISS_DEBUG
#import "UISSAppearancePrivate.h"
#endif

@interface UISSDemoAppDelegate ()

@end

@implementation UISSDemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // skip the rest if running tests
    if ([[[NSProcessInfo processInfo] environment] objectForKey:@"TEST"]) {
        return YES;
    }

    // Remote Style
//    self.uiss = [UISS uissWithURL:[NSURL URLWithString:@"http://uiss.dev/uiss_demo.json"]];

    // Local Style
    self.uiss = [UISS defaultUISS];
    self.uiss.debugEnabled = YES;

    return YES;
}

@end
