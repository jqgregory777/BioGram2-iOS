//
//  MDObjectsPaginationHelper.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

@protocol MDObjectsPaginationHelperObject <NSObject>
@required
- (NSString*)paginatedObjectId;
@end

@protocol MDObjectsPaginationHelperDelegate <NSObject>
@required
- (id<MDObjectsPaginationHelperObject>)lastObjectFromResults:(id)results NOTNULL(1);
@end

@interface MDObjectsPaginationHelper : NSObject

- (MDObjectsPaginationHelper*)initWithPageSize:(NSUInteger)pageSize
                                      delegate:(id<MDObjectsPaginationHelperDelegate>)delegate NOTNULL(2);

- (void)checkToLoadPaginatedObjectsWithCallback:(MDObjectCallback)callback NOTNULL(1);
- (void)checkToLoadNewObjectsWithCallback:(MDObjectCallback)callback NOTNULL(1);

- (void)synchronizeObject:(id<MDObjectsPaginationHelperObject>)object withCallback:(MDObjectCallback)callback NOTNULL(1);

- (void)resetPagination;

@end
