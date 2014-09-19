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

@implementation CBCShareEventController

#pragma mark - Save Button

- (IBAction)saveButtonTouched:(id)sender
{
    if ([[CBCAppDelegate appDelegate] isLoggedInToMedable])
    {
        // when in medable mode, we never save to Core Data, so clean up the pending object
        [[CBCAppDelegate appDelegate] cancelPendingHeartRateEvent];
    }
    
    // Also activate the feed view in the tab bar.
    self.tabBarController.selectedIndex = 0;

    // Jump back to start of the "create heart rate event" page sequence.
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"unwindToCreateHeartRateEventSegue" sender:self];
}

@end
