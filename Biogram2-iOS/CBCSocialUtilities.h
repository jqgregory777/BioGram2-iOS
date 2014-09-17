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

@interface CBCSocialUtilities : NSObject

#pragma mark - Facebook

+ (BOOL)postToFacebook:(CBCHeartRateEvent *)pendingEvent;

#pragma mark - Twitter

+ (BOOL)postToTwitter:(CBCHeartRateEvent *)pendingEvent;

@end
