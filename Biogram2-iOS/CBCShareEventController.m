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
#import "CBCTabBarController.h"

#import <Social/Social.h>

@interface CBCShareEventController ()

@property (strong, nonatomic) UIViewController * originalRootController;

@end

@implementation CBCShareEventController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"CBCShareEventController viewDidAppear:%s", animated?"YES":"NO");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"CBCShareEventController viewDidAppear:%s", animated?"YES":"NO");
    [super viewDidAppear:animated];
}

- (void)makeOnlyViewInNavigationStack
{
    NSLog(@"CBCShareEventController makeOnlyViewInNavigationStack");
    NSArray * existingControllers = self.navigationController.viewControllers;
    if ([existingControllers lastObject] == self)
        NSLog(@"As I thought!");
    
    self.originalRootController = [existingControllers firstObject];
    
    NSArray * newControllers = [NSArray arrayWithObject:self];
    [self.navigationController setViewControllers:newControllers animated:NO];
}

//- (void)resetUIFlow
//{
//    // Put the original root controller back into the stack.
//    NSArray * newControllers = [NSArray arrayWithObjects:self.originalRootController, self, nil];
//    [self.navigationController setViewControllers:newControllers animated:NO];
//    
//    // Jump back to start of the "create heart rate event" page sequence.
//    [self.navigationController popToRootViewControllerAnimated:NO];
//    //[self performSegueWithIdentifier:@"unwindToCreateHeartRateEventSegue" sender:self];
//}

- (IBAction)doneButtonTouched:(id)sender
{
    // Activate the feed view in the tab bar.
    self.tabBarController.selectedIndex = 0;

    // Reset to start of the "create heart rate event" page sequence.
    CBCTabBarController * tabBarController = (CBCTabBarController *)self.tabBarController;
    [tabBarController resetCreateHeartRateUIFlow:self];
}

@end
