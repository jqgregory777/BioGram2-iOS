//
//  CBCMedableCreateAccountController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableCreateAccountController.h"
#import "CBCAppDelegate.h"
#import "EXTPhoneNumberFormatter.h"
#import "CBCMedableMainTableViewController.h"


@interface CBCMedableCreateAccountController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthDatePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderMaleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderFemaleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *genderUnspecifiedCell;

@end

@implementation CBCMedableCreateAccountController {
    int _phoneNumberTextSemaphore;
    EXTPhoneNumberFormatter *_phoneNumberFormatter;
    NSString *_locale; //@"us"
}

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
    self.passwordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    self.phoneNumberTextField.delegate = self;
    
    _phoneNumberFormatter = [[EXTPhoneNumberFormatter alloc] init];
    _locale = [[NSLocale currentLocale] localeIdentifier];
    _phoneNumberTextSemaphore = 0; // init semaphore
    self.phoneNumberTextField.placeholder = [_phoneNumberFormatter placeholderStringForLocale:_locale];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // make the keyboard disappear when the user hits the Done button
    [textField resignFirstResponder];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // make the phone number keyboard disappear when the list view is scrolled (since it has no Done button)
    [self.phoneNumberTextField resignFirstResponder];
}

- (IBAction)autoFormatTextField:(id)sender
{
    // auto-format phone number text field as the user types
    if(_phoneNumberTextSemaphore)
        return;
    
    _phoneNumberTextSemaphore = 1;
    
    self.phoneNumberTextField.text = [_phoneNumberFormatter format:self.phoneNumberTextField.text withLocale:_locale];
    
    _phoneNumberTextSemaphore = 0;
    
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
    MDInfoValidator* accountValidator = [[MDInfoValidator alloc] initWithType:MDInfoValidatorBundleTypePatientSignup];
    
    accountValidator.firstName = self.firstNameTextField.text;
    accountValidator.lastName = self.lastNameTextField.text;
    accountValidator.phone = [MDDataFriendly plainPhoneNumberFromMaskedPhoneNumber:self.phoneNumberTextField.text];
    accountValidator.email = self.emailTextField.text;
    accountValidator.password = self.passwordTextField.text;
    accountValidator.confirmPassword = self.confirmPasswordTextField.text;
    accountValidator.dateOfBirth = [MDDateUtilities formattedDayOfBirthFromDate:self.birthDatePicker.date];
    
    if (self.genderMaleCell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        accountValidator.gender = [MDDataFriendly genderShortStringFromGender:MDGenderMale];
    }
    else if (self.genderFemaleCell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        accountValidator.gender = [MDDataFriendly genderShortStringFromGender:MDGenderFemale];
    }
    else
    {
        accountValidator.gender = [MDDataFriendly genderShortStringFromGender:MDGenderUnspecified];
    }
    
    BOOL accountInfoIsValid = [accountValidator isValidWithInvalidMessagesCallback:^(NSArray* invalidMessages)
                               {
                                   [self displayValidationErrorsWithArray:invalidMessages];
                               }];
    
    if (accountInfoIsValid)
    {
        MDProfileInfo* profileInfo = [MDProfileInfo
                                      patientProfileWithGender:accountValidator.gender
                                      dob:accountValidator.dateOfBirth];
        
        [[MDAPIClient sharedClient]
         registerAccountWithFirstName:accountValidator.firstName
         lastName:accountValidator.lastName
         email:accountValidator.email
         mobile:accountValidator.phone
         password:accountValidator.password
         role:kRolePatient
         profileInfo:profileInfo
         thumbImage:nil
         progressCallback:nil
         callback:
            ^(NSDictionary *result, MDFault *fault)
            {
                void (^completion)() = nil;
                
                if (fault)
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Signup Failed", nil)
                                                message:fault.text
                                               delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                      otherButtonTitles:nil, nil] show];
                }
                else
                {
                    completion = ^{
                        [(CBCMedableMainTableViewController*)self.presentingViewController updateAccountDetailsButton:nil];
                    };
                }
                
                [self dismissViewControllerAnimated:YES completion:completion];
            }
        ];
    }
}

- (void)displayValidationErrorsWithArray:(NSArray*)invalidMessages
{
    ASSERT_CLASS(invalidMessages, NSArray);
    
    NSMutableString* errorMsg = [[NSMutableString alloc] init];
    for (NSString* invalidFieldMsg in invalidMessages)
    {
        ASSERT_STRING(invalidFieldMsg);
        [errorMsg appendFormat:@"\n- %@", invalidFieldMsg];
    }
    
    if ([invalidMessages count])
    {
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"validation_error_title", nil)
          message:errorMsg
          delegate:nil
          cancelButtonTitle:NSLocalizedString(@"ok", nil)
          otherButtonTitles:nil]
         show];
    }
}

@end
