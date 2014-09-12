//
//  CBCMedableAccount.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableAccount.h"

@implementation CBCMedableAccount

- (id)init
{
    self = [super init];
    if (self)
    {
        self.firstName = @"";
        self.lastName = @"";
        self.email = @"";
        self.phoneNumber = @"";
        self.gender = kGenderUnspecified;
    }
    return self;
}

- (BOOL)isValid
{
    return (self.firstName.length > 0
        &&  self.lastName.length > 0
        &&  self.email.length > 0
        &&  self.phoneNumber.length > 0 // should check for valid number
        &&  self.dateOfBirth != nil);
}

@end
