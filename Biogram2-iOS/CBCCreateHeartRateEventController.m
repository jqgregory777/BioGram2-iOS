//
//  CBCCreateHeartRateEventController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCCreateHeartRateEventController.h"
#import "CBCAppDelegate.h"
#import "CBCHeartRateEvent.h"

@interface CBCCreateHeartRateEventController ()

@end

@implementation CBCCreateHeartRateEventController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isMovingToParentViewController == NO)
    {
        // we're already on the navigation stack
        // another controller must have been popped off
        // so, cancel the pending heart rate event
        CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate cancelPendingHeartRateEvent];
    }
}

- (IBAction)unwindToCreateHeartRateEvent:(UIStoryboardSegue *)unwindSegue
{
    // Destination for unwind segue that resets the UINavigationController to the start of the
    // "create new heart rate event" page sequence (viz., this page).
}

@end
