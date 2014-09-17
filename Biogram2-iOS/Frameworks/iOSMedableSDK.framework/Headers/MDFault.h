//
//  MDFault.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDFault : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* code;
@property (nonatomic, readonly) NSString* text;

@end
