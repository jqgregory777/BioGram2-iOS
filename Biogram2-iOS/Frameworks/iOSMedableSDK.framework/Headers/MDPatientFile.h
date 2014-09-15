//
//  MDPatientFile.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MDContextObject.h"
#import "MDObjectsPaginationHelper.h"

@interface MDPatientFile : NSObject
<MDObjectsPaginationHelperObject, MDContextObject>

/**
 * The unique identifer
 */
@property (nonatomic, readonly) NSString* Id;

/**
 * First name
 */
@property (nonatomic, readonly) NSString* firstName;

/**
 * Last name
 */
@property (nonatomic, readonly) NSString* lastName;

/**
 * The full name of the Account, generated from name.first and name.last
 */
@property (nonatomic, readonly) NSString* fullName;

/**
 * The Account id of the connected patient.
 */
@property (nonatomic, readonly) MDExpandableProperty* account;

/**
 * True when the Patient account has Connected to the Patient Record.
 */
@property (nonatomic, readonly) BOOL accountConnected;

/**
 * Patient age, derived from dob
 */
@property (nonatomic, readonly) NSUInteger age;

/**
 * The object context name
 */
@property (nonatomic, readonly) NSString* context;

/**
 * A Unix Timestamp representing the time the object was created
 */
@property (nonatomic, readonly) NSDate* created;

/**
 * The account id of the object creator
 */
@property (nonatomic, readonly) MDExpandableProperty* creator;

/**
 * A description of the Patient File. The result varies depending on the caller's access level.
 */
@property (nonatomic, readonly) NSString* patientFileDescription;

/**
 * Patient date of birth
 */
@property (nonatomic, readonly) NSDate* dob;

/**
 * A patient email address
 */
@property (nonatomic, readonly) NSString* email;

/**
 * Marks this object as a favorite of the caller.
 */
@property (nonatomic, readonly) BOOL favorite;

/**
 * Patient gender
 */
@property (nonatomic, readonly) MDGender gender;

/**
 * The object image. To update it, set the property to the name of an uploaded file.
 */
@property (nonatomic, readonly) NSDictionary* image;

/**
 * Medical Record Number
 */
@property (nonatomic, readonly) NSString* mrn;

/**
 * The Org to which this object belongs.
 */
@property (nonatomic, readonly) MDExpandableProperty* org;

/**
 * The account id of the object owner
 */
@property (nonatomic, readonly) MDExpandableProperty* owner;

/**
 * A patient contact phone number
 */
@property (nonatomic, readonly) NSString* phone;

/**
 * True if this object has explicit connections or pending invitations
 */
@property (nonatomic, readonly) BOOL shared;

/**
 * A Unix Timestamp representing the time the object was modified
 */
@property (nonatomic, readonly) NSDate* updated;


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

@property (nonatomic, assign) MDPatientFileState patientFileState;

- (NSString*)accountId;
- (void)synchronizeObjectWithCallback:(MDNoArgumentCallback)callback;

- (NSString*)ownerId;
- (NSString*)ownerName;
- (NSString*)ownerDescription;

@end
