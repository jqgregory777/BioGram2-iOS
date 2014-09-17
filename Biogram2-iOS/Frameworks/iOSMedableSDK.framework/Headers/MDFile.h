//
//  MDFile.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MDContextObjectPaginationHelper.h"

@interface MDFile : NSObject
<MDObjectsPaginationHelperObject>

/**
 * The unique identifer
 */
@property (nonatomic, readonly) NSString* Id;

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
 * File name
 */
@property (nonatomic, readonly) NSString* fileDescription;

@property (nonatomic, readonly) NSDictionary* diagnoses;

/**
 * Marks this object as a favorite of the caller.
 */
@property (nonatomic, readonly) BOOL favorite;

/**
 * Original post object. Exists for generated files.
 */
@property (nonatomic, readonly) MDExpandableProperty* object;

/**
 * The Org to which this object belongs.
 */
@property (nonatomic, readonly) MDExpandableProperty* org;

/**
 * The account id of the object owner
 */
@property (nonatomic, readonly) MDExpandableProperty* owner;

@property (nonatomic, readonly) MDExpandableProperty* patientFile;

/**
 * Original post. Exists for files generated from posts.
 */
@property (nonatomic, readonly) MDExpandableProperty* post;

/**
 * origin post sequence
 */
@property (nonatomic, readonly) NSUInteger postSeq;

/**
 * True if this object has explicit connections or pending invitations
 */
@property (nonatomic, readonly) BOOL shared;

@property (nonatomic, readonly) NSArray* tags;

/**
 * A Unix Timestamp representing the time the object was modified
 */
@property (nonatomic, readonly) NSDate* updated;

/**
 * The file stream access URLs. (one URL per label)
 */
@property (nonatomic, readonly) NSDictionary* value;


#pragma mark - Additional

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


// --

@property (nonatomic, readonly) MDMediaInfo* mediaInfo;

@end
