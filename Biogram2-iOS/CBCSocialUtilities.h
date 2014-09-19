//
//  CBCSocialUtilities.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/16/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCHeartRateEvent.h"
#import <Foundation/Foundation.h>
#import <Social/Social.h>

// Represents a request to share a single CBCHeartRateEvent to one or more social media services.
// This object is created when the CBCHeartRateEvent is first saved. It sticks around until
// all requested shares have either completed or failed, and then updates the CBCHeartRateEvent's
// postedTo* attributes appropriately (and notifies the user if one or more of the shares failed).

@interface CBCSocialUtilities : NSObject

#pragma mark - Notifications

enum ESocialServiceID
{
    SocialServiceIDFacebook,
    SocialServiceIDTwitter,
    SocialServiceIDMedable,
    SocialServiceIDCount
};
typedef NSInteger SocialServiceID;

extern NSString* const kCBCSocialPostDidComplete;

#pragma mark - Facebook

+ (void)postToFacebook:(CBCHeartRateEvent *)pendingEvent sender:(id)sender;

#pragma mark - Twitter

+ (void)postToTwitter:(CBCHeartRateEvent *)pendingEvent sender:(id)sender;

#pragma mark - Medable

+ (void)postToMedable:(CBCHeartRateEvent *)heartRateEvent postToPublicFeed:(BOOL)postToPublicFeed completion:(void (^)(MDPost* post, MDFault* fault))finishBlock;
+ (void)postToMedable:(CBCHeartRateEvent *)heartRateEvent postToPublicFeed:(BOOL)postToPublicFeed;

@end
