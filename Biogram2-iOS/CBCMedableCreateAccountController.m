//
//  CBCMedableCreateAccountController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableCreateAccountController.h"
#import "CBCAppDelegate.h"

@interface CBCMedableCreateAccountController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderMaleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderFemaleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderUnspecifiedCell;

@end

@implementation CBCMedableCreateAccountController

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
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.phoneNumberTextField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.phoneNumberTextField resignFirstResponder];
}

#pragma mark - Selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.phoneNumberTextField resignFirstResponder];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.genderMaleCell
    ||  cell == self.genderFemaleCell
    ||  cell == self.genderUnspecifiedCell)
    {
        // Implement radio-button behavior
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (cell == self.genderMaleCell)
        {
            self.genderFemaleCell.accessoryType = UITableViewCellAccessoryNone;
            self.genderUnspecifiedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (cell == self.genderFemaleCell)
        {
            self.genderMaleCell.accessoryType = UITableViewCellAccessoryNone;
            self.genderUnspecifiedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else if (cell == self.genderUnspecifiedCell)
        {
            self.genderMaleCell.accessoryType = UITableViewCellAccessoryNone;
            self.genderFemaleCell.accessoryType = UITableViewCellAccessoryNone;
        }
        //[tableView reloadSections:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Navigation

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    // Actually create the account...
    CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CBCMedableAccount* account = [CBCMedableAccount new];
    account.firstName = self.firstNameTextField.text;
    account.lastName = self.lastNameTextField.text;
    account.phoneNumber = self.phoneNumberTextField.text;
    account.email = self.emailTextField.text;
    account.dateOfBirth = self.birthDatePicker.date;
    
    if (self.genderMaleCell.accessoryType == UITableViewCellAccessoryCheckmark)
        account.gender = kGenderMale;
    else if (self.genderFemaleCell.accessoryType == UITableViewCellAccessoryCheckmark)
        account.gender = kGenderFemale;
    else
        account.gender = kGenderUnspecified;
    
    if ([account isValid])
    {
        [appDelegate createMedableAccount:account];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
