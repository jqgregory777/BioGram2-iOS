//
//  CBCHeartRateFeed.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/18/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBCHeartRateEvent.h"

typedef enum : NSInteger
{
    CBCFeedNone = -1,
    CBCFeedPrivate = 0,
    CBCFeedPublic,
    CBCFeedCollective,
    CBCFeedLocal // used only in trial mode
} CBCFeedType;

extern NSString* const kCBCWillSwitchFeed;
extern NSString* const kCBCDidSwitchFeed;

// ----------------------------------------------------------------------------------------------------------------------------
// Abstract class for any type of feed (a local Core Data feed, or a Medable feed)
// ----------------------------------------------------------------------------------------------------------------------------

#pragma mark - CBCFeed

@interface CBCFeed : NSObject

@property (readonly) CBCFeedType type;
@property (readonly, strong, nonatomic) NSFetchedResultsController * fetchedResultsController;

- (CBCFeed *)initWithType:(CBCFeedType)type;
- (void)dealloc;
- (BOOL)saveHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent;
- (BOOL)updateHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent;
- (void)deleteHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent;
- (void)deleteHeartRateEvents:(NSArray *)events;
- (NSArray *)fetchAllHeartRateEvents;

+ (NSString *)typeAsString:(CBCFeedType)type;

#pragma mark - Heart Rate Event Creation

@property (strong, nonatomic) CBCHeartRateEvent * pendingHeartRateEvent;
@property UIImage * pendingRawImage;

- (CBCHeartRateEvent *)createPendingHeartRateEvent;
- (void)cancelPendingHeartRateEvent;
- (BOOL)savePendingHeartRateEvent;

@end

// ----------------------------------------------------------------------------------------------------------------------------

#pragma mark - CBCFeedManager

@interface CBCFeedManager : NSObject

#pragma mark - General

+ (CBCFeedManager *)singleton;

@property (readonly, strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly, strong, nonatomic) CBCFeed * currentFeed;

// Call this function to switch feeds. It is called whenever (a) the "filter" segmented
// control is touched by the user, and (b) whenever the user logs in or out of Medable
// (which takes us from public/private/collective to local and vice-versa).
- (CBCFeed *)switchToFeed:(CBCFeedType)type;

+ (NSURL *)applicationDocumentsDirectory;

@end
