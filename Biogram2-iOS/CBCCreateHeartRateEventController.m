//
//  CBCCreateHeartRateEventController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCCreateHeartRateEventController.h"
#import "CBCAppDelegate.h"
#import "CBCMedable.h"
#import "CBCHeartRateEvent.h"
#import "CBCHearTRateFeed.h"
#import "AliveHMViewController.h"

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
        CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];
        [feed cancelPendingHeartRateEvent];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isLoggedIn = [[CBCMedable singleton] isLoggedIn];
    int trialEventCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"TrialEventCount"];
    int maxTrialEventCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxTrialEventCount"];
    BOOL allowEventCreation = (isLoggedIn || trialEventCount < maxTrialEventCount);
    
    switch(indexPath.row)
    {
        case 0:
            if (allowEventCreation)
            {
                [self performSegueWithIdentifier:@"manualNextSegue" sender:self];
            }
            else
            {
                [[CBCMedable singleton] showMedableInfoDialog:self];
            }
            break;
            
        case 1:
            if (allowEventCreation)
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AliveHMViewController *aliveController = [storyboard instantiateViewControllerWithIdentifier:@"aliveController"];

                //
                // Create a new pending heart rate event (for manual entry)
                //
                
                CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];
                [feed createPendingHeartRateEvent];
                
                // Now fake a segue to the view (needed to keep the landscape orientation)
                [aliveController setDelegate:self];
                [self presentViewController:aliveController animated:YES completion:nil];
            }
            else
            {
                [[CBCMedable singleton] showMedableInfoDialog:self];
            }
            break;
    }
}

- (IBAction)unwindToCreateHeartRateEvent:(UIStoryboardSegue *)unwindSegue
{
    // Destination for unwind segue that resets the UINavigationController to the start of the
    // "create new heart rate event" page sequence (viz., this page).
}

#pragma mark - AliveHMDelegate

-(void)didCloseAliveViewWithHeartRate:(NSString*)heartRate
{
    CBCHeartRateEvent * pendingEvent = [[[CBCFeedManager singleton] currentFeed] pendingHeartRateEvent];
    if (pendingEvent != nil)
    {
        pendingEvent.heartRate = [heartRate copy];
        NSLog(@"CBCCreateHeartRateEventController: didCloseAliveViewWithHeartRate: pendingEvent.heartRate = %@", pendingEvent.heartRate);
    }

    [self performSegueWithIdentifier:@"aliveCorNextSegue" sender:self];
    
    [self dismissViewControllerAnimated:YES completion:
        ^
        {
            CBCHeartRateEvent * pendingEvent2 = [[[CBCFeedManager singleton] currentFeed] pendingHeartRateEvent];
            NSLog(@"pendingEvent2 = %p, pendingEvent = %p", pendingEvent2, pendingEvent);
            NSLog(@"CBCCreateHeartRateEventController: performed segue... pendingEvent2.heartRate = %@, pendingEvent.heartRate = %@", pendingEvent2.heartRate, pendingEvent.heartRate);
        }
    ];
}

-(void)didAbortAliveView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
