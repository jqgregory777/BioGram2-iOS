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

@interface CBCTabBarController ()

@end

@implementation CBCTabBarController

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    // whenever the user changes views in the tab bar, stop editing the table view
    UINavigationController * navController = self.viewControllers[0];
    if ([navController.viewControllers[0] respondsToSelector:@selector(stopEditingTableView)])
    {
        [navController.viewControllers[0] performSelector:@selector(stopEditingTableView)];
    }
    
    // also reset the CBCSharePhotoController if it's currently displayed
    navController = self.viewControllers[1];
    UIViewController * viewController = navController.viewControllers[0];
    if ([viewController respondsToSelector:@selector(resetUIFlow)])
    {
        // it's a CBCShareEventController
        [viewController performSelector:@selector(resetUIFlow)];
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

@end
