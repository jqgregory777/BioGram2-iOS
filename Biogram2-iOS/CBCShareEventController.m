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
#import "CBCHeartRateFeed.h"
#import "CBCImageUtilities.h"
#import "CBCSocialUtilities.h"

#import <Social/Social.h>

@interface CBCShareEventController ()

@property (strong, nonatomic) UIViewController * originalRootController;

- (void)willSwitchFeed:(NSNotification *)notification;

@end

@implementation CBCShareEventController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(willSwitchFeed:) name:kCBCWillSwitchFeed object:nil];
}

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

- (void)resetUIFlow
{
    // Put the original root controller back into the stack.
    NSArray * newControllers = [NSArray arrayWithObjects:self.originalRootController, self, nil];
    [self.navigationController setViewControllers:newControllers animated:NO];
    
    // Jump back to start of the "create heart rate event" page sequence.
    [self.navigationController popToRootViewControllerAnimated:NO];
    //[self performSegueWithIdentifier:@"unwindToCreateHeartRateEventSegue" sender:self];
}

- (void)willSwitchFeed:(NSNotification *)notification
{
    // whenever the feed changes, any pending heart rate event is canceled,
    // so reset our UI flow to the start of the event creation sequence
    [self resetUIFlow];
}

- (IBAction)doneButtonTouched:(id)sender
{
    // Activate the feed view in the tab bar.
    self.tabBarController.selectedIndex = 0;

    // Reset to start of the "create heart rate event" page sequence.
    [self resetUIFlow];
}

@end
