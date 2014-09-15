//
//  MDAssetManager.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

@interface MDAssetManager : NSObject

/*
 *  Once an image is decrypted it keeps a reference to it, if somebody else asks for it
 *  the decrypted version is returned right away without going through the decryption process.
 *  Saves CPU, uses a lot of memory, because images are not freed since they are retained by the cache.
 */
@property (nonatomic, assign) BOOL useDecryptedDataMemoryCache;


+ (MDAssetManager*)sharedManager;

- (void)storeFingerprint:(NSString*)fingerprint withKey:(NSString*)encryptKey NOTNULL(1,2);

/*
 *  Returns path if the file is already downloaded, nil otherwise
 */
- (NSString*)pathForMediaId:(NSString*)mediaId
                  imageType:(NSString*)imageType NOTNULL(1,2);

- (void)decryptedImageWithFilename:(NSString*)filename
                          callback:(MDObjectCallback)callback NOTNULL(1,2);

- (void)deleteAssetWithMediaOrContextId:(NSString*)mediaOrContextId
                                context:(NSString*)context
                              imageType:(NSString*)imageType
                            finishBlock:(void (^)())finishBlock  NOTNULL(1,3);

- (void)saveImage:(UIImage*)image
 mediaOrContextId:(NSString*)mediaOrContextId
          context:(NSString*)context
        imageType:(NSString*)imageType
      finishBlock:(void (^)())finishBlock NOTNULL(1,2,4);

- (void)removeFromCachePhotosWithId:(NSArray*)photoIds;

@end
