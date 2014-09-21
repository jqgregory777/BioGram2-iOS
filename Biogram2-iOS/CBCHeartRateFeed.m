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

- (void)willRetire;

@end

#pragma mark - CBCLocalFeed

@interface CBCLocalFeed : CBCFeed

- (CBCLocalFeed *)init;

@end

#pragma mark - CBCMedableFeed

@interface CBCMedableFeed : CBCFeed

- (CBCMedableFeed *)initWithType:(CBCFeedType)type;

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
        [self save];
        
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
        success = [self updateHeartRateEvent:self.pendingHeartRateEvent];
        
        // release the strong reference - if there are views open that still reference the object
        // they will also have strong references to it so it'll be retained until they're done
        self.pendingHeartRateEvent = nil;
    }
    
    return success;
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
    [self save]; // establish connection to Core Data and refresh feed from Medable

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(socialPostDidComplete:) name:kCBCSocialPostDidComplete object:nil];  // TO DO: not needed anymore
    
    return self;
}

- (void)socialPostDidComplete:(NSNotification *)notification
{
    // TO DO: if the completed post was a medable post, handle it appropriately
}

- (void)deleteFromMedable:(NSIndexPath *)indexPath
{
    __weak typeof (self) wSelf = self;
    
    // Delete from Medable
    MDPost* post = [self.data objectAtIndex:indexPath.row];
    
    NSString* creatorId = nil;
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
        [[MDAPIClient sharedClient]
         deletePostWithId:post.Id
         commentId:nil
         callback:^(MDFault *fault)
         {
             if (fault)
             {
                 [[CBCMedable singleton] displayAlertWithFault:fault];
             }
             else
             {
                 [wSelf.data removeObject:post];

//               [wSelf.tableView deleteRowsAtIndexPaths:@[indexPath]
//                                        withRowAnimation:UITableViewRowAnimationFade];
             }
         }];
    }
}

- (void)updateMedableFeed // TO DO: use this to gather Medable events and copy them into the in-memory Core Data store
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
        
        [[MDAPIClient sharedClient]
         listFeedWithBiogramId:biogramId
         parameters:parameters
         callback:^(NSArray *feed, MDFault *fault)
         {
             if (!fault)
             {
                 [wSelf.data removeAllObjects];
                 [wSelf.data addObjectsFromArray:feed];
                 
                 //[wSelf.tableView reloadData]; // FIXME
             }
         }];
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
        
        // GET /feed?contexts[]=biogram&postTypes=heartrate&filterCaller=true
        [[MDAPIClient sharedClient]
         listFeedWithBiogramId:[currentAccount biogramId]
         parameters:parameters
         callback:^(NSArray *feed, MDFault *fault)
         {
             if (!fault)
             {
                 //[wSelf.tableView reloadData]; // FIXME
             }
         }];
        
        
        [[MDAPIClient sharedClient]
         listPublicBiogramObjectsWithParameters:parameters
         callback:^(NSArray* feed, MDFault *fault)
         {
             if (!fault)
             {
                 [wSelf.data removeAllObjects];
                 [wSelf.data addObjectsFromArray:feed];
                 
                 //[wSelf.tableView reloadData]; // FIXME
             }
         }];
    }
}

/*
- (BOOL)configureCellToDoToDo
{
    MDPost* post = [self.data objectAtIndex:indexPath.row];
    
    if (post.typeEnumerated == MDPostTypeHeartrate)
    {
        NSUInteger heartbeat = 0;
        
        NSArray* body = [post body];
        for (NSDictionary* bodyDict in body)
        {
            NSString* segmentType = [bodyDict objectForKey:kTypeKey];
            if ([segmentType isEqualToString:kIntegerKey])
            {
                NSNumber* heartbeatNumber = [bodyDict objectForKey:kValueKey];
                heartbeat = [heartbeatNumber unsignedIntegerValue];
            }
        }
        
        cell.textLabel.text = [NSDateFormatter
                               localizedStringFromDate:post.created
                               dateStyle:NSDateFormatterMediumStyle
                               timeStyle:NSDateFormatterShortStyle];
        
        cell.imageView.image = [UIImage imageNamed:@"tabbar_heartrate"]; // cells are reused so it could have the image of another post, remove it
        
        [post postPicsWithUpdateBlock:^BOOL(NSString *imageId, UIImage *image, BOOL lastImage)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                cell.imageView.image = image;
                            });
             
             return YES;
         }];
        
    }
}
*/

/*
 else if (self.displayedPost)
 {
 self.postedToFacebookImgView.hidden = YES;
 self.postedToTwitterImgView.hidden = YES;
 self.postedToMedableImgView.hidden = NO;
 
 self.postToFacebookButton.enabled = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
 self.postToTwitterButton.enabled = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
 self.postToMedableButton.enabled = NO;
 
 NSUInteger heartbeat = 0;
 
 NSArray* body = [self.displayedPost body];
 for (NSDictionary* bodyDict in body)
 {
 NSString* segmentType = [bodyDict objectForKey:kTypeKey];
 if ([segmentType isEqualToString:kIntegerKey])
 {
 NSNumber* heartbeatNumber = [bodyDict objectForKey:kValueKey];
 heartbeat = [heartbeatNumber unsignedIntegerValue];
 }
 }
 
 self.timeStampLabel.text = [NSDateFormatter
 localizedStringFromDate:self.displayedPost.created
 dateStyle:NSDateFormatterMediumStyle
 timeStyle:NSDateFormatterShortStyle];
 
 self.captionLabel.text = self.displayedPost.text;
 
 __weak typeof (self) wSelf = self;
 
 [self.displayedPost postPicsWithUpdateBlock:^BOOL(NSString *imageId, UIImage *image, BOOL lastImage)
 {
 dispatch_async(dispatch_get_main_queue(), ^
 {
 wSelf.photoImageView.image = image;
 });
 
 return YES;
 }];
 }
*/

@end
