//
//  MDEnvironment.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDEnvironment : NSObject

+ (MDEnvironment*)environment;

- (NSString*)APIbaseURL;
- (NSString*)APIURL;
- (NSString*)appAPIKey;

@end
