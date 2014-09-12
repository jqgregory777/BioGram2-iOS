//
//  CBCMedableMainTableViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableMainTableViewController.h"
#import "CBCAppDelegate.h"
#import "CBCMedableAccount.h"

@interface CBCMedableMainTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *accountCell;

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
    [self updateAccountDetailsButton];
}

- (void)updateAccountDetailsButton
{
    // Grey out the Account cell if there's no account to view
    CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
    CBCMedableAccount* account = appDelegate.medableAccount;
    
    BOOL enabled = (account != nil);

    self.accountCell.userInteractionEnabled = enabled;
    self.accountCell.textLabel.enabled = enabled;
    self.accountCell.detailTextLabel.enabled = enabled;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isMovingToParentViewController == NO)
    {
        // we're already on the navigation stack
        // another controller must have been popped off
        [self updateAccountDetailsButton];
    }
}

// NOT NECESSARY - [updateAccountDetailsButton] sets userInteractionEnabled to NO which disallows the segue
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if ([identifier isEqualToString:@"medableAccountDetailsSegue"])
//    {
//        CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
//        CBCMedableAccount* account = appDelegate.medableAccount;
//        return (account != nil);
//    }
//    return YES;
//}

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
