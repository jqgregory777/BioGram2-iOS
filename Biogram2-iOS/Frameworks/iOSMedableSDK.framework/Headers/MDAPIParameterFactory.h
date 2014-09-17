//
//  MDAPIParameterFactory.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MDAPIPathFactory : NSObject

+ (NSString*)pathStringWithComponents:(NSArray*)pathComponents;

@end

@interface MDAPIParameters : NSObject

- (void)addParametersWithParameters:(MDAPIParameters*)parameters;
- (void)addParametersWithDictionary:(NSDictionary*)parameters;

@end


@interface MDAPIParameterFactory : NSObject

/*
 For combining parameters into one
 */
+ (MDAPIParameters*)parametersWithParameters:(MDAPIParameters*)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/*
 For adding custom parameters
 */
+ (MDAPIParameters*)parametersWithCustomParameters:(NSDictionary*)customParameters;

/*
 Filter by minimum access level.
 */
+ (MDAPIParameters*)parametersWithMinimunAccessLevel:(MDACLLevel)accessLevel;

/*
 Creates an expand=true parameter.
 */
+ (MDAPIParameters*)parametersWithExpand;

/*
 A list of paths to expand from referenced ids. See each context object for expandable properties.
 Items are expanded with the caller's access level (Public access is granted).
 */
+ (MDAPIParameters*)parametersWithExpandPaths:(NSArray*)paths;

/*
 A list of optional paths to include. See each context object for optional properties.
 */
+ (MDAPIParameters*)parametersWithIncludePaths:(NSArray*)paths;

/*
 Limits the result to the specified paths.
 */
+ (MDAPIParameters*)parametersWithLimitPaths:(NSArray*)paths;

/*
 Limit the number of results.
 */
+ (MDAPIParameters*)parametersWithLimitResultsTo:(NSUInteger)count;

/*
 The number of items to skip. See "Skip&Sort vs Ranged Paging".
 */
+ (MDAPIParameters*)parametersWithSkipItemsCount:(NSUInteger)count;

/*
 A comma-delimited list of fields on which to sort.
 */
+ (MDAPIParameters*)parametersWithSortBy:(NSArray*)fields;

/*
 rangeField: The field on which to sort for a ranged list. See each context's sortable properties. See "Skip&Sort vs Ranged Paging".
 rangeStart: The starting point of a ranged page. The rangeStart item is not included in the results.
 rangeEnd: The last item in a rangedQuery. Limit still applies. The rangeEnd item is included i the results.
 previous: For ranged paging, returns the previous page.
 ascending: For ranged paging, returns the results in ascending order. Since the default rangeField is _id and the convention is to return the latest values first, the default is false.
 */
+ (MDAPIParameters*)parametersWithRangeFieldName:(NSString*)rangeField
                                      rangeStart:(NSString*)start
                                        rangeEnd:(NSString*)end
                                        previous:(BOOL)previous
                                       ascending:(BOOL)ascending;

/*
 Filters the list by the caller's role in the Patient File.
 */
+ (MDAPIParameters*)parametersWithFilterByCallerRole:(NSString*)role;

/*
 A list of account roles by which to filter the list.
 */
+ (MDAPIParameters*)parametersWithFilterByAccountRoles:(NSArray*)roles;

/*
 Search filter.
 */
+ (MDAPIParameters*)parametersWithSearch:(NSString*)search;

/*
 Patient name search filter
 */
+ (MDAPIParameters*)parametersWithPatientNameSearch:(NSString*)search;

/*
 Filters the results to match the list of Patient file Ids.
 */
+ (MDAPIParameters*)parametersWithFilterPatientFilesWithIDs:(NSArray*)patientFilesIDs;

/*
 Filter the results by an array of tags.
 */
+ (MDAPIParameters*)parametersWithFilterByTags:(NSArray*)tags;

/*
 Filter the results by an array of diagnoses.
 */
+ (MDAPIParameters*)parametersWithFilterByDiagnoses:(NSArray*)diagnoses;

/*
 Filter diagnoses with search text.
 */
+ (MDAPIParameters*)parametersWithFilterByDiagnosesWithSearch:(NSString*)search;

/*
 Delete object reason.
 */
+ (MDAPIParameters*)parametersWithDeleteObjectReason:(NSString*)reason;

/*
 Hide sent / received invitations
 */
+ (MDAPIParameters*)parametersWithHideSentInvitations:(BOOL)hideSentInvitations
                              hideReceivedInvitations:(BOOL)hideReceivedInvitations;

/*
 Set to true to filter the caller from the list
 */
+ (MDAPIParameters*)parametersWithFilterCaller:(BOOL)filterCaller;

/*
 A comma-delimited list of post types to include/exclude.
 */
+ (MDAPIParameters*)parametersWithIncludePostTypes:(NSArray*)includePostTypes
                                  excludePostTypes:(NSArray*)excludePostTypes;

/*
 Include comments
 */
+ (MDAPIParameters*)parametersWithIncludeComments;

/*
 Results in a profile view for supported contexts.
 */
+ (MDAPIParameters*)parametersWithProfile;

/*
 Only posts unread by the caller are returned.
 */
+ (MDAPIParameters*)parametersWithNewObjectsOnly;

/*
 Target objects. A post type that is configured to support targeting allows the poster to make the post redable only by selected accounts or roles.
 */
+ (MDAPIParameters*)parametersWithTargetAccountId:(NSString*)accountId;

/*
 Target objects. A post type that is configured to support targeting allows the poster to make the post redable only by selected accounts or roles.
 */
+ (MDAPIParameters*)parametersWithTargetRole:(MDAccountRole)role;

/*
    favorites=0/1
 */
+ (MDAPIParameters*)parametersWithFavorites:(BOOL)favorites;

/*
    hasPatient=0/1
 */
+ (MDAPIParameters*)parametersWithHasPatient:(BOOL)hasPatient;

/*
    contexts[]=
 */
+ (MDAPIParameters*)parametersWithContexts:(NSArray*)contexts;

@end

