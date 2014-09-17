//
//  MDExpandableProperty.h
//  iOSMedableSDK
//
//  
//  Copyright (c) 2014 Medable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDExpandableProperty : NSObject

@property (nonatomic, strong) id expandedObject;

- (instancetype)initWithValue:(id)value NOTNULL(1);

- (instancetype)initWithContractedValue:(NSString*)contractedValue NOTNULL(1);

- (instancetype)initWithExpandedValue:(id)expandedValue NOTNULL(1);

- (instancetype)initWithContractedValue:(NSString*)contractedValue
                          expandedValue:(id)expandedValue;

- (id)value;
- (BOOL)isExpanded;

@end
