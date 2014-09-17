//
//  MDMediaDownloadHelper.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

@class MDMediaInfo;

@interface MDMediaDownloadHelper : NSObject

/*
 * Searches media on disk, decrypts it and returns it or,
 * if not present or there's an decryption error, the media is downloaded again
 * and returned. It's also encrypted and saved to disk.
 *
 * For invitation thumbnails just specify 'kInvitationKey' as the context and use the invitation token as mediaOrContextId.
 */
+ (void)mediaWithMediaOrContextId:(NSString*)mediaOrContextId
                          context:(NSString*)context
                        imageType:(NSString*)imageType
                         callback:(MDImageOrFaultCallback)callback NOTNULL(1,2,3,4);



#pragma mark - Instance methods

- (void)configureMediasWithDictionary:(NSDictionary*)dictionary
                              context:(NSString*)context NOTNULL(1,2);

- (void)addMediaInfo:(MDMediaInfo*)mediaInfo
             context:(NSString*)context
notifyAvailableMedia:(BOOL)notifyAvailableMedia NOTNULL(1,2);

- (void)addMediaInfoArray:(NSArray*)mediaInfoArray
                  context:(NSString*)context
     notifyAvailableMedia:(BOOL)notifyAvailableMedia NOTNULL(1,2);

- (BOOL)hasMedia;
- (NSUInteger)mediaCount;
- (void)mediaWithUpdateBlock:(MDPicsUpdateBlock)updateBlock;
- (void)stopNotifiyingMediaUpdates;

@end
