//
//  MDBundle.h
//  Medable
//
//  
//  Copyright (c) 2014 Medable. All rights reserved.
//

@class MDLegalAgreement;

@interface MDBundle : NSObject

@property (nonatomic, readonly) NSString* version;
@property (nonatomic, readonly) NSString* locale;
@property (nonatomic, readonly) NSDictionary* faults;
@property (nonatomic, readonly) NSArray* symptoms;
@property (nonatomic, readonly) NSArray* diagnoses;
@property (nonatomic, readonly) NSArray* treatments;
@property (nonatomic, readonly) NSDictionary* strings;
@property (nonatomic, readonly) NSDictionary* latestAgreements;
@property (nonatomic, readonly) NSDictionary* tutorial;

- (id)initWithAttributes:(NSDictionary*)attributes NOTNULL(1);
- (MDLegalAgreement*)agreementWithName:(NSString*)agreementName NOTNULL(1);

@end
