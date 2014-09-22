//
//  CBCHeartRateFeed.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/18/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCHeartRateFeed.h"
#import "CBCAppDelegate.h"
#import "CBCMedable.h"
#import "CBCSocialUtilities.h"

NSString* const kCBCWillSwitchFeed = @"kCBCWillSwitchFeed";
NSString* const kCBCDidSwitchFeed  = @"kCBCDidSwitchFeed";

// ----------------------------------------------------------------------------------------------------------------------------

#pragma mark - CBCFeed

@interface CBCFeed ()

@property (readonly, strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;

- (void)save;

@end

#pragma mark - CBCLocalFeed

@interface CBCLocalFeed : CBCFeed

- (CBCLocalFeed *)init;

@end

#pragma mark - CBCMedableFeed

@interface CBCMedableFeed : CBCFeed

@property (strong, nonatomic) NSMutableDictionary * postFromEvent; // ability to look up an MDPost given the managed object id of an event

- (CBCMedableFeed *)initWithType:(CBCFeedType)type;
- (CBCHeartRateEvent *) createHeartRateEventForPost:(MDPost *)post;
- (void)createHeartRateEventsForPosts:(NSArray *)feed;

@end

// ----------------------------------------------------------------------------------------------------------------------------

#pragma mark - CBCFeedManager

@implementation CBCFeedManager

static CBCFeedManager * _feedManager = nil;

+ (CBCFeedManager *)singleton
{
    if (_feedManager == nil)
    {
        _feedManager = [[CBCFeedManager alloc] init];
    }
    return _feedManager;
}

@synthesize currentFeed = _currentFeed;

- (CBCFeed *)currentFeed
{
    return _currentFeed;
}

- (CBCFeed *)switchToFeed:(CBCFeedType)type
{
    if (_currentFeed == nil || _currentFeed.type != type)
    {
        CBCFeedType oldFeedType = CBCFeedNone;

        if (_currentFeed != nil)
        {
            oldFeedType = _currentFeed.type;
            
            [_currentFeed willRetire];
        }

        {
            NSDictionary * userInfo = @{ @"OldFeedType" : [NSNumber numberWithInt:oldFeedType],
                                         @"NewFeedType" : [NSNumber numberWithInt:type] };
            [[NSNotificationCenter defaultCenter] postNotificationName:kCBCWillSwitchFeed object:nil userInfo:userInfo];
        }
        
        NSLog(@"*** SWITCHING TO FEED %@ (was %@) ***", [CBCFeed typeAsString:type], [CBCFeed typeAsString:oldFeedType]);
        
        switch (type)
        {
            case CBCFeedLocal:
                _currentFeed = [[CBCLocalFeed alloc] init];
                break;
            case CBCFeedPrivate:
            case CBCFeedPublic:
            case CBCFeedCollective:
                _currentFeed = [[CBCMedableFeed alloc] initWithType:type];
                break;
            default:
                NSAssert(NO, @"invalid feed type");
                break;
        }
        NSAssert(_currentFeed.type == type, @"feed type mismatch");
        
        {
            NSDictionary * userInfo = @{ @"OldFeedType" : [NSNumber numberWithInt:oldFeedType],
                                         @"NewFeedType" : [NSNumber numberWithInt:type] };
            [[NSNotificationCenter defaultCenter] postNotificationName:kCBCDidSwitchFeed object:nil userInfo:userInfo];
        }
    }
    
    return _currentFeed;
}

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [urls lastObject];
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.

@synthesize managedObjectModel = _managedObjectModel;

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Biogram2_iOS" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

@end

// ----------------------------------------------------------------------------------------------------------------------------

#pragma mark - CBCFeed

@implementation CBCFeed

- (CBCFeed *)initWithType:(CBCFeedType)type
{
    self = [super init];
    _type = type;
    return self;
}

- (void)dealloc
{
    NSLog(@"CBCFeed dealloc, self = %@", self);
}

+ (NSString *)typeAsString:(CBCFeedType)type
{
    switch (type)
    {
        case CBCFeedLocal:      return @"CBCFeedLocal";
        case CBCFeedPrivate:    return @"CBCFeedPrivate";
        case CBCFeedPublic:     return @"CBCFeedPublic";
        case CBCFeedCollective: return @"CBCFeedCollective";
        default:                return @"CBCFeedNone";
    }
}

- (void)save
{
    NSError * error = nil;
    NSManagedObjectContext * managedObjectContext = self.managedObjectContext;
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

- (void)willRetire
{
    [self cancelPendingHeartRateEvent];
    [self save];
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
}

#pragma mark - Core Data Scaffolding

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

@synthesize managedObjectContext = _managedObjectContext;

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

- (NSPersistentStore *)addPersistentStoreWithUrl:(NSURL *)storeURL error:(NSError **)pError;
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

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Local mode uses a SQLLite persistent store; all others use an in-memory store backed by Medable.
    NSURL *storeURL = (self.type == CBCFeedLocal) ? [[CBCFeedManager applicationDocumentsDirectory] URLByAppendingPathComponent:@"Biogram2_iOS.sqlite"] : nil;
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[CBCFeedManager singleton] managedObjectModel]];
    
    NSPersistentStore * store = [self addPersistentStoreWithUrl:storeURL error:&error];
    
    if (!store)
    {
        if (self.type == CBCFeedLocal)
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


@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HeartRateEvent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // NB: nil for section name key path means "no sections".
    NSFetchedResultsController * controller = [[NSFetchedResultsController alloc]
                                               initWithFetchRequest:fetchRequest
                                               managedObjectContext:self.managedObjectContext
                                               sectionNameKeyPath:nil
                                               cacheName:@"Master"];

    _fetchedResultsController = controller; // sets _fetchedResultsController
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (NSArray *)fetchAllHeartRateEvents
{
    NSManagedObjectContext * moc = [self managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription * entityDescription = [NSEntityDescription entityForName:@"HeartRateEvent" inManagedObjectContext:moc];
    [request setEntity:entityDescription];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError * error;
    NSArray * array = [moc executeFetchRequest:request error:&error];
    
    return array;
}

- (void)deleteHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent
{
    NSManagedObjectContext * context = [self managedObjectContext];
    [context deleteObject:heartRateEvent];
    [self save];
}

- (void)deleteHeartRateEvents:(NSArray *)events
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    for (CBCHeartRateEvent * event in events)
    {
        [context deleteObject:event];
    }

    [self save];
}

#pragma mark - Heart Rate Event Creation

- (CBCHeartRateEvent *)createHeartRateEvent;
{
    NSManagedObjectContext *context = [self managedObjectContext];
    CBCHeartRateEvent * event = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateEvent" inManagedObjectContext:context];
    event.timeStamp = [NSDate date]; // current date
    event.postedToFacebook = @NO;
    event.postedToTwitter = @NO;
    event.postedToMedable = @NO;

    NSLog(@"## created event: %@ (temp)", event.objectID.URIRepresentation);

    return event;
}

- (CBCHeartRateEvent *)createPendingHeartRateEvent;
{
    // cancel any pending event
    [self cancelPendingHeartRateEvent];
    
    self.pendingHeartRateEvent = [self createHeartRateEvent];
    
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

- (BOOL)savePendingHeartRateEvent
{
    BOOL success = NO;
    
    if (self.pendingHeartRateEvent != nil)
    {
        success = [self saveHeartRateEvent:self.pendingHeartRateEvent];
        
        // release the strong reference - if there are views open that still reference the object
        // they will also have strong references to it so it'll be retained until they're done
        self.pendingHeartRateEvent = nil;
    }
    
    return success;
}

- (BOOL)saveHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent
{
    if (heartRateEvent != nil)
    {
        [self save];
        
        NSManagedObjectID * permanentId = heartRateEvent.objectID;
        NSURL * url = [permanentId URIRepresentation];
        NSLog(@"%% Saved CBCHeartRateEvent with URL = %@", url);
        
        return YES;
    }
    return NO;
}

- (BOOL)updateHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent
{
    if (heartRateEvent != nil)
    {
        [self save];
        
        NSManagedObjectID * permanentId = heartRateEvent.objectID;
        NSURL * url = [permanentId URIRepresentation];
        NSLog(@"Updated CBCHeartRateEvent with URL = %@", url);

        return YES;
    }
    return NO;
}

#pragma mark - Medable callback

- (void)didPostEvent:(CBCHeartRateEvent *)heartRateEvent forMedablePost:(MDPost *)post
{
    // nothing to do - subclasses may override
}

@end

// ----------------------------------------------------------------------------------------------------------------------------

#pragma mark - CBCLocalFeed

@implementation CBCLocalFeed

- (CBCLocalFeed *) init
{
    self = [super initWithType:CBCFeedLocal];
    [self save]; // establish connection to Core Data
    return self;
}

@end

// ----------------------------------------------------------------------------------------------------------------------------

#pragma mark - CBCMedableFeed

@interface CBCMedableFeed ()

@property (nonatomic, strong) NSMutableArray* data;

@end

@implementation CBCMedableFeed

- (CBCMedableFeed *)initWithType:(CBCFeedType)type
{
    self = [super initWithType:type];
    [self save]; // establish connection to Core Data
    
    self.postFromEvent = [[NSMutableDictionary alloc] init];

    [self updateFeedFromMedable];
    
    return self;
}

- (BOOL)saveHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent
{
    BOOL success = [super saveHeartRateEvent:heartRateEvent];

    if (success)
    {
        BOOL postToPublicFeed = (self.type != CBCFeedPrivate); // FOR NOW post new events to private feed only if current feed is private - later allow user to select
        NSLog(@"## posting to Medable %s feed: %@", postToPublicFeed?"public":"private", heartRateEvent.objectID.URIRepresentation);
        [CBCSocialUtilities postToMedable:heartRateEvent postToPublicFeed:postToPublicFeed];
    }
    
    return success;
}

- (void)deleteHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent
{
    [super deleteHeartRateEvent:heartRateEvent];

    // Delete from Medable
    
    NSURL * eventKey = heartRateEvent.objectID.URIRepresentation;
    NSLog(@"## deleting from Medable feed: %@", eventKey);
    
    MDPost * post = [self.postFromEvent objectForKey:eventKey];
    if (post)
    {
        [self.postFromEvent removeObjectForKey:eventKey];
        
        NSString * creatorId = nil;
        if ([post.creator isExpanded])
        {
            creatorId = [post.creator.value objectForKey:kIDKey];
        }
        else
        {
            creatorId = post.creator.value;
        }
        
        if ([creatorId isEqualToString:[[MDAPIClient sharedClient] localUser].Id])
        {
            __weak typeof (self) wSelf = self;
            
            [[MDAPIClient sharedClient]
             deletePostWithId:post.Id
             commentId:nil
             callback:
                ^(MDFault *fault)
                {
                    NSURL * eventKey = heartRateEvent.objectID.URIRepresentation;
                    NSLog(@"## delete from Medable feed completed%s: %@", (fault != nil)?" (fault)":"", eventKey);
                    if (fault)
                    {
                        [[CBCMedable singleton] displayAlertWithFault:fault];
                    }
                }
            ];
        }
        else
        {
            // if the creator id doesn't match, don't delete from medable, but do clean up the mapping dict
            NSURL * eventKey = heartRateEvent.objectID.URIRepresentation;
            NSLog(@"## delete from Medable feed (but creator id didn't match): %@", eventKey);
            [self.postFromEvent removeObjectForKey:eventKey];
        }
    }
}

- (void)updateFeedFromMedable
{
    switch (self.type)
    {
        case CBCFeedPrivate:
            [self updateFeedFromPublic:NO];
            break;
            
        case CBCFeedPublic:
            [self updateFeedFromPublic:YES];
            break;
            
        case CBCFeedCollective:
            [self updateFeedFromCollective];
            break;
            
        default:
            NSAssert(NO, @"invalid feed type");
            break;
    }
}

- (void)updateFeedFromPublic:(BOOL)publicFeed
{
    __weak typeof (self) wSelf = self;
    
    MDAccount* currentAccount = [MDAPIClient sharedClient].localUser;
    if (currentAccount)
    {
        NSString* biogramId = [currentAccount biogramId];
        
        MDAPIParameters* parameters = nil;
        if (publicFeed)
        {
            //parameters = [MDAPIParameterFactory parametersWithIncludePostTypes:@[kPublicFeedKey] excludePostTypes:@[kPrivateFeedKey]]; // WORK AROUND API BUG
            parameters = [MDAPIParameterFactory parametersWithCustomParameters:@{ @"postTypes" : @"publicHeartrate,-privateHeartrate" }];
        }
        else
        {
            //parameters = [MDAPIParameterFactory parametersWithIncludePostTypes:@[kPrivateFeedKey] excludePostTypes:@[kPublicFeedKey]]; // WORK AROUND API BUG
            parameters = [MDAPIParameterFactory parametersWithCustomParameters:@{ @"postTypes" : @"publicHeartrate,privateHeartrate" }];
        }
        
        NSMutableDictionary * eventFromPost = [[NSMutableDictionary alloc] init];
        
        [[MDAPIClient sharedClient]
         listFeedWithBiogramId:biogramId
         parameters:parameters
         callback:
            ^(NSArray* feed, MDFault* fault)
            {
                if (!fault)
                {
                    [wSelf.postFromEvent removeAllObjects];
                    [wSelf createHeartRateEventsForPosts:feed];
                }
            }
        ];
    }
}

- (void)updateFeedFromCollective
{
    __weak typeof (self) wSelf = self;
    
    MDAPIClient* apiClient = [MDAPIClient sharedClient];
    
    // Current account
    MDAccount* currentAccount = apiClient.localUser;
    if (currentAccount)
    {
        // i.e. First Page
        // GET /feed/biogram/53e29340247fdb7b5c00010e?contexts[]=biogram&postTypes=heartrate&filterCaller=true&limit=2
        
        MDAPIParameters* contextsParameter = [MDAPIParameterFactory parametersWithContexts:@[ kBiogramKey ]];
        MDAPIParameters* postTypeParameter = [MDAPIParameterFactory parametersWithIncludePostTypes:@[ kHeartrateKey ] excludePostTypes:nil];
        MDAPIParameters* filterCallerParameter = [MDAPIParameterFactory parametersWithFilterCaller:YES];
        MDAPIParameters* limitParameter = [MDAPIParameterFactory parametersWithLimitResultsTo:2];
        
        MDAPIParameters* parameters = [MDAPIParameterFactory parametersWithParameters:
                                       contextsParameter,
                                       postTypeParameter,
                                       filterCallerParameter,
                                       limitParameter,
                                       nil];
        
        [self.postFromEvent removeAllObjects];

        // GET /feed?contexts[]=biogram&postTypes=heartrate&filterCaller=true
        [[MDAPIClient sharedClient]
         listFeedWithBiogramId:[currentAccount biogramId]
         parameters:parameters
         callback:^(NSArray *feed, MDFault *fault)
         {
             if (!fault)
             {
                 [wSelf createHeartRateEventsForPosts:feed];
             }
         }];
        
        
        [[MDAPIClient sharedClient]
         listPublicBiogramObjectsWithParameters:parameters
         callback:^(NSArray* feed, MDFault *fault)
         {
             if (!fault)
             {
                 [wSelf createHeartRateEventsForPosts:feed];
             }
         }];
    }
}

- (CBCHeartRateEvent *) createHeartRateEventForPost:(MDPost *)post
{
    // create a Core Data managed object for this post/event
    CBCHeartRateEvent* event = [self createHeartRateEvent];
    
    NSUInteger heartRate = 0;
    
    NSArray* body = [post body];
    for (NSDictionary* bodyDict in body)
    {
        NSString* segmentType = [bodyDict objectForKey:kTypeKey];
        if ([segmentType isEqualToString:kIntegerKey])
        {
            NSNumber* heartRateNumber = [bodyDict objectForKey:kValueKey];
            heartRate = [heartRateNumber unsignedIntegerValue];
        }
    }
    
    event.timeStamp = post.created;
    event.heartRate = [NSString stringWithFormat:@"%u", heartRate];
    event.eventDescription = post.text;
    event.backgroundImage = nil;
    event.overlayImage = nil;
    event.thumbnail = nil;
    event.postedToMedable = @YES;
    
    [post postPicsWithUpdateBlock:
        ^BOOL(NSString *imageId, UIImage *image, BOOL lastImage)
        {
            dispatch_async(dispatch_get_main_queue(),
                ^
                {
                    NSData * photoData = UIImagePNGRepresentation(image);
                    event.photo = photoData;
                }
            );
            return YES;
        }
    ];
    
    return event;
}

- (void)createHeartRateEventsForPosts:(NSArray *)feed
{
    NSMutableDictionary * eventFromPost = [[NSMutableDictionary alloc] init];
    
    for (MDPost* post in feed)
    {
        if (post.typeEnumerated == MDPostTypeHeartrate)
        {
            CBCHeartRateEvent * event = [self createHeartRateEventForPost:post];
            if (event != nil)
            {
                [eventFromPost setObject:event forKey:post.Id];
            }
        }
    }
    
    [self save]; // commit the new objects to give them *permanent* object IDs
    
    for (MDPost* post in feed)
    {
        if (post.typeEnumerated == MDPostTypeHeartrate)
        {
            CBCHeartRateEvent * event = [eventFromPost objectForKey:post.Id];
            if (event != nil)
            {
                NSURL * eventKey = event.objectID.URIRepresentation;
                NSLog(@"## found event: %@ (perm) for post: %@", eventKey, post);
                [self.postFromEvent setObject:post forKey:eventKey];
            }
        }
    }
}

#pragma mark - Medable callback

- (void)didPostEvent:(CBCHeartRateEvent *)event forMedablePost:(MDPost *)post
{
    NSURL * eventKey = event.objectID.URIRepresentation;
    NSLog(@"%% CBCMedableFeed didPostEvent:%@ forMedablePost%@", eventKey, post);
    [self.postFromEvent setObject:post forKey:eventKey];
}

@end
