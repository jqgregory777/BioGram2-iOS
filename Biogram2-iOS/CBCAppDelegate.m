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

@interface CBCAppDelegate ()

@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* verificationToken;

@property (nonatomic, strong) UIAlertView* medableLoginDialog;

@end

@implementation CBCAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize usingInMemoryStore = _usingInMemoryStore;

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
    _usingInMemoryStore = NO;
    
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
                                    @"TrialEventCount" : @0 };
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    // Initialize Medable's assets manager
    [MDAssetManager sharedManager];

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(medableUserDidLogIn) name:kMDNotificationUserDidLogin object:nil];
    [defaultCenter addObserver:self selector:@selector(medableUserDidLogOut) name:kMDNotificationUserDidLogout object:nil];

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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    // Medable - Delete temp files
    [[NSFileManager defaultManager] deleteGeneralCacheDirectoryForUserID:[MDAPIClient sharedClient].currentUserEmail];
}

#pragma mark - Utilities

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [urls lastObject];
}

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

- addPersistentStoreWithUrl:(NSURL *)storeURL error:(NSError **)pError;
{
    NSPersistentStore * store = nil;
    if (storeURL == nil)
        store = [_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:pError];
    else
        store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:pError];
    return store;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = (self.usingInMemoryStore) ? nil : [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Biogram2_iOS.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSPersistentStore * store = [self addPersistentStoreWithUrl:storeURL error:&error];
    
    if (!store)
    {
        if (!self.usingInMemoryStore)
        {
            // The schema for the persistent store is probably incompatible with current managed object model,
            // because we changed it (during development). Delete it and try again.
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            store = [self addPersistentStoreWithUrl:storeURL error:&error];
        }

        if (!store)
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
                //abort();
            }
        }
    }
}

- (BOOL)usingInMemoryStore
{
    return _usingInMemoryStore;
}

- (void)toggleUsingInMemoryStore
{
    [self setUsingInMemoryStore:!_usingInMemoryStore];
}

- (void)setUsingInMemoryStore:(BOOL)wantInMemory
{
    [self saveContext];
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;

    _usingInMemoryStore = wantInMemory;
    [self saveContext];
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

- (BOOL)updateHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent
{
    if (heartRateEvent != nil)
    {
        if (CBCHeartRateFeed.currentFeedSource == CBCFeedSourceCoreData)
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
        else
        {
            // TO DO: figure out how to update an already-posted event in medable
        }
    }
    return YES;
}

- (BOOL)savePendingHeartRateEvent
{
    BOOL success = NO;
    
    if (self.pendingHeartRateEvent != nil)
    {
        if (CBCHeartRateFeed.currentFeedSource == CBCFeedSourceCoreData)
        {
            // in Core Data (Trial mode), update and save are the same thing
            success = [self updateHeartRateEvent:self.pendingHeartRateEvent];
        }
        else
        {
            // in Medable, to save is to post an event to the user's feed
            [CBCSocialUtilities postToMedable:self.pendingHeartRateEvent postToPublicFeed:YES];
            success = YES;
        }
        
        // release the strong reference - if there are views open that still reference the object
        // they will also have strong references to it so it'll be retained until they're done
        self.pendingHeartRateEvent = nil;
    }
    
    return success;
}

#pragma mark - Medable Observer

- (void)medableUserDidLogIn
{
    BOOL loggedIn = [[CBCMedable singleton] isLoggedIn];
    
    NSLog(@"medableUserDidLogIn - loggedIn = %s", loggedIn?"YES":"NO");
    [[NSUserDefaults standardUserDefaults] setBool:loggedIn forKey:@"LoggedInToMedable"];
    
    // if there are any saved events in the local Core Data store, automatically post them
    // to the user's Medable feed
    NSArray * coreDataEvents = [CBCHeartRateFeed fetchHeartRateEventsFromCoreData];
    if (coreDataEvents != nil && coreDataEvents.count != 0)
    {
        int __block count = coreDataEvents.count;
        
        for (CBCHeartRateEvent * heartRateEvent in coreDataEvents)
        {
            [CBCSocialUtilities postToMedable:heartRateEvent postToPublicFeed:YES completion:
                ^(MDPost *post, MDFault *fault)
                {
                    NSLog(@"BATCH POST: decrementing count = %d", count);
                    --count;
                    if (count == 0)
                    {
                        NSLog(@"BATCH POST: DONE: count = %d", count);
                        [CBCHeartRateFeed deleteHeartRateEventsFromCoreData:coreDataEvents];

                        [[NSNotificationCenter defaultCenter] postNotificationName:kCBCSocialPostDidComplete object:self];
                    }
                }
            ];
        }
    }
}

- (void)medableUserDidLogOut
{
    BOOL loggedIn = [[CBCMedable singleton] isLoggedIn];
    
    NSLog(@"medableUserDidLogOut - loggedIn = %s", loggedIn?"YES":"NO");
    [[NSUserDefaults standardUserDefaults] setBool:loggedIn forKey:@"LoggedInToMedable"];
}

@end

