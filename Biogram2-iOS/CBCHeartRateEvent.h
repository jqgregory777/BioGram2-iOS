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

@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * heartRate;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSData * backgroundImage;
@property (nonatomic, retain) NSData * overlayImage;

@end
