//
//  MDAPIClient.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MDFault;
@class MDAccount;
@class MDFile;
@class MDTeam;
@class MDConversation;
@class MDPatientFile;
@class MDProfileInfo;
@class MDAPIParameters;
@class MDInvitation;
@class MDPost;
@class MDPostComment;
@class MDPostSegments;

@interface MDAPIClient : NSObject

@property (nonatomic, readonly) NSString* currentSessionId;
@property (nonatomic, readonly) NSString* currentUserEmail;
@property (nonatomic, readonly) NSString* currentPushNotificationToken;
@property (nonatomic, strong) NSString* invitationToken;

@property (nonatomic, readonly) MDAccount* localUser;

/**
 *  Returns the shared API client instance.
 */
+ (MDAPIClient*)sharedClient;

/**
 *  Stores current Apple Push Notification token.
 *  @param APN token received in UIApplicationDelegate's application:didRegisterForRemoteNotificationsWithDeviceToken:
 */
- (void)setPushNotificationToken:(NSData*)token;


#pragma mark - Account

/**
 *  Gets latest data for current logged in account
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)currentAccount:(void (^)(MDAccount* account, MDFault* fault))callback;

/**
 *  Activates an account.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)activateAccountWithToken:(NSString*)token callback:(void (^)(MDFault* fault))callback;

/**
 *  Request account verification resend.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)resendAccountVerificationWithCallback:(void (^)(MDFault* fault))callback;

/**
 *  Verifies an account.
 *  @param token Verification token
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)verifyAccountWithToken:(NSString*)token callback:(void (^)(MDFault* fault))callback;

/**
 *  Creates an account. User signup.
 *  @param firstName (required)
 *  @param lastName (required)
 *  @param email (required)
 *  @param mobile (required)
 *  @param password (required)
 *  @param role
 *  @param profileInfo
 *  @param thumbImage
 *  @param progressCallback Progress update block, only needed for when sending a thumb image. It might be used to show a progress bar.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)registerAccountWithFirstName:(NSString*)firstName
                            lastName:(NSString*)lastName
                               email:(NSString*)email
                              mobile:(NSString*)mobile
                            password:(NSString*)password
                                role:(NSString*)role
                         profileInfo:(MDProfileInfo*)profileInfo
                          thumbImage:(UIImage *)thumbImage
                    progressCallback:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressCallback
                            callback:(void (^)(NSDictionary* result, MDFault* fault))callback;


#pragma mark - Auth

/**
 *  Returns the status of a session client as a "loggedin" boolean property.
 *  If connected, the result will contain an "account" property. If there is an error, the response will contain a "fault" object.
 *  @param parameters expand[]=account can be sent.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)loginStatusWithParameters:(MDAPIParameters*)parameters
                         callback:(void (^)(MDAccount* account, MDFault* fault))callback;

/**
 *  Logout an authenticated session client.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)logout:(void (^)(MDFault* fault))callback;

/**
 *  Authenticates using email and password credentials, and returns the current account object.
 *  @param email
 *  @param password
 *  @param token
 *  @param singleUse
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)authenticateSessionWithEmail:(NSString*)email
                            password:(NSString*)password
                   verificationToken:(NSString*)token
                           singleUse:(BOOL)singleUse
                            callback:(void (^)(MDAccount* localUser, MDFault* fault))callback;

/**
 *  Requests a password reset.
 *  @param email
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)requestPasswordResetWithEmail:(NSString*)email
                             callback:(void (^)(MDFault* fault))callback;

/**
 *  Reset password.
 *  @param password
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)passwordResetWithToken:(NSString*)token
                      password:(NSString*)password
                      callback:(void (^)(MDFault* fault))callback;


#pragma mark - Collaboration

/**
 * List a context object's connections and invitations to/from the caller (optionally, withing a given context). The resulting array will consist of account objects and invitation objects.
 *  @param context (required)
 *  @param contextId (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are filterCaller, roles and expand.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listConnectionsWithContext:(NSString*)context
                         contextId:(NSString*)contextId
                        parameters:(MDAPIParameters*)parameters
                          callback:(void (^)(NSArray* invitations, NSArray* connectedAccounts, MDFault* fault))callback;

/**
 * List invitation objects.
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are from, to and expand.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listInvitationsWithParameters:(MDAPIParameters*)parameters
                             callback:(void (^)(NSArray* invitations, MDFault* fault))callback;

/**
 * List invitation objects.
 *  @param context Context for the invitations.
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are from, to and expand.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listInvitationsWithContext:(NSString*)context
                        parameters:(MDAPIParameters*)parameters
                          callback:(void (^)(NSArray* invitations, MDFault* fault))callback;
/**
 * Reject a collaboration invitation.
 *  @param token Invitation token.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)rejectInvitationWithInviteToken:(NSString*)token
                               callback:(void (^)(MDFault* fault))callback;

/**
 * Test a collaboration.
 *  @param token Collaboration token.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)testCollaborationToken:(NSString*)token
                      callback:(void (^)(MDFault* fault))callback;

/**
 * Accept a collaboration invitation.
 *  @param token Invitation token.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)acceptInvitationWithInviteToken:(NSString*)token
                               callback:(void (^)(MDFault* fault))callback;

/**
 * Sends a collaboration invitation.
 *  @param email Email address of invitee
 *  @param context Context (required)
 *  @param objectId Context Object Id. Some contexts suppport creation upon invitation. See the collaborationCreatable of each context object.
 *  @param object Some contexts suppport creation upon invitation. In those cases the new object's details are provided in this dictionary.
 *  @param inviteeFirstName A placeholder name used for the invitation when no account exists
 *  @param inviteeLastName A placeholder name used for the invitation when no account exists
 *  @param transfer If true, transfers ownership to the invitee for supported contexts
 *  @param connect If true, also requests an account connection (Implicit for account invitations).
 *  @param accessLevel The access level to grant to the invitee. See the 'shareChain' for each context.
 *  @param role Upon acceptance, the invitee assumes the specified object role. Only required for patientFile and conversation contexts.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)inviteByEmail:(NSString*)email
              context:(NSString*)context
             objectId:(NSString*)objectId
               object:(NSDictionary*)object
     inviteeFirstName:(NSString*)inviteeFirstName
      inviteeLastName:(NSString*)inviteeLastName
             transfer:(BOOL)transfer
              connect:(BOOL)connect
          accessLevel:(MDACLLevel)accessLevel
                 role:(NSString*)role
             callback:(void (^)(MDFault* fault))callback;

/**
 * Sends a collaboration invitation.
 *  @param accountId Account id of invitee
 *  @param context Context (required)
 *  @param objectId Context Object Id. Some contexts suppport creation upon invitation. See the collaborationCreatable of each context object.
 *  @param object Some contexts suppport creation upon invitation. In those cases the new object's details are provided in this dictionary.
 *  @param inviteeFirstName A placeholder name used for the invitation when no account exists
 *  @param inviteeLastName A placeholder name used for the invitation when no account exists
 *  @param transfer If true, transfers ownership to the invitee for supported contexts
 *  @param connect If true, also requests an account connection (Implicit for account invitations).
 *  @param accessLevel The access level to grant to the invitee. See the 'shareChain' for each context.
 *  @param role Upon acceptance, the invitee assumes the specified object role. Only required for patientFile and conversation contexts.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)inviteByAccountId:(NSString*)accountId
                  context:(NSString*)context
                 objectId:(NSString*)objectId
                   object:(NSDictionary*)object
         inviteeFirstName:(NSString*)inviteeFirstName
          inviteeLastName:(NSString*)inviteeLastName
                 transfer:(BOOL)transfer
                  connect:(BOOL)connect
              accessLevel:(MDACLLevel)accessLevel
                     role:(NSString*)role
                 callback:(void (^)(MDFault* fault))callback;

/**
 * Sends a collaboration invitation.
 *  @param teamId Team id of invitees
 *  @param context Context (required)
 *  @param objectId Context Object Id. Some contexts suppport creation upon invitation. See the collaborationCreatable of each context object.
 *  @param object Some contexts suppport creation upon invitation. In those cases the new object's details are provided in this dictionary.
 *  @param inviteeFirstName A placeholder name used for the invitation when no account exists
 *  @param inviteeLastName A placeholder name used for the invitation when no account exists
 *  @param transfer If true, transfers ownership to the invitee for supported contexts
 *  @param connect If true, also requests an account connection (Implicit for account invitations).
 *  @param roles When the recipient is a team, the roles array limits invitations to those members having a matching role.
 *  @param accessLevel The access level to grant to the invitee. See the 'shareChain' for each context.
 *  @param role Upon acceptance, the invitee assumes the specified object role. Only required for patientFile and conversation contexts.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)inviteByTeamId:(NSString*)teamId
               context:(NSString*)context
              objectId:(NSString*)objectId
                object:(NSDictionary*)object
      inviteeFirstName:(NSString*)inviteeFirstName
       inviteeLastName:(NSString*)inviteeLastName
              transfer:(BOOL)transfer
               connect:(BOOL)connect
           accessLevel:(MDACLLevel)accessLevel
                 roles:(NSArray*)roles
                  role:(NSString*)role
              callback:(void (^)(MDFault* fault))callback;

/**
 * Removes a collaboration.
 *  @param context Context (required)
 *  @param contextId Context Object Id (required)
 *  @param accountIdOrEmail accountId or email to remove
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)removeCollaborationWithContext:(NSString*)context
                              objectId:(NSString*)objectId
                      accountIdOrEmail:(NSString*)accountIdOrEmail
                              callback:(void (^)(MDFault* fault))callback;


#pragma mark - Feed

/**
 * Lists a context feed
 *  @param context Context (required)
 *  @param objectId Context Object Id (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are comments, profile, new, postTypes, expand, include, paths and either (limit, skip, sort) or (rangeField, rangeStart, rangeEnd, previous and ascending).
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listFeedWithContext:(NSString*)context
                   objectId:(NSString*)objectId
                 parameters:(MDAPIParameters*)parameters
                   callback:(void (^)(NSArray* feed, MDFault* fault))callback;

/**
 * Gets a feed post
 *  @param postId Post ObjectId (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are skip, limit, expand, include and paths.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)readPostWithPostId:(NSString*)postId
                parameters:(MDAPIParameters*)parameters
                  callback:(void (^)(MDPost* post, MDFault* fault))callback;

/**
 * Posts to a context's feed
 *  @param context Context (required)
 *  @param objectId Context ObjectId (required)
 *  @param postType Post type. See each context's list of supported post types and segments.
 *  @param bodySegments Create body segments with the helper methods provided in MDPostSegments class.
 *  @param targets An array of target objects. A post type that is configured to support targeting allows the poster to make the post redable only by selected accounts or roles. A target consists of a type (Acl.AccessTargets.Account, AccessTargets.Role) and a target object Id representing the roleId or accountId. Create target parameters using MDAPIParameterFactory.
 *  @param images Optional images to be added to the post
 *  @param images Optional censor overlays for the images added to the post
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)postToContext:(NSString*)context
             objectId:(NSString*)objectId
             postType:(NSString*)postType
         bodySegments:(MDPostSegments*)bodySegments
              targets:(MDAPIParameters*)targets
               images:(NSArray*)images
       censorOverlays:(NSArray*)censorOverlays
             progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
          finishBlock:(void (^)(MDPost* post, MDFault* fault))finishBlock;

/**
 * Posts a comment to a post
 *  @param postId Post ObjectId (required)
 *  @param postType Comment post type. Most context post types only support "text" comments.
 *  @param bodySegments Create body segments with the helper methods provided in MDPostSegments class.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)postCommentToPostWithId:(NSString*)postId
                       postType:(NSString*)postType
                   bodySegments:(MDPostSegments*)bodySegments
                       callback:(void (^)(MDPost* post, MDFault* fault))callback;

/**
 * Votes a post / comment
 *  @param postId Post ObjectId (required)
 *  @param commentId Optionally you could vote a comment by providing its commentId
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)voteUpPostWithId:(NSString*)postId
               commentId:(NSString*)commentId
                callback:(void (^)(MDFault* fault))callback;

/**
 * Edits an existing post
 *  @param postId Post ObjectId (required)
 *  @param commentId Optionally you could edit a comment by providing its commentId
 *  @param bodySegments Create body segments with the helper methods provided in MDPostSegments class.
 *  @param targets An array of target objects. A post type that is configured to support targeting allows the poster to make the post redable only by selected accounts or roles. A target consists of a type (Acl.AccessTargets.Account, AccessTargets.Role) and a target object Id representing the roleId or accountId. Create target parameters using MDAPIParameterFactory.
 *  @param images Optional images to be added to the post
 *  @param images Optional censor overlays for the images added to the post
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)editPostWithId:(NSString*)postId
             commentId:(NSString*)commentId
          bodySegments:(MDPostSegments*)bodySegments
               targets:(MDAPIParameters*)targets
                images:(NSArray*)images
        censorOverlays:(NSArray*)censorOverlays
              progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
           finishBlock:(void (^)(MDPost* post, MDFault* fault))finishBlock;

/**
 * Deletes an existing post
 *  @param postId Post ObjectId (required)
 *  @param commentId Optionally you could delete a comment by providing its commentId
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)deletePostWithId:(NSString*)postId
               commentId:(NSString*)commentId
                callback:(void (^)(MDFault* fault))callback;

/**
 * Un-votes a post / comment
 *  @param postId Post ObjectId (required)
 *  @param commentId Optionally you could vote a comment by providing its commentId
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)removeVoteFromPostWithId:(NSString*)postId
                       commentId:(NSString*)commentId
                        callback:(void (^)(MDFault* fault))callback;


#pragma mark - Notifications

/**
 * Lists current API notifications (not APN notifications)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are limit, skip and expand.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listNotificationsWithParameters:(MDAPIParameters*)parameters
                               callback:(void (^)(NSArray* notifications, MDFault* fault))callback;

/**
 * Clears a notification
 *  @param notificaitonId Notification ID
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)clearNotificationWithId:(NSString*)notificationId
                       callback:(void (^)(MDFault* fault))callback;

/**
 * Clears notifications by type / by context / by specific context object
 *  @param type limits the operation to a notification type
 *  @param context limits the operation to a context
 *  @param objectId limits the operation to an object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)clearNotificationsWithType:(MDNotificationType)type
                           context:(NSString*)context
                          objectId:(NSString*)objectId
                          callback:(void (^)(MDFault* fault))callback;

/**
 * Clears notifications related to feed posts
 *  @param postIds a subset of post ids to clear. If not present, all post notifications are cleared
 *  @param postTypes A list of post types to clear. If not present, notifications for all post types are cleared.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)clearFeedNotificationsWithPostIds:(NSArray*)postIds
                                postTypes:(NSArray*)postTypes
                                 callback:(void (^)(MDFault* fault))callback;


#pragma mark - Object

/**
 * List context objects
 *  @param context Context (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include, paths, either (limit, skip, sort) or (rangeField, rangeStart, rangeEnd, previous and ascending), accountRoles, search, patient, patientFile, tags, diagnoses, 'and', and search.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listObjectsWithContext:(NSString*)context
                    parameters:(MDAPIParameters*)parameters
                      callback:(void (^)(NSArray* objects, MDFault* fault))callback;

/**
 * Gets a context object
 *  @param context Context (required)
 *  @param objectId Context ObjectId (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include and paths.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)objectWithContext:(NSString*)context
                 objectId:(NSString*)objectId
               parameters:(MDAPIParameters*)parameters
                 callback:(void (^)(id object, MDFault* fault))callback;

/**
 * Updates a context object
 *  @param context Context (required)
 *  @param objectId Context ObjectId (required)
 *  @param body Object properties that are updated
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)updateObjectWithContext:(NSString*)context
                       objectId:(NSString*)objectId
                           body:(NSDictionary*)body
                       callback:(void (^)(id object, MDFault* fault))callback;

/**
 * Updates a context object's image
 *  @param context Context (required)
 *  @param objectId Context ObjectId (required)
 *  @param image Image (required)
 *  @param progress An upload progress callback block
 *  @param completionBlock Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)updateObjectImageWithContext:(NSString*)context
                            objectId:(NSString*)objectId
                               image:(UIImage*)image
                            progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                     completionBlock:(void (^)(MDFault* fault))completionBlock;


#pragma mark - Account Object

/**
 * Updates context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)updateAccountWithID:(NSString*)userID
                  firstName:(NSString*)firstName
                   lastName:(NSString*)lastName
                      email:(NSString*)email
                     mobile:(NSString*)mobile
                   password:(NSString*)password
                oldPassword:(NSString*)oldPassword
            confirmPassword:(NSString*)confirmPassword
                       role:(NSString*)role
                profileInfo:(MDProfileInfo*)profileInfo
                      image:(UIImage*)image
                   progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                finishBlock:(void (^)(MDAccount* account, MDFault* fault))finishBlock;

/**
 * Deletes context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)deleteAccountWithId:(NSString*)accountId
                     reason:(MDAPIParameters*)reason
                   callback:(void (^)(MDFault* fault))callback;


#pragma mark - File

/**
 * List context objects
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include, paths, either (limit, skip, sort) or (rangeField, rangeStart, rangeEnd, previous and ascending), accountRoles, search, patient, patientFile, tags, diagnoses, 'and', and search.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listFilesWithParameters:(MDAPIParameters*)parameters
                       callback:(void (^)(NSArray* files, MDFault* fault))callback;

/**
 * Gets a context object
 *  @param objectId Context ObjectId (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include and paths.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)fileWithId:(NSString*)fileId
        parameters:(MDAPIParameters*)parameters
          callback:(void (^)(MDFile* file, MDFault* fault))callback;

/**
 * Creates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)createFileWithValueName:(NSString*)valueName
                          value:(NSData*)value
                    description:(NSString*)description
                       favorite:(BOOL)favorite
                           tags:(NSArray*)tags
                       progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                    finishBlock:(void (^)(MDFile* file, MDFault* fault))finishBlock;

/**
 * Updates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)updateFileWithId:(NSString*)fileId
             description:(NSString*)description
                favorite:(BOOL)favorite
                    tags:(NSArray*)tags
                callback:(void (^)(MDFile* file, MDFault* fault))callback;

/**
 * Deletes a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)deleteFileWithId:(NSString*)fileId
                  reason:(MDAPIParameters*)reason
                callback:(void (^)(MDFault* fault))callback;


#pragma mark - Patient File

/**
 * List context objects
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include, paths, either (limit, skip, sort) or (rangeField, rangeStart, rangeEnd, previous and ascending), accountRoles, search, patient, patientFile, tags, diagnoses, 'and', and search.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listPatientFilesWithParameters:(MDAPIParameters*)parameters
                              callback:(void (^)(NSArray* patientFiles, MDFault* fault))callback;

/**
 * Gets a context object
 *  @param objectId Context ObjectId (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include and paths.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)patientFileWithId:(NSString*)patientFileId
               parameters:(MDAPIParameters*)parameters
                 callback:(void (^)(MDPatientFile* patientFile, MDFault* fault))callback;

/**
 * Creates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)createPatientfileWithFirstName:(NSString*)firstName
                              lastName:(NSString*)lastName
                                   dob:(NSDate*)dob
                                 email:(NSString*)email
                              favorite:(BOOL)favorite
                                gender:(MDGender)gender
                                   mrn:(NSString*)mrn
                                 phone:(NSString*)phone
                                 image:(UIImage*)image
                              progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                           finishBlock:(void (^)(MDPatientFile* patientFile, MDFault* fault))finishBlock;

/**
 * Updates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)updatePatientFileWithId:(NSString*)patientFileId
                      firstName:(NSString*)firstName
                       lastName:(NSString*)lastName
                            dob:(NSDate*)dob
                          email:(NSString*)email
                       favorite:(BOOL)favorite
                         gender:(MDGender)gender
                            mrn:(NSString*)mrn
                          phone:(NSString*)phone
                          image:(UIImage*)image
                       progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                    finishBlock:(void (^)(MDPatientFile* patientFile, MDFault* fault))finishBlock;

/**
 * Deletes a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)deletePatientfileWithId:(NSString*)patientFileId
                         reason:(MDAPIParameters*)reason
                       callback:(void (^)(MDFault* fault))callback;


#pragma mark - Conversation

/**
 * List context objects
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include, paths, either (limit, skip, sort) or (rangeField, rangeStart, rangeEnd, previous and ascending), accountRoles, search, patient, patientFile, tags, diagnoses, 'and', and search.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listConversationsWithParameters:(MDAPIParameters*)parameters
                               callback:(void (^)(NSArray* conversations, MDFault* fault))callback;

/**
 * Gets a context object
 *  @param objectId Context ObjectId (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include and paths.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)conversationWithId:(NSString*)conversationId
                parameters:(MDAPIParameters*)parameters
                  callback:(void (^)(MDConversation* conversation, MDFault* fault))callback;

/**
 * Creates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)createConversationWithDescription:(NSString*)description
                              patientFile:(MDPatientFile*)patientFile
                                   images:(NSArray*)images
                           censorOverlays:(NSArray*)censorOverlays
                             bodySegments:(MDPostSegments*)bodySegments
                                 progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                              finishBlock:(void (^)(MDConversation* conversation, MDFault* fault))finishBlock;

/**
 * Updates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)updateConversationWithId:(NSString*)conversationId
                     description:(NSString*)description
                     patientFile:(MDPatientFile*)patientFile
                        favorite:(BOOL)favorite
                  censorOverlays:(NSArray*)censorOverlays
                          images:(NSArray*)images
                    bodySegments:(MDPostSegments*)bodySegments
                        progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                     finishBlock:(void (^)(MDConversation* conversation, MDFault* fault))finishBlock;

/**
 * Deletes a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)deleteConversationWithId:(NSString*)conversationId
                          reason:(MDAPIParameters*)reason
                        callback:(void (^)(MDFault* fault))callback;


#pragma mark - Team

/**
 * List context objects
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include, paths, either (limit, skip, sort) or (rangeField, rangeStart, rangeEnd, previous and ascending), accountRoles, search, patient, patientFile, tags, diagnoses, 'and', and search.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)listTeamsWithParameters:(MDAPIParameters*)parameters
                       callback:(void (^)(NSArray* teams, MDFault* fault))callback;

/**
 * Gets a context object
 *  @param objectId Context ObjectId (required)
 *  @param parameters Construct parameters using MDAPIParameterFactory. Available parameters in this service are accessLevel, expand, include and paths.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)teamWithId:(NSString*)teamId
        parameters:(MDAPIParameters*)parameters
          callback:(void (^)(MDTeam* team, MDFault* fault))callback;

/**
 * Creates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)createTeamWithName:(NSString*)name
                  favorite:(BOOL)favorite
                     image:(UIImage*)image
                  progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
               finishBlock:(void (^)(MDTeam* team, MDFault* fault))finishBlock;

/**
 * Updates a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)updateTeamWithId:(NSString*)teamId
                    name:(NSString*)name
                favorite:(BOOL)favorite
                   image:(UIImage*)image
                progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
             finishBlock:(void (^)(MDTeam* team, MDFault* fault))finishBlock;

/**
 * Deletes a context object
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)deleteTeamWithId:(NSString*)teamId
                  reason:(MDAPIParameters*)reason
                callback:(void (^)(MDFault* fault))callback;


#pragma mark - Stream

/**
 * Stream property
 *  @param context Context (required)
 *  @param objectId Context ObjectId (required)
 *  @param propertyName Name of the property to be streamed (required)
 *  @param segmentId Segment Id. Not required, but can be used if known, as a cache buster and as a filter.
 *  @param base64 If set, base64 encodes the return stream. Useful for XMLHttpRequests in browsers lacking Blob support.
 *  @param label If true, selects a media label
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)streamPropertyWithContext:(NSString*)context
                         objectId:(NSString*)objectId
                     propertyName:(NSString*)propertyName
                        segmentId:(NSString*)segmentId
                           base64:(BOOL)base64
                            label:(NSString*)label
                         callback:(void (^)(id streamData, MDFault* fault))callback;

/**
 * Stream feed media
 *  @param segmentId Media segmentId (required)
 *  @param label Media label. If omitted, the default is streamed. See the media segment documentation regarding defaults.
 *  @param base64 If set, base64 encodes the return stream. Useful for XMLHttpRequests in browsers lacking Blob support.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)streamFeedMediaWithSegmentId:(NSString*)segmentId
                               label:(NSString*)label
                              base64:(BOOL)base64
                            callback:(void (^)(id streamData, MDFault* fault))callback;

/**
 * Stream invitation thumbnail
 *  @param token Invitation token (required)
 *  @param base64 If set, base64 encodes the return stream. Useful for XMLHttpRequests in browsers lacking Blob support.
 *  @param callback Callback block called when the service call finishes. Check MDFault for errors.
 */
- (void)streamInvitationThumbnailWithToken:(NSString*)token
                                    base64:(BOOL)base64
                                  callback:(void (^)(id streamData, MDFault* fault))callback;


#pragma mark - Media

- (NSURLRequest*)mediaRequestWithMediaId:(NSString*)mediaId
                               imageType:(NSString *)type;

- (NSURLRequest*)thumbRequestWithContext:(NSString*)context
                               contextId:(NSString*)contextId;

- (void)uploadImages:(NSArray*)images
    censoredOverlays:(NSArray*)censoredOverlays
             context:(NSString*)context
           contextId:(NSString*)contextId
        bodySegments:(MDPostSegments*)bodySegments
            progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
     completionBlock:(void (^)(MDFault* fault))completionblock;


#pragma mark - Bundle

/**
 *  Gets the last bundle version.
 */
- (void)getLastBundleVersionWithResponse:(void (^)(NSString* version, NSString* locale, NSError* error))response;

/**
 *  Gets a bundle.
 */
- (void)getBundleWithUrl:(NSString*)bundleUrl
                response:(void (^)(NSDictionary* response, NSError* error))response;


#pragma mark - Legal acceptance

/**
 *  Accepts a legal agreement.
 */
- (void)acceptLegalAgreement:(NSString*)agreement
                     version:(NSString*)version
                   accountId:(NSString*)accountId
                    callback:(void (^)(MDFault* fault))callback;


#pragma mark - Biogram

/**
 *  Biogram Object -
 *  Rename/Set Biogram object.
 *  Changes public/private object visibility.
 */
- (void)updateBiogramObjectWithId:(NSString*)biogramId
                             name:(NSString*)name
                   objectIsPublic:(BOOL)objectIsPublic
                         callback:(void (^)(id object, MDFault* fault))callback;

/**
 *  Biogram Feed
 *  Lists Biogram feed
 */
- (void)listFeedWithBiogramId:(NSString*)biogramId
                   parameters:(MDAPIParameters*)parameters
                     callback:(void (^)(NSArray* feed, MDFault* fault))callback;

/**
 *  Biogram Feed
 *  Post a heartbeat with optional image and overlay
 */
- (void)postHeartbeatWithBiogramId:(NSString*)biogramObjectId
                         heartbeat:(NSUInteger)heartbeat
                             image:(UIImage*)image
                           overlay:(UIImage*)overlay
                          progress:(void (^)(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite))progressBlock
                       finishBlock:(void (^)(MDPost* post, MDFault* fault))finishBlock;

/**
 *  Biogram objects
 *  Gets a paginated list of public biogram objects
 */
- (void)listPublicBiogramObjectsWithParameters:(MDAPIParameters*)parameters
                                      callback:(void (^)(NSArray* objects, MDFault* fault))callback;

@end
