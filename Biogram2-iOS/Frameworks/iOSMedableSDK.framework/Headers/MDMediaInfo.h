//
//  MDMediaInfo.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import "MDObjectsPaginationHelper.h"

@interface MDMediaInfo : NSObject
<MDObjectsPaginationHelperObject>

@property (nonatomic, readonly) NSString* mediaId;
@property (nonatomic, readonly) NSString* headerSegmentId;
@property (nonatomic, readonly) NSString* mimeType;
@property (nonatomic, readonly) NSString* filename;
@property (nonatomic, readonly) NSString* label;

+ (BOOL)isImageMIMEType:(NSString*)mimeType NOTNULL(1);

- (id)initWithDictionary:(NSDictionary*)mediaDict NOTNULL(1);
- (id)initWithArray:(NSArray*)mediaInfo NOTNULL(1);
- (BOOL)allMediaDownloaded;
- (BOOL)isImageMedia;

@end