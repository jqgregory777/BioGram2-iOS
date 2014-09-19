//
//  CBCHeartRateFeed.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/18/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger
{
    CBCFeedFilterPrivate = 0,
    CBCFeedFilterPublic,
    CBCFeedFilterCollective
} CBCFeedFilter;

typedef enum : NSInteger
{
    CBCFeedSourceCoreData = 0,
    CBCFeedSourceMedable
} CBCFeedSource;

@interface CBCHeartRateFeed : NSObject

# pragma mark - Feed Source and Trial Mode

+ (CBCFeedSource)currentFeedSource;

# pragma mark - Feed Filter

+ (CBCFeedFilter)currentFeedFilter;
+ (void)setCurrentFeedFilter:(CBCFeedFilter)filter;

#pragma mark - Core Data

+ (NSArray *)fetchHeartRateEventsFromCoreData;
+ (void)deleteHeartRateEventsFromCoreData:(NSArray *)events;

@end
