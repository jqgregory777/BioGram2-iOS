//
//  CBCMedableMainTableViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableMainTableViewController.h"

@interface CBCMedableMainTableViewController ()

@end

@implementation CBCMedableMainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization...
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Custom behavior...
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"medableCreateAccountSegue"])
    {
        // Could do something here like set myself as the delegate of the destination controller
        //UINavigationController *navigationController = segue.destinationViewController;
        //CBCMedableCreateAccountController *controller = [navigationController viewControllers][0];
        //controller.delegate = self;
    }
}

@end
