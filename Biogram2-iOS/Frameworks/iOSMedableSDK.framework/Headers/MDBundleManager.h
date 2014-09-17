//
//  MDBundleManager.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDBundle;

typedef void (^BundleLoaderCallback) (MDBundle* bundle);

@interface MDBundleManager : NSObject

+ (MDBundleManager*)sharedManager;

- (BOOL)shouldDownloadWithVersion:(NSString*)bundleVersion;
- (void)downloadBundleWithVersion:(NSString*)bundleVersion locale:(NSString*)locale callback:(BundleLoaderCallback)callback NOTNULL(1,2,3);
- (void)loadLocalBundleWithCallback:(BundleLoaderCallback)callback NOTNULL(1);

@property (nonatomic, readonly) MDBundle* localBundle;

@end
