//
//  MDContentDownloader.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kContentDownloadedDidStartDownloads;
extern NSString* const kContentDownloadedDidFinishDownloads;


@interface MDContentDownloader : NSObject

- (id)initWithCallback:(MDNoArgumentCallback)callback NOTNULL(1);
- (void)checkForDownloads;

@end
