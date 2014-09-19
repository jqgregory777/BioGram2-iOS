//
//  CBCNavigationController.m
//  biogram
//
//  Created by Neel Bhoopalam on 5/7/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import "CBCNavigationController.h"

@implementation CBCNavigationController

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
