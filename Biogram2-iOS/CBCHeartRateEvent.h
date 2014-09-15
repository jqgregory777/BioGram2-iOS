//
//  Event.h
//  biogram
//
//  Created by Yuxiao Li on 8/21/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CBCHeartRateEvent : NSManagedObject

@property (nonatomic, strong) NSString * eventDescription;
@property (nonatomic, strong) NSString * heartRate;
@property (nonatomic, strong) NSData * photo;
@property (nonatomic, strong) NSDate * timeStamp;
@property (nonatomic, strong) NSData * backgroundImage;
@property (nonatomic, strong) NSData * overlayImage;

- (NSString *)timeStampAsString;

@end
