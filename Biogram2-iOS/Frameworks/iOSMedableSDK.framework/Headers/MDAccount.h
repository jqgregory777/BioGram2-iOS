//
//  MDAccount.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MDContextObject.h"

@interface MDAccount : NSObject
<MDContextObject>

/**
 * The unique identifer
 */
@property (nonatomic, readonly) NSString* Id;

/**
 * First Name
 */
@property (nonatomic, readonly) NSString* firstName;

/**
 * Last Name
 */
@property (nonatomic, readonly) NSString* lastName;

/**
 * The full name of the Account, generated from name.first and name.last
 */
@property (nonatomic, readonly) NSString* fullName;

/**
 * Account role
 */
@property (nonatomic, readonly) NSString* role;

/**
 * Gender
 */
@property (nonatomic, readonly) MDGender gender;

/**
 * Email
 */
@property (nonatomic, readonly) NSString* email;

/**
 * Description of account used for public listing. (e.g. "Male, Age 36" instead of "John Smith")
 */
@property (nonatomic, readonly) NSString* accountDescription;

/**
 * Mobile
 */
@property (nonatomic, readonly) NSString* mobile;

/**
 * Account activation required (true,false) -- depends on org settings.
 */
@property (nonatomic, readonly) BOOL activationRequired;

/**
 * An integer representing the access held by the account on the object in context. This property is set in the results or Object.connections and the GET /collaboration/:context/:objectId route
 */
@property (nonatomic, readonly) MDACLLevel connectionAccess;

/**
 * Account creation date
 */
@property (nonatomic, readonly) NSDate* created;

/**
 * Account last modification date
 */
@property (nonatomic, readonly) NSDate* updated;

/**
 * Marks this object as a favorite of the caller.
 */
@property (nonatomic, readonly) BOOL favorite;

/**
 * The object image. To update it, set the property to the name of an uploaded file.
 */
@property (nonatomic, readonly) NSArray* image;

/**
 * The Org to which this object belongs.
 */
@property (nonatomic, readonly) MDExpandableProperty* org;

/**
 * True if this object has explicit connections or pending invitations
 */
@property (nonatomic, readonly) BOOL shared;

/**
 * List of teams that the Account belongs to.
 */
@property (nonatomic, readonly) NSArray* teams;

/**
 * The object context name
 */
@property (nonatomic, readonly) NSString* context;


#pragma mark - Provider only
/**
 * Institutional affiliation of the provider.
 */
@property (nonatomic, readonly) NSString* affiliation;

/**
 * National Provider Identifier number
 */
@property (nonatomic, readonly) NSString* npi;

/**
 * State of provider verification (e.g. unverified, processing, verified, revoked)
 */
@property (nonatomic, readonly) NSString* state;

/**
 * State/province where provider is licensed to practice
 */
@property (nonatomic, readonly) NSString* licenseState;

/**
 * State/province license number
 */
@property (nonatomic, readonly) NSString* licenseNumber;

/**
 * Specialty of provider
 */
@property (nonatomic, readonly) NSString* specialty;


#pragma mark - Patient only
/**
 * Patient date of birth
 */
@property (nonatomic, readonly) NSString* dob;

// Local user only
/**
 * A dictionary with preferences like 'notifications' and 'visibility.provider' (Setting to allow provider profiles to be publicly visible to providers.) or 'visibility.patient' (Setting to allow provider profiles to be publicly visible to patients.).
 */
@property (nonatomic, readonly) NSDictionary* preferences;

/**
 * Current state for the account. (e.g. unverified, verified)
 */
@property (nonatomic, readonly) MDAccountState accountState;


#pragma mark - Additional
/*
    The followwing properties are returned only when passed in the "include" query parameter, 
    e.g. ?include[]=connections&include[]=invitations.
 */

/**
 * The access level held by the calling account. Though optional, this property will sometimes be included when not requested.
 */
@property (nonatomic, readonly) MDACLLevel access;

/**
 * A list of accounts that have at least Connected access to the object. Returned as a list of Account objects when reading a single object, an an array of ObjectIds when reading a list of objects.
 */
@property (nonatomic, readonly) NSArray* connections;

/**
 * The object feed. This allows a single call to get both an object and it's first page of posts. Feed query arguments are supported.
 */
@property (nonatomic, readonly) NSArray* feed;

/**
 * A list of Invitations sent by the caller for this object.
 */
@property (nonatomic, readonly) NSArray* invitations;

/**
 * An object keyed by post type, with an integer value representing the number of unread posts.
 */
@property (nonatomic, readonly) NSDictionary* updates;


/**
 * The Biogram property to which this account is attached.
 */
@property (nonatomic, readonly) MDExpandableProperty* biogram;
- (NSString*)biogramId;

- (BOOL)hasAccountRole:(MDAccountRole)role; // bitmask with MDAccountRole s



- (BOOL)isConnectedWithId:(NSString*)accountId NOTNULL(1);
- (BOOL)sentInviteToId:(NSString*)Id NOTNULL(1);

- (void)synchronizeObjectWithCallback:(MDNoArgumentCallback)callback;

@end
