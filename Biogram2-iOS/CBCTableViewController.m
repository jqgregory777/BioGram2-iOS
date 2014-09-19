//
//  CBCTableViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/19/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCTableViewController.h"

@interface CBCTableViewController ()

@end

@implementation CBCTableViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
