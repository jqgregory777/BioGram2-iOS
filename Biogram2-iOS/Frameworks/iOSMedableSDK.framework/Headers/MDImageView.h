//
//  MDImageView.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//


/*
 Checks if it's existent in disk
 If not existent the image is downloaded, encrypted and saved to disk
 Any image that's saved to disk is encrypted, decrypted images live in memory only.
 */
@interface MDImageView : UIImageView

@property (nonatomic, readonly) BOOL targetPictureSet;

- (void)setImageWithMediaOrContextId:(NSString*)mediaId
                             context:(NSString*)context
                           imageType:(NSString*)imageType
                placeholderImageName:(NSString*)placeholderImageName
                            callback:(MDFaultCallback)callback NOTNULL(1,3);

- (void)cancelImageCallback;

@end
