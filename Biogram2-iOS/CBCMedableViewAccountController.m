//
//  CBCMedableViewAccountController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/12/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableViewAccountController.h"
#import "CBCAppDelegate.h"

@interface CBCMedableViewAccountController ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *firstNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *lastNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneNumberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *birthDateCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *deleteAccountCell;

@end

@implementation CBCMedableViewAccountController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MDAccount* account = [[MDAPIClient sharedClient] localUser];
    if (account != nil)
    {
        self.firstNameCell.detailTextLabel.text = account.firstName;
        self.lastNameCell.detailTextLabel.text = account.lastName;
        self.emailCell.detailTextLabel.text = account.email;
        self.phoneNumberCell.detailTextLabel.text = account.mobile;
        self.birthDateCell.detailTextLabel.text = account.dob;
        self.genderCell.detailTextLabel.text = [MDDataFriendly genderLongStringFromShortString:[MDDataFriendly genderShortStringFromGender:account.gender]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.deleteAccountCell)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Confirm Account Deletion"
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Delete", nil];
        
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate deleteMedableAccount];
        [self performSegueWithIdentifier:@"returnToMainView" sender:self];
    }
}

@end
