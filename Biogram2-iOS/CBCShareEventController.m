//
//  CBCShareEventController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/14/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCShareEventController.h"
#import "CBCAppDelegate.h"
#import "CBCHeartRateEvent.h"
#import "CBCImageUtilities.h"
#import "CBCSocialUtilities.h"

#import <Social/Social.h>

@interface CBCShareEventController ()

@property (strong, nonatomic) UIViewController * originalRootController;

@end

@implementation CBCShareEventController

#pragma mark - Save Button

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"CBCShareEventController viewDidAppear:%s", animated?"YES":"NO");
    NSArray * existingControllers = self.navigationController.viewControllers;
    if ([existingControllers lastObject] == self)
        NSLog(@"As I thought!");
    
    self.originalRootController = [existingControllers firstObject];
    
    NSArray * newControllers = [NSArray arrayWithObject:self];
    [self.navigationController setViewControllers:newControllers animated:NO];
}

- (IBAction)saveButtonTouched:(id)sender
{
//    if ([[CBCMedable singleton] isLoggedIn])
//    {
//        // when in medable mode, we never save to Core Data, so clean up the pending object
//        [[CBCAppDelegate appDelegate] cancelPendingHeartRateEvent];
//    }
    
    // Activate the feed view in the tab bar.
    self.tabBarController.selectedIndex = 0;

    // Put the original root controller back into the stack.
    NSArray * newControllers = [NSArray arrayWithObjects:self.originalRootController, self, nil];
    [self.navigationController setViewControllers:newControllers animated:NO];
    
    // Jump back to start of the "create heart rate event" page sequence.
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"unwindToCreateHeartRateEventSegue" sender:self];
}

@end
