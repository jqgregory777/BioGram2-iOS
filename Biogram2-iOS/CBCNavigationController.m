//
//  CBCNavigationController.m
//  biogram
//
//  Created by Neel Bhoopalam on 5/7/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import "CBCNavigationController.h"
#import "CBCShareEventController.h"

@implementation CBCNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
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

- (void)navigationController:(UINavigationController *)navCtrl didShowViewController:(UIViewController*)viewCtrl animated:(BOOL)animated
{
    if ([viewCtrl isKindOfClass:[CBCShareEventController class]])
    {
        CBCShareEventController * shareEventCtrl = (CBCShareEventController*)viewCtrl;
        [shareEventCtrl makeOnlyViewInNavigationStack];
    }
}

@end
