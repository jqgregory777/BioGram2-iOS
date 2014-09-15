//
//  MDNotification.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDNotification : NSObject

/**
 * The unique identifer
 */
@property (nonatomic, readonly) NSString* Id;

/**
 * The account id to which the notification belongs.
 */
@property (nonatomic, readonly) id account;

/**
 * Type-specific metadata
 */
@property (nonatomic, readonly) NSDictionary* metadata;

/**
 * The context of the notification
 */
@property (nonatomic, readonly) MDNotificationContext context;

/**
 * The object for which the notification was generated
 */
@property (nonatomic, readonly) id object;

/**
 * The org in which the notification was generated
 */
@property (nonatomic, readonly) id org;

/**
 * The notification timestamp, accurate to the millisecond.
 */
@property (nonatomic, readonly) NSDate* timestamp;

/**
 * The notification code
 */
@property (nonatomic, readonly) MDNotificationType type;


- (MDNotification*)initWithAttributes:(NSDictionary*)attributes NOTNULL(1);

@end
