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
        CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];
        [appDelegate cancelPendingHeartRateEvent];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.row)
    {
        case 1:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AliveHMViewController *aliveController = [storyboard instantiateViewControllerWithIdentifier:@"aliveController"];

            //
            // Create a new pending heart rate event (for manual entry)
            //
            
            CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];
            [appDelegate createPendingHeartRateEvent];
            
            // Now fake a segue to the view (needed to keep the landscape orientation)
            [aliveController setDelegate:self];
            [self presentViewController:aliveController animated:YES completion:nil];
            break;
        }
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
    CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];
    if (appDelegate.pendingHeartRateEvent != nil)
    {
        appDelegate.pendingHeartRateEvent.heartRate = heartRate;
    }

    [self dismissViewControllerAnimated:YES completion:
        ^
        {
            [self performSegueWithIdentifier:@"aliveCorNextSegue" sender:self];
        }
    ];
}

-(void)didAbortAliveView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
