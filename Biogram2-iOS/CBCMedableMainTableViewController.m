//
//  CBCMedableMainTableViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableMainTableViewController.h"
#import "CBCAppDelegate.h"

@interface CBCMedableMainTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *accountCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *logInOutCell;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isMovingToParentViewController == NO)
    {
        // we're already on the navigation stack
        // another controller must have been popped off
        [self updateAccountDetailsButton];
    }

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateAccountDetailsButton) name:kMDNotificationUserDidLogin object:nil];
    [defaultCenter addObserver:self selector:@selector(updateAccountDetailsButton) name:kMDNotificationUserDidLogout object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)updateAccountDetailsButton
{
    // Grey out the Account cell if there's no account to view
    BOOL loggedIn = [[CBCAppDelegate appDelegate] isLoggedInToMedable];

    self.accountCell.userInteractionEnabled = loggedIn;
    self.accountCell.textLabel.enabled = loggedIn;
    self.accountCell.detailTextLabel.enabled = loggedIn;

    self.logInOutCell.textLabel.text = NSLocalizedString(loggedIn ? @"Log Out" : @"Log In", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"medableLogInOut"])
    {
        if ( ![[CBCAppDelegate appDelegate] isLoggedInToMedable] )
        {
            [[CBCAppDelegate appDelegate] showMedableLoginDialog];
        }
        else
        {
            [[CBCAppDelegate appDelegate] logoutMedable];
        }
    }
}


#pragma mark - Navigation

// NOT NECESSARY - [updateAccountDetailsButton] sets userInteractionEnabled to NO which disallows the segue
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if ([identifier isEqualToString:@"medableAccountDetailsSegue"])
//    {
//        CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];
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

- (IBAction)returnToMainView:(UIStoryboardSegue *)segue
{
    // Nothing to do
}

@end
