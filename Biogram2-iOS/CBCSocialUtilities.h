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

+ (BOOL)postToFacebook:(CBCHeartRateEvent *)pendingEvent;
+ (BOOL)postToTwitter:(CBCHeartRateEvent *)pendingEvent;

@end
