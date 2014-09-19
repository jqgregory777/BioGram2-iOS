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

#pragma mark - Core Data

+ (NSArray *)fetchHeartRateEventsFromCoreData
{
    NSManagedObjectContext * moc = [[CBCAppDelegate appDelegate] managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];

    NSEntityDescription * entityDescription = [NSEntityDescription entityForName:@"HeartRateEvent" inManagedObjectContext:moc];
    [request setEntity:entityDescription];

    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];

    NSError * error;
    NSArray * array = [moc executeFetchRequest:request error:&error];

    return array;
}

+ (void)deleteHeartRateEventsFromCoreData:(NSArray *)events
{
    NSManagedObjectContext *context = [[CBCAppDelegate appDelegate] managedObjectContext];

    for (CBCHeartRateEvent * event in events)
    {
        [context deleteObject:event];
    }
    
    NSError *error = nil;
    if (![context save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
