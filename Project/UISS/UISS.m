//
// Copyright (c) 2013 Robert Wijas. All rights reserved.
//

#import "UISS.h"

#import "UISSStatusViewController.h"
#import "UISSPropertySetter.h"
#import "UISSConsoleViewController.h"
#import "UISSError.h"
#import "UISSCodeGenerator.h"
#import "UISSStatusWindow.h"

#if UISS_DEBUG

#import "UISSAppearancePrivate.h"

#endif

NSString *const UISSWillApplyStyleNotification = @"UISSWillApplyStyleNotification";
NSString *const UISSDidApplyStyleNotification = @"UISSDidApplyStyleNotification";

NSString *const UISSWillRefreshViewsNotification = @"UISSWillRefreshViewsNotification";
NSString *const UISSDidRefreshViewsNotification = @"UISSDidRefreshViewsNotification";

@interface UISS () <UISSStatusWindowControllerDelegate>

@property(nonatomic, strong) UISSStatusViewController *statusWindowController;
@property(nonatomic, strong) UISSStatusWindow *statusWindow;

@property(nonatomic, strong) NSTimer *delayLoadTimer;

@property(nonatomic, strong) UISSCodeGenerator *codeGenerator;

@property(nonatomic, strong) NSMutableArray *configuredAppearanceProxies;

@property(nonatomic, assign) NSTimeInterval delayTimeInterval;

@property(nonatomic, strong) UISSConfig *config;

@property(nonatomic, strong) UISSStyle *style;

@property(nonatomic, copy) NSArray *errors;

// all style parsing is done on the queue
#if OS_OBJECT_USE_OBJC
@property(nonatomic, strong) dispatch_queue_t queue;
#else
@property(nonatomic, unsafe_unretained) dispatch_queue_t queue;
#endif

@end

@implementation UISS

#pragma mark - Constructors

- (id)init {
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("com.robertwijas.uiss.queue", DISPATCH_QUEUE_SERIAL);
        self.codeGenerator = [[UISSCodeGenerator alloc] init];
        self.errors = @[];
#if UISS_DEBUG
        self.configuredAppearanceProxies = [NSMutableArray array];
        
        [self logDebugMessageOnce];
#endif
    }
    return self;
}

- (UISS *)initWithURL:(NSURL *)URL config:(UISSConfig *)config;{
    if (self = [self init]) {
        self.style = [UISSStyle styleWithURL:URL];
        self.config = config;
    }
    return self;
}

- (void)dealloc {
#if !(OS_OBJECT_USE_OBJC)
    dispatch_release(self.queue);
#endif
}

- (void)logDebugMessageOnce {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"UISS is running in DEBUG mode");
    });
}

+ (UISS *)UISSWithURL:(NSURL *)URL config:(UISSConfig *)config;{
    return [[self alloc] initWithURL:URL config:config];
}

+ (UISS *)defaultUISS; {
    NSURL *defaultURL = [[NSBundle mainBundle] URLForResource:@"uiss" withExtension:@"json"];
    return [self defaultUISSWithURL:defaultURL];
}

+ (UISS *)defaultUISSWithURL:(NSURL *)URL; {
    return [[self alloc] initWithURL:URL config:[UISSConfig defaultConfig]];
}

#pragma mark - Reloading Style

- (void)configureAppearanceWithPropertySetters:(NSArray *)propertySetters {
    [[NSNotificationCenter defaultCenter] postNotificationName:UISSWillApplyStyleNotification object:self];
    
#if UISS_DEBUG
    [self resetAppearanceForPropertySetters:propertySetters];
#endif
    
    NSMutableArray *invocations = [NSMutableArray array];
    
    for (UISSPropertySetter *propertySetter in propertySetters) {
        NSInvocation *invocation = propertySetter.invocation;
        if (invocation) {
            [invocations addObject:invocation];
        } else {
            NSError *error = [UISSError errorWithCode:UISSPropertySetterCreateInvocationError userInfo:[NSDictionary dictionaryWithObject:propertySetter forKey:UISSPropertySetterErrorKey]];
            self.errors = [[self errors] arrayByAddingObject:error];
        }
    }
    
    for (NSInvocation *invocation in invocations) {
        if ([[self configuredAppearanceProxies] containsObject:[invocation target]] == NO) {
            [[self configuredAppearanceProxies] addObject:[invocation target]];
        }
        
        [invocation invoke];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UISSDidApplyStyleNotification object:self];
}

- (void)applyURL:(NSURL *)URL;{
    [self applyURL:URL delay:0];
}

- (void)applyURL:(NSURL *)URL delay:(NSTimeInterval)delay;{
    self.style = [UISSStyle styleWithURL:URL];
    
    if (delay > 0) {
        self.delayTimeInterval = delay;
        
        [self updateDelayLoadTimer];
    } else {
        [self applyAsynchronously];
    }
}

- (void)applyAsynchronously {
    dispatch_async([self queue], ^{
        NSArray *errors = nil;
        UIUserInterfaceIdiom userInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
        NSArray *propertySetters = [[self style] parseForUserInterfaceIdiom:userInterfaceIdiom withConfig:[self config] errors:&errors];
        if (propertySetters) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configureAppearanceWithPropertySetters:propertySetters];
                [self refreshViews];
            });
        } else if (errors && [errors count]) {
            self.errors = [[self errors] arrayByAddingObjectsFromArray:errors];
        }
    });
}

- (void)apply {
    __block NSArray *propertySetters = nil;
    
    dispatch_sync(self.queue, ^{
        NSArray *errors = nil;
        UIUserInterfaceIdiom userInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
        propertySetters = [[self style] parseForUserInterfaceIdiom:userInterfaceIdiom withConfig:[self config] errors:&errors];
        if (errors && [errors count]) {
            self.errors = [[self errors] arrayByAddingObjectsFromArray:errors];
        }
    });
    
    if (propertySetters) {
        [self configureAppearanceWithPropertySetters:propertySetters];
    }
}

- (void)refreshViews {
    [[NSNotificationCenter defaultCenter] postNotificationName:UISSWillRefreshViewsNotification object:self];
    
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        for (UIView *view in [[window subviews] copy]) {
            [view removeFromSuperview];
            [window addSubview:view];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UISSDidRefreshViewsNotification object:self];
}

#if UISS_DEBUG

- (void)resetAppearanceForPropertySetters:(NSArray *)propertySetters {
    UISS_LOG(@"resetting appearance");
    
    for (id appearanceProxy in self.configuredAppearanceProxies) {
        [[appearanceProxy _appearanceInvocations] removeAllObjects];
    }
    
    [self.configuredAppearanceProxies removeAllObjects];
}

#endif

#pragma mark - Code Generation

- (void)generateCodeForUserInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
                              codeHandler:(void (^)(NSString *code, NSArray *errors))codeHandler {
    NSAssert(codeHandler, @"code handler required");
    
    dispatch_async([self queue], ^{
        NSArray *errors = nil;
        UIUserInterfaceIdiom userInterfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
        NSArray *propertySetters = [[self style] parseForUserInterfaceIdiom:userInterfaceIdiom withConfig:[self config] errors:&errors];
        
        NSString *code = [[self codeGenerator] generateCodeForPropertySetters:propertySetters errors:&errors];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            codeHandler(code, [[self errors] arrayByAddingObjectsFromArray:errors]);
        });
    });
}

#pragma mark - Auto Reload

- (void)updateDelayLoadTimer {
    if ([self delayTimeInterval] > 0) {
        self.delayLoadTimer = [NSTimer scheduledTimerWithTimeInterval:self.delayTimeInterval
                                                               target:self
                                                             selector:@selector(applyAsynchronously)
                                                             userInfo:nil repeats:YES];
    } else {
        self.delayLoadTimer = nil;
    }
}

- (void)setAutoReloadTimer:(NSTimer *)delayLoadTimer {
    [_delayLoadTimer invalidate];
    _delayLoadTimer = delayLoadTimer;
}

#pragma mark - Status Window

- (BOOL)debugEnabled {
    return [self statusWindow] != nil;
}

- (void)setDebugEnabled:(BOOL)debugEnabled {
    if (debugEnabled) {
        if ([self statusWindowController] == nil) {
            // configure Console
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"uiss_console" ofType:@"json"
                                                            inDirectory:@"UISSResources.bundle"];
            if (filePath) {
                [[UISS defaultUISSWithURL:[NSURL fileURLWithPath:filePath]] apply];
            }
            
            self.statusWindow = [[UISSStatusWindow alloc] init];
            
            UISSStatusViewController *statusWindowController = [[UISSStatusViewController alloc] init];
            statusWindowController.delegate = self;
            
            self.statusWindow.rootViewController = statusWindowController;
            self.statusWindow.hidden = NO;
        }
    } else {
        self.statusWindow = nil;
    }
}

#pragma mark - Console

- (void)statusWindowControllerDidSelect:(UISSStatusViewController *)statusWindowController {
    [self presentConsoleViewController];
}

- (void)presentConsoleViewController {
    UISSConsoleViewController *consoleViewController = [[UISSConsoleViewController alloc] initWithUISS:self];
    consoleViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if (presentingViewController.presentedViewController) {
        if ([presentingViewController.presentedViewController isKindOfClass:[UISSConsoleViewController class]]) {
            [presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [presentingViewController dismissViewControllerAnimated:YES completion:^{
                [presentingViewController presentViewController:consoleViewController animated:YES completion:nil];
            }];
        }
    } else {
        [presentingViewController presentViewController:consoleViewController animated:YES completion:nil];
    }
}

@end
