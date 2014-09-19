//
//  CBCHeartRateFeed.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/18/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCHeartRateFeed.h"
#import "CBCAppDelegate.h"

@implementation CBCHeartRateFeed

static CBCFeedFilter _currentFeedFilter;

# pragma mark - Feed Source and Trial Mode

+ (CBCFeedSource)currentFeedSource
{
    BOOL loggedIn = [[CBCAppDelegate appDelegate] isLoggedInToMedable];
    return (loggedIn) ? CBCFeedSourceMedable : CBCFeedSourceCoreData;
}

# pragma mark - Feed Filter

+ (CBCFeedFilter)currentFeedFilter
{
    return _currentFeedFilter;
}

+ (void)setCurrentFeedFilter:(CBCFeedFilter)filter
{
    _currentFeedFilter = filter;
}

@end
