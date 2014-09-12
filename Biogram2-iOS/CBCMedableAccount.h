//
//  CBCMedableAccount.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBCMedableAccount : NSObject

typedef NS_ENUM(NSInteger, Gender)
{
    kGenderMale,
    kGenderFemale,
    kGenderUnspecified,
    kGenderCount
};

@property NSString *firstName;
@property NSString *lastName;
@property NSString *email;
@property NSString *phoneNumber;
@property NSDate *dateOfBirth;
@property (readonly) NSString *dateOfBirthAsString;
@property Gender gender;
@property (readonly) NSString* genderAsString;

- (id)init;
- (BOOL)isValid;

@end
