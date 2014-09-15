//
//  Event.m
//  biogram
//
//  Created by Yuxiao Li on 8/21/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import "CBCHeartRateEvent.h"


@implementation CBCHeartRateEvent

@dynamic eventDescription;
@dynamic heartRate;
@dynamic photo;
@dynamic timeStamp;
@dynamic backgroundImage;
@dynamic overlayImage;

- (NSString *)timeStampAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    //return [self.timeStamp descriptionWithLocale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:self.timeStamp];
}

@end
