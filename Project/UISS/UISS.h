//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISSConfig.h"
#import "UISSStyle.h"

extern NSString *const UISSWillApplyStyleNotification;
extern NSString *const UISSDidApplyStyleNotification;

extern NSString *const UISSWillRefreshViewsNotification;
extern NSString *const UISSDidRefreshViewsNotification;

@interface UISS : NSObject

@property(nonatomic, strong, readonly) UISSConfig *config;

@property(nonatomic, strong, readonly) UISSStyle *style;

@property(nonatomic, assign, readonly) NSTimeInterval delayTimeInterval;

@property(nonatomic, copy, readonly) NSArray *errors;

@property(nonatomic, assign) BOOL debugEnabled;

- (UISS *)initWithURL:(NSURL *)URL config:(UISSConfig *)config;
+ (UISS *)UISSWithURL:(NSURL *)URL config:(UISSConfig *)config;

+ (UISS *)defaultUISS;
+ (UISS *)defaultUISSWithURL:(NSURL *)URL;

- (void)apply;
- (void)applyAsynchronously;
- (void)applyURL:(NSURL *)URL; // Asynchronously
- (void)applyURL:(NSURL *)URL delay:(NSTimeInterval)delay;

// code handler is called on main thread
- (void)generateCodeForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
                              codeHandler:(void (^)(NSString *code, NSArray *errors))codeHandler;

@end
