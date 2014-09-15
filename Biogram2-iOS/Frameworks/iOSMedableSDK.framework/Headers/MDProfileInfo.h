//
//  MDProfileInfo.h
//  iOSMedableSDK
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MDProfileInfo : NSObject

+ (MDProfileInfo*)patientProfileWithGender:(NSString*)gender
                                       dob:(NSString*)dob NOTNULL(2);

+ (MDProfileInfo*)providerProfileWithGender:(NSString*)gender
                                  specialty:(NSString*)specialty
                                affiliation:(NSString*)affiliation
                          patientVisibility:(BOOL)patientVisibility
                         providerVisibility:(BOOL)providerVisibility
                                        npi:(NSString*)npi
                               licenseState:(NSString*)licenseState
                              licenseNumber:(NSString*)licenseNumber NOTNULL(2,3);

- (NSDictionary*)dictionaryRepresentation;

@end
