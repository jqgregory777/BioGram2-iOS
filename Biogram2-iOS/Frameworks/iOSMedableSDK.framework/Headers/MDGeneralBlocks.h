//
//  MDGeneralBlocks.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#ifndef iOSMedableSDK_MDGeneralBlocks_h
#define iOSMedableSDK_MDGeneralBlocks_h

@class MDFault;

typedef void (^MDNoArgumentCallback)(void);
typedef void (^MDObjectCallback)(id object);
typedef void (^MDBoolArgumentCallback)(BOOL boolean);
typedef BOOL (^MDPicsUpdateBlock)(NSString* imageId, UIImage* image, BOOL lastImage);
typedef void (^MDUIntegerCallback)(NSUInteger integer);
typedef void (^MDImageCallback)(UIImage* image);
typedef void (^MDFaultCallback)(MDFault* fault);
typedef void (^MDImageOrFaultCallback)(UIImage* image, MDFault* fault);
typedef void (^MDObjectBoolCallback)(id object, BOOL condition);

#endif
