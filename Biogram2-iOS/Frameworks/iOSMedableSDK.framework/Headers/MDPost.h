//
//  MDPost.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDContextObject.h"

@interface MDPostSegments : NSObject

/**
 *  Creates post segments
 */
+ (MDPostSegments*)postSegmentsWithText:(NSString*)text
                        imageAndOverlay:(NSDictionary*)imageAndOverlay
                              diagnoses:(NSArray*)diagnoses;

+ (MDPostSegments*)postSegmentsWithHeartbeat:(NSUInteger)heartbeat;

/**
 *  Creates post segments
 *	filesAndOverlays is a NSDictionary with:
 *      'key': filename / file upload name
 *      'object': overlay / overlay uplaod name
 *	Note: if no overlay set 'object': kEmptyString
 *	i.e.
 *	NSDictionary* filesAndOverlays = @{ @"fileUpload1", kEmptyString,
 *	                                    @"fileUpload2", @"fileUpload2Overlay" };
 */
+ (MDPostSegments*)postSegmentsWithFilesAndOverlays:(NSOrderedDictionary*)filesAndOverlays NOTNULL(1);

+ (MDPostSegments*)postSegmentsWithPostSegments:(MDPostSegments*)firstObject, ...;


/**
 *  Return all the file names that where configured by filesAndOverlays parameter
 */
- (NSArray*)files;

/**
 *  Checks if the file has an overlay and returns its name or nil if it doesn't have.
 */
- (NSString*)overlayForFile:(NSString*)file NOTNULL(1);

/**
 *  Serializes the object to the format the API expects.
 */
- (NSArray*)apiFormat;

@end


@interface MDPost : NSObject
<MDContextObject>

/**
 * The unique identifer
 */
@property (nonatomic, readonly) NSString* Id;

/**
 * Comments are messages that users can generate and are associated to a post.
 */
@property (nonatomic, readonly) NSArray* comments;

/**
 * A list of post/comment tags
 */
@property (nonatomic, readonly) NSArray* tags;

/**
 * Body Segments
 */
@property (nonatomic, readonly) NSArray* body;

/**
 * The object context that the post is associated with
 */
@property (nonatomic, readonly) NSString* context;

/**
 * The created datetime for the post
 */
@property (nonatomic, readonly) NSDate* created;

/**
 * The account that created the post
 */
@property (nonatomic, readonly) MDExpandableProperty* creator;

/**
 * The object that the post is associated with.
 */
@property (nonatomic, readonly) MDExpandableProperty* object;

/**
 * The sequence of the post
 */
@property (nonatomic, readonly) NSUInteger sequence;

/**
 * The type of post being created (e.g. "post", "attachment"). The type determines how the post is handled depending on the object being posted to.
 */
@property (nonatomic, readonly) NSString* type;

/**
 * The updated Unix timestamp for the post when edited
 */
@property (nonatomic, readonly) NSDate* updated;

/**
 * Has the current user voted on the post (true,false).
 */
@property (nonatomic, readonly) BOOL voted;

/**
 * Number of up votes on a post
 */
@property (nonatomic, readonly) NSUInteger votes;

// ---
/**
 * 'text' segment from body segments
 */
@property (nonatomic, strong) NSString* text;
@property (nonatomic, readonly) MDPostType typeEnumerated;
@property (nonatomic, readonly) NSArray* diagnoses;


+ (MDPost*)initialPostWithConversation:(MDConversation*)conversation NOTNULL(1);

- (void)postPicsWithUpdateBlock:(MDPicsUpdateBlock)updateBlock NOTNULL(1);
- (void)stopNotifiyingPhotoUpdates; // this won't stop queued downloads
- (NSUInteger)picsCount;
- (BOOL)hasPics;

- (NSArray*)postNonImages;

- (void)synchronizeObjectWithCallback:(MDNoArgumentCallback)callback NOTNULL(1);
- (NSString*)creatorId;

- (BOOL)hasDiagnoses;

@end


@interface MDPostComment : NSObject

/**
 * The unique identifer
 */
@property (nonatomic, readonly) NSString* Id;

/**
 * The account that created the comment
 */
@property (nonatomic, readonly) MDExpandableProperty* creator;

/**
 * The created datetime for the comment
 */
@property (nonatomic, readonly) NSDate* created;

/**
 * The type of comment being created (e.g. "text").
 */
@property (nonatomic, readonly) NSString* type;

/**
 * Body Segments
 */
@property (nonatomic, readonly) NSArray* body;

/**
 * Number of up votes on a comment
 */
@property (nonatomic, readonly) NSUInteger votes;

/**
 * Has the current user voted on the comment
 */
@property (nonatomic, readonly) BOOL voted;

/**
 * 'text' segment from body segments
 */
@property (nonatomic, readonly) NSString* text;

/**
 * Reference to parent post
 */
@property (nonatomic, readonly) MDPost* parentPost;

- (NSString*)creatorId;

@end
