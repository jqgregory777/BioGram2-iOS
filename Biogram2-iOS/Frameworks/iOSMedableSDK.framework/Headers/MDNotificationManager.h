//
//  MDNotificationManager.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import "MDNotification.h"

@interface MDNotificationManager : NSObject

+ (MDNotificationManager*)sharedManager;

- (void)loadNotificationsWithArray:(NSArray*)notifications NOTNULL(1);

- (BOOL)addNotification:(MDNotification*)notification NOTNULL(1);
- (void)removeNotification:(MDNotification*)notification NOTNULL(1);

- (MDNotification*)notificationWithId:(NSString*)notificationId NOTNULL(1);
- (NSSet*)notificationsWithType:(MDNotificationType)type
                        context:(MDNotificationContext)context
                      contextId:(NSString*)contextId
        optionalMetadataFilters:(NSDictionary*)optionalMetadataFilters;

- (NSArray*)currentNotifications;

- (void)synchNotificationsWithServer;   // try not to call it for networking performance

@end
