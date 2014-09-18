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
    CBCAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    
    if ([appDelegate savePendingHeartRateEvent])
    {
        // successfully saved to Core Data... now post to Medable
        // TO DO: CHANGE TO POST TO MEDABLE *ONLY* AND NOT USE CORE DATA AT ALL
        
        if ([[MDAPIClient sharedClient] localUser])
        {
            [CBCSocialUtilities postToMedable:self.displayedEvent sender:self];
        }
        else
        {
            // TO DO: user chose not to log in... discard the event
            [CBCAppDelegate showMessage:@"Unable to post event to Medable." withTitle:@"Medable Failure"];
        }
    }
    else
    {
        [CBCAppDelegate showMessage:@"Unable to save event to Core Data." withTitle:@"Save Failure"];
    }

    // Also activate the feed view in the tab bar.
    self.tabBarController.selectedIndex = 0;

    // Jump back to start of the "create heart rate event" page sequence.
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"unwindToCreateHeartRateEventSegue" sender:self];
}

@end
