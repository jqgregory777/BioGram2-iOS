//
//  CBCAppDelegate.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCAppDelegate.h"
#import "CBCMedable.h"
#import "CBCHeartRateFeed.h"
#import "CBCSocialUtilities.h"

#import <iOSMedableSDK/AFNetworkActivityLogger.h>
#import <iOSMedableSDK/AFNetworkActivityIndicatorManager.h>

NSString* const kCBCActivityDidStart = @"kCBCActivityDidStart";
NSString* const kCBCActivityDidStop = @"kCBCActivityDidStop";

@interface CBCAppDelegate ()

- (void)medableUserDidLogIn:(NSNotification *)notification;
- (void)medableUserDidLogOut:(NSNotification *)notification;

@end

@implementation CBCAppDelegate

+ (CBCAppDelegate*)appDelegate
{
    return (CBCAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
                        NSLog(@"In fallback handler");
                    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup network calls. Log to console in debug builds.
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
#endif
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    // Install defaults for NSUserDefaults
    NSDictionary * appDefaults = @{ @"CacheMedableLoginEmail" : @YES,
                                    @"CacheMedableLoginPassword" : @NO,
                                    @"MedableAutoLogin" : @NO,
                                    @"LoggedInToMedable" : @NO,
                                    @"TrialEventCount" : @0 };
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"MaxTrialEventCount"];

    // Initialize Medable's assets manager
    [MDAssetManager sharedManager];

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(medableUserDidLogIn:) name:kMDNotificationUserDidLogin object:nil];
    [defaultCenter addObserver:self selector:@selector(medableUserDidLogOut:) name:kMDNotificationUserDidLogout object:nil];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[CBCMedable singleton] checkForValidSession];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[CBCMedable singleton] checkForValidSession];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Cancel any pending heart rate event before the application terminates.
    CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];
    [feed willRetire];
    
    // Medable - Delete temp files
    [[NSFileManager defaultManager] deleteGeneralCacheDirectoryForUserID:[MDAPIClient sharedClient].currentUserEmail];

    // Clean up observers
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:kMDNotificationUserDidLogin object:nil];
    [defaultCenter removeObserver:self name:kMDNotificationUserDidLogout object:nil];
}

#pragma mark - Utilities

// convenient utility -- put it here for lack of a better place
+ (void)showMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView* loginAlertView = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(title, nil)
                                   message:NSLocalizedString(message, nil)
                                   delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                   otherButtonTitles:nil];
    [loginAlertView show];
}

#pragma mark - Medable Observer

- (void)medableUserDidLogIn:(NSNotification *)notification
{
    BOOL loggedIn = [[CBCMedable singleton] isLoggedIn];
    
    NSLog(@"medableUserDidLogIn - loggedIn = %s", loggedIn?"YES":"NO");
    [[NSUserDefaults standardUserDefaults] setBool:loggedIn forKey:@"LoggedInToMedable"];
}

- (void)medableUserDidLogOut:(NSNotification *)notification
{
    BOOL loggedIn = [[CBCMedable singleton] isLoggedIn];
    
    NSLog(@"medableUserDidLogOut - loggedIn = %s", loggedIn?"YES":"NO");
    [[NSUserDefaults standardUserDefaults] setBool:loggedIn forKey:@"LoggedInToMedable"];
}

@end

