//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISSDemoSecondViewController.h"

#import "UISSDemoAppDelegate.h"

@implementation UISSDemoSecondViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
      return YES;
  }
}

- (IBAction)action:(id)sender {
    static BOOL random = YES;
    UISS *uiss = [(UISSDemoAppDelegate *)[[UIApplication sharedApplication] delegate] uiss];
    
    [uiss reloadWithURL:[[NSBundle mainBundle] URLForResource:random ? @"uiss2" : @"uiss" withExtension:@"json"]];
    
    random = (random + 1) % 2;
}

@end
