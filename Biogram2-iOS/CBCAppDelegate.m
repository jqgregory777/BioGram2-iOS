//
//  CBCAppDelegate.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCAppDelegate.h"
#import "CBCFeedViewController.h"
#import "CBCSocialUtilities.h"

#import <iOSMedableSDK/AFNetworkActivityLogger.h>
#import <iOSMedableSDK/AFNetworkActivityIndicatorManager.h>

@interface CBCAppDelegate ()

@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* verificationToken;

@end

@implementation CBCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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
                                    @"LoggedInToMedable" : @NO,
                                    @"InTrialMode" : @YES,
                                    @"TrialEventCount" : @0 };
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    // Initialize Medable's assets manager
    [MDAssetManager sharedManager];

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
    
    [self checkForValidMedableSession];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self checkForValidMedableSession];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    // Medable - Delete temp files
    [[NSFileManager defaultManager] deleteGeneralCacheDirectoryForUserID:[MDAPIClient sharedClient].currentUserEmail];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges])
        {
            // Save the data to persistent store
            if (![managedObjectContext save:&error])
            {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You
                // should not use this function in a shipping application, although it may
                // be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        } 
    }
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

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Biogram2_iOS" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Biogram2_iOS.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        // The schema for the persistent store is probably incompatible with current managed object model, because we changed it (during development).
        // Delete it and try again.
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [urls lastObject];
}

#pragma mark - Heart Rate Event Creation

- (CBCHeartRateEvent *)createPendingHeartRateEvent;
{
    // cancel any pending event
    [self cancelPendingHeartRateEvent];

    NSManagedObjectContext *context = [self managedObjectContext];
    self.pendingHeartRateEvent = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateEvent" inManagedObjectContext:context];
    self.pendingHeartRateEvent.timeStamp = [NSDate date]; // current date
    self.pendingHeartRateEvent.postedToFacebook = @NO;
    self.pendingHeartRateEvent.postedToTwitter = @NO;
    self.pendingHeartRateEvent.postedToMedable = @NO;

    return self.pendingHeartRateEvent;
}

- (void)cancelPendingHeartRateEvent
{
    if (self.pendingHeartRateEvent != nil)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:self.pendingHeartRateEvent];
        self.pendingHeartRateEvent = nil;
    }
}

- (BOOL)saveHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent
{
    if (heartRateEvent != nil)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error = nil;
        if (![context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            return NO; // won't get here until abort() above is removed -- TO DO: handle these errors properly
        }
        
        NSManagedObjectID * permanentId = heartRateEvent.objectID;
        NSURL * url = [permanentId URIRepresentation];
        NSLog(@"Saved CBCHeartRateEvent with URL = %@", url);
    }
    return YES;
}

- (BOOL)savePendingHeartRateEvent
{
    BOOL success = NO;
    
    if (self.pendingHeartRateEvent != nil)
    {
        success = [self saveHeartRateEvent:self.pendingHeartRateEvent];

        if (success)
        {
            // nothing to do right now
        }
        
        self.pendingHeartRateEvent = nil; // release the strong reference
    }
    
    return success;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.alertViewStyle)
    {
        case UIAlertViewStyleLoginAndPasswordInput:
        {
            if (buttonIndex == 1)
            {
                UITextField* emailTextField = [alertView textFieldAtIndex:0];
                self.email = emailTextField.text;
                
                UITextField* passwordTextField = [alertView textFieldAtIndex:1];
                self.password = passwordTextField.text;
                
                [self loginMedableWithEmail:self.email
                                   password:self.password
                          verificationToken:self.verificationToken];
            }
            
            break;
        }
            
        case UIAlertViewStylePlainTextInput:
        {
            UITextField* codeTextField = [alertView textFieldAtIndex:0];
            self.verificationToken = codeTextField.text;
            
            [self loginMedableWithEmail:self.email
                               password:self.password
                      verificationToken:self.verificationToken];
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Medable

- (void)checkForValidMedableSession
{
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(medableLoginStateDidChange) name:kMDNotificationUserDidLogin object:nil];
    [defaultCenter addObserver:self selector:@selector(medableLoginStateDidChange) name:kMDNotificationUserDidLogout object:nil];

    // Autologin if we already have a token

    __weak typeof (self) wSelf = self;

    [[MDAPIClient sharedClient]
     loginStatusWithParameters:[MDAPIParameterFactory parametersWithExpand]
     callback:
     ^(MDAccount* account, MDFault* fault)
     {
         if (account == nil)
         {
             [wSelf showMedableLoginDialog];
         }
     }];
}

- (void)medableLoginStateDidChange
{
    BOOL loggedIn = ([[MDAPIClient sharedClient] localUser] != nil);
    NSLog(@"medableLoginStateDidChange - loggedIn = %s", loggedIn?"YES":"NO");
    [[NSUserDefaults standardUserDefaults] setBool:loggedIn forKey:@"LoggedInToMedable"];
    
    if (loggedIn)
    {
        // once you've logged in at least once, you're no longer in trial mode
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"InTrialMode"];
    }
}

- (void)loginMedableWithEmail:(NSString*)email password:(NSString*)password verificationToken:(NSString*)verificationToken
{
    if (email.length && password.length)
    {
        __weak typeof (self) wSelf = self;
        
        [[MDAPIClient sharedClient]
         authenticateSessionWithEmail:email
                             password:password
                    verificationToken:verificationToken
                            singleUse:NO
                             callback:
            ^(MDAccount *localUser, MDFault *fault)
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginEmail"])
                    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"MedableLoginEmail"];
                else
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MedableLoginEmail"];
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginPassword"])
                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
                else
                    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
                
                if (fault)
                {
                    if ([fault.code isEqualToString:kMDAPIErrorUnverifiedLocation] ||
                        [fault.code isEqualToString:kMDAPIErrorNewLocation])
                    {
                        [wSelf displayAlertWithMedableFault:fault];
                    }
                    else if ([fault.code isEqualToString:@"kInvalidCredentials"])
                    {
                        [wSelf showMedableLoginDialog];
                    }
                    else
                    {
                        [wSelf displayAlertWithMessage:fault.text];
                    }
                }
            }
        ];
    }
}

- (void)logoutMedable
{
    __weak typeof (self) wSelf = self;
    
    [[MDAPIClient sharedClient] logout:^(MDFault *fault)
    {
        if (fault)
        {
            [wSelf displayAlertWithMedableFault:fault];
        }
    }];
}

- (void)showMedableLoginDialog
{
    UIAlertView* loginAlertView = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Medable Login", nil)
                                   message:NSLocalizedString(@"Enter your credentials", nil)
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                   otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
    
    loginAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginEmail"])
    {
        // the user has requested that we cache the login information for convenience
        // see if we have any cached info, and auto-login if so
        NSString * email = [[NSUserDefaults standardUserDefaults] stringForKey:@"MedableLoginEmail"];
        if (email != nil)
        {
            [loginAlertView textFieldAtIndex:0].text = email;
            [[loginAlertView textFieldAtIndex:1] becomeFirstResponder]; // sadly this doesn't work, need to do it in the UIAlertView's viewWillAppear: method...
        }
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginPassword"])
    {
        // the user has requested that we cache the login information for convenience
        // see if we have any cached info, and auto-login if so
        NSString * password = [[NSUserDefaults standardUserDefaults] stringForKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
        if (password != nil)
        {
            [loginAlertView textFieldAtIndex:1].text = password;
        }
    }
    
    [loginAlertView show];
}

- (void)displayAlertWithMedableFault:(MDFault*)fault
{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:[@"Error: " stringByAppendingString:fault.code]
                          message:fault.text
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
    
    // Received error on first login with no verification token
    if ([fault.code isEqualToString:kMDAPIErrorUnverifiedLocation] ||
        [fault.code isEqualToString:kMDAPIErrorNewLocation])
    {
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.message = [alert.message stringByAppendingString:@"\nPlease enter verfication code:"];
    }
    
    [alert show];
}

- (void)displayAlertWithMessage:(NSString*)message
{
    [[[UIAlertView alloc]
      initWithTitle:nil
      message:message
      delegate:nil
      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
      otherButtonTitles:nil] show];
}

@end

// org.uscbodycomputing.${PRODUCT_NAME:rfc1034identifier}
// biogrammobileapp

