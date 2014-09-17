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
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

@end
