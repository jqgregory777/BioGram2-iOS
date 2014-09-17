//
//  MDACLDefines.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDACLDefines : NSObject

// acl access level
+ (NSUInteger)aclLevelPublic;
+ (NSUInteger)aclLevelConnected;
+ (NSUInteger)aclLevelEmbed;
+ (NSUInteger)aclLevelRead;
+ (NSUInteger)aclLevelShare;
+ (NSUInteger)aclLevelUpdate;
+ (NSUInteger)aclLevelDelete;
+ (NSUInteger)aclLevelAdmin;

// acl access target
+ (NSUInteger)aclAccessTargetAccount;
+ (NSUInteger)aclAccessTargetTeam;
+ (NSUInteger)aclAccessTargetRole;

// acl org provider role
+ (NSString*)aclRoleBaseOrg;
+ (NSString*)aclRoleSystemAdmin;
+ (NSString*)aclRoleOrgAdmin;
+ (NSString*)aclRoleProvider;
+ (NSString*)aclRolePatient;

+ (MDAccountRole)accountRoleFromString:(NSString*)roleString NOTNULL(1);
+ (NSString*)roleStringFromRole:(MDAccountRole)role;

@end
