//
//  MDTypedefs.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#pragma mark - Gender

typedef enum : NSUInteger
{
    MDGenderUnspecified = 0,
    MDGenderMale,
    MDGenderFemale
} MDGender;

#pragma mark - Account state

typedef enum : NSUInteger
{
    MDAccountStateUnverified,
    MDAccountStateProcessing,
    MDAccountStateVerified
} MDAccountState;


#pragma mark - ACL typedefs
/*
 AccessLevels:
 Public: 1,              // can scan a minimum of public object details (ie. thumbnail image, name. eg. members on the same team)
 Connected: 2,           // can read non-private object details (ie. 'colleagues' get this access level)
 Embed: 3,               // can add this access target to a context requiring invitations.
 Read: 4,                // can read all object details
 Share: 5,               // can share/invite others to the object context (eg. update colleagues) promote/demote access at this level or lower.
 Update: 6,              // can update the object properties (base and accessible profiles)
 Delete: 7,              // can delete the object
 Admin: 8                // can administer the object (assign org roles and edit acl entries)
 */

typedef enum : NSInteger
{
    MDACLLevelNotSet = -1,
    MDACLLevelPublic = 1,
    MDACLLevelConnected = 2,
    MDACLLevelEmbed = 3,
    MDACLLevelRead = 4,
    MDACLLevelShare = 5,
    MDACLLevelUpdate = 6,
    MDACLLevelDelete = 7,
    MDACLLevelAdmin = 8
} MDACLLevel;

inline static bool isAccessLevel(MDACLLevel level)
{
    bool retVal = ((level > MDACLLevelNotSet) &&
                   (level <= MDACLLevelAdmin));
    
    return retVal;
}

typedef enum : NSUInteger
{
    MDACLAccessTargetAccount = 1,
    MDACLAccessTargetTeam = 2,
    MDACLAccessTargetRole = 3
} MDACLAccessTarget;

typedef enum : NSInteger
{
    MDAccountRoleNotDefined = -1,
    MDAccountRoleBaseOrg = 0,
    MDAccountRoleSystemAdmin = 1,
    MDAccountRoleOrgAdmin = 2,
    MDAccountRoleOrgProvider = 3,
    MDAccountRoleOrgPatient = 4,
    MDAccountRoleDeveloper = 5
} MDAccountRole;

inline static bool isAccountRole(MDAccountRole role)
{
    bool retVal = ((role > MDAccountRoleNotDefined) &&
                   (role <= MDAccountRoleDeveloper));
    
    return retVal;
}

#pragma mark - MDNotifications

typedef enum : NSInteger
{
    MDNotificationTypeNotSpecified = -1,
    MDNotificationTypeFeedUpdate = 1,
    MDNotificationTypeInvitation = 2,
    MDNotificationTypeOwnershipTransfer = 3
} MDNotificationType;

typedef enum : NSUInteger
{
    MDNotificationContextColleague,
    MDNotificationContextConversation,
    MDNotificationContextTeam,
    MDNotificationContextOrg,
    MDNotificationContextPatient,
} MDNotificationContext;


#pragma mark - MDPostTypes

typedef enum : NSUInteger
{
    MDPostTypePost = 0,
    MDPostTypeDiagnosis,
    MDPostTypeTreatment,
    MDPostTypeComment,
    MDPostTypeAlbum,
    MDPostTypeInitialComment,
    MDPostTypeAttachment,
    MDPostTypeHeartrate
} MDPostType;


#pragma mark - MDProfileInfo

typedef enum : NSUInteger
{
    MDProfileInfoTypeProvider,
    MDProfileInfoTypePatient
} MDProfileInfoType;


#pragma mark - MDPatientFile

typedef enum : NSInteger
{
    MDPatientFileStateNotSet = -1,
    MDPatientFileStateToInvite,
    MDPatientFileStateInvited,
    MDPatientFileStateJoined
} MDPatientFileState;


#pragma mark - Image size

typedef enum ResizedImageEnum
{
	kNoResize = 0,
	kThumbSize,
	kGallerySize
} ResizedImageEnum;
