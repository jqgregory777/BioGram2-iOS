//
//  MDInvitation.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDExpandableProperty;

@interface MDInvitation : NSObject

/**
 * The unique identifer
 */
@property (nonatomic, readonly) NSString* Id;

/**
 * The access level being granted in the invite.
 */
@property (nonatomic, readonly) MDACLLevel access;

/**
 * True when a non-Account invitation includes an account connection request
 */
@property (nonatomic, readonly) BOOL connect;

/**
 * The created datetime for the invitation
 */
@property (nonatomic, readonly) NSDate* created;

/**
 * The invitation account sender thumbnail url
 */
@property (nonatomic, readonly) NSString* image;

/**
 * Public metadata added to the invitation by some contexts.
 */
@property (nonatomic, readonly) NSDictionary* meta;

/**
 * The mobile application invitation acceptance url.
 */
@property (nonatomic, readonly) NSString* mobileURL;

/**
 * The object id that the invite will establish a collaboration connection to.
 */
@property (nonatomic, readonly) MDExpandableProperty* object;

/**
 * The recipient of the invite.
 */
@property (nonatomic, readonly) NSDictionary* recipient;

/**
 * The invitation sender
 */
@property (nonatomic, readonly) MDExpandableProperty* sender;

/**
 * The invite token.
 */
@property (nonatomic, readonly) NSString* token;

/**
 * Does the invite involve transfer of ownership (true,false).
 */
@property (nonatomic, readonly) BOOL transfer;

/**
 * The web application invitation acceptance landing page.
 */
@property (nonatomic, readonly) NSString* URL;


- (NSString*)senderId;
- (NSString*)recipientId;

@end
