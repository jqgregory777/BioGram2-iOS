//
//  CBCTabBarController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/15/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCTabBarController.h"
#import "CBCFeedViewController.h"
#import "CBCShareEventController.h"
#import "CBCHeartRateFeed.h"

@interface CBCTabBarController ()

@property (strong, nonatomic) UIViewController * rootCreateHeartRateController;

@end

@implementation CBCTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(willSwitchFeed:) name:kCBCWillSwitchFeed object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"CBCTabBarController viewDidAppear:%s", animated?"YES":"NO");

    UINavigationController * navController = self.viewControllers[1];
    NSArray * existingControllers = navController.viewControllers;
    
    self.rootCreateHeartRateController = [existingControllers firstObject];
}

- (void)willSwitchFeed:(NSNotification *)notification
{
    // whenever the feed changes, make sure that any detail event that might
    // be shown is popped off the nav controller's view stack
    [self resetFeedUIFlow];
    
    // whenever the feed changes, any pending heart rate event is canceled,
    // so reset our UI flow to the start of the event creation sequence
    [self resetCreateHeartRateUIFlow:nil];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    // whenever the user changes views in the tab bar, stop editing the table view
    UINavigationController * navController = self.viewControllers[0];
    if ([navController.viewControllers[0] respondsToSelector:@selector(stopEditingTableView)])
    {
        [navController.viewControllers[0] performSelector:@selector(stopEditingTableView)];
    }
    
    // also reset the heart rate creation UI flow, but ONLY if we're currently displaying the
    // special CBCShareEventController... otherwise it's unnecessary
    navController = self.viewControllers[1];
    UIViewController * viewController = [navController.viewControllers lastObject];
    if (viewController != nil && [viewController isKindOfClass:[CBCShareEventController class]])
    {
        [self resetCreateHeartRateUIFlow:nil];
    }
}

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

- (void)resetFeedUIFlow
{
    UINavigationController * navController = self.viewControllers[0];
    [navController popToRootViewControllerAnimated:NO];
}

- (void)resetCreateHeartRateUIFlow:(UIViewController *)currentTopController
{
    UINavigationController * navController = self.viewControllers[1];

    if (currentTopController == nil)
    {
        UIViewController * viewController = [navController.viewControllers lastObject];
        if (viewController != nil && [viewController isKindOfClass:[CBCShareEventController class]])
        {
            currentTopController = viewController;
        }
    }

    // Put the original root controller back into the stack.
    if (currentTopController != nil)
    {
        NSArray * newControllers = [NSArray arrayWithObjects:self.rootCreateHeartRateController, currentTopController, nil];
        [navController setViewControllers:newControllers animated:NO];
    }
    
    // Jump back to start of the "create heart rate event" page sequence.
    [navController popToRootViewControllerAnimated:NO];
}

- (void)goToMedableSettings
{
    NSLog(@"goToMedableSettings");
    
    // go to settings tab
    self.selectedIndex = 2;
    
    // go to medable settings page
    UINavigationController * settingsNavControl = self.viewControllers[2];
    NSArray * presentedSettingsControllers = settingsNavControl.viewControllers;
    
    BOOL foundMedableController = NO;
    int count = presentedSettingsControllers.count;
    for (int i = 0; i < count; i++)
    {
        UIViewController * controller = [presentedSettingsControllers objectAtIndex:i];
        if ([controller.restorationIdentifier isEqualToString:@"medableMainTableViewController"])
        {
            foundMedableController = YES;
            break;
        }
    }
    
    if (!foundMedableController)
    {
        UIViewController * settingsViewControl = settingsNavControl.childViewControllers[0];
        [settingsViewControl performSegueWithIdentifier:@"goToMedableSettingsSegue" sender:self];
    }
}

@end
