//
//  MDDefines.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#ifndef iOSMedableSDK_MDDefines_h
#define iOSMedableSDK_MDDefines_h


#ifdef INFO_PLIST
#define STRINGIFY(_x)        _x
#else
#define STRINGIFY(_x)      # _x
#endif

#define STRX(x)			x

#define kAPIVersion                     @"v1"

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_IOS6_OR_LESS (floor(NSFoundationVersionNumber)<=NSFoundationVersionNumber_iOS_6_1)
#define IS_IOS5_OR_LESS (floor(NSFoundationVersionNumber)<=NSFoundationVersionNumber_iOS_5_1)

#endif
