//
//  MDDateUtilities.h
//  Medable
//

//  Copyright (c) 2014 Medable. All rights reserved.
//

extern NSString* const kDateFormatString;
extern NSString* const kDateFormatStringLong;

@interface MDDateUtilities : NSObject

+ (NSDateFormatter*)dateFormatter;

+ (NSDate*)dateFromWapiDobString:(NSString*)dobStringFromWapi NOTNULL(1);
+ (NSDate*)dateFromYYYYMMDDString:(NSString*)yyyymmddSting NOTNULL(1);

+ (NSUInteger)ageFromDateOfBirth:(NSDate*)dob NOTNULL(1);
+ (NSDate*)dobFromAge:(NSUInteger)age;
+ (NSString*)formattedDayOfBirthFromAge:(NSUInteger)age;
+ (NSString*)formattedDayOfBirthFromDate:(NSDate*)date;

@end
