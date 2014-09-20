//
//  CBCMedable.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/20/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedable.h"

static CBCMedable * _medableSingleton = nil;

@interface CBCMedable ()

@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* verificationToken;
@property (nonatomic, strong) UIAlertView* loginDialog;

@end

@implementation CBCMedable

#pragma mark - Singleton

+ (CBCMedable *) singleton
{
    if (_medableSingleton == nil)
        _medableSingleton = [[CBCMedable alloc] init];
    
    return _medableSingleton;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.alertViewStyle)
    {
        case UIAlertViewStyleLoginAndPasswordInput:
        {
            if (buttonIndex == 1)
            {
                UITextField* emailTextField = [alertView textFieldAtIndex:0];
                self.email = emailTextField.text;
                
                UITextField* passwordTextField = [alertView textFieldAtIndex:1];
                self.password = passwordTextField.text;
                
                [self loginWithEmail:self.email
                                   password:self.password
                          verificationToken:self.verificationToken];
            }
            
            break;
        }
            
        case UIAlertViewStylePlainTextInput:
        {
            UITextField* codeTextField = [alertView textFieldAtIndex:0];
            self.verificationToken = codeTextField.text;
            
            [self loginWithEmail:self.email
                               password:self.password
                      verificationToken:self.verificationToken];
            
            break;
        }
            
        default:
            break;
    }
    
    if (alertView == self.loginDialog)
    {
        self.loginDialog = nil;
    }
}

- (void)checkForValidSession
{
    // Autologin if we already have a token
    
    __weak typeof (self) wSelf = self;
    
    [[MDAPIClient sharedClient]
     loginStatusWithParameters:[MDAPIParameterFactory parametersWithExpand]
     callback:
         ^(MDAccount* account, MDFault* fault)
         {
             if (account == nil)
             {
                 [wSelf showLoginDialog];
             }
         }
    ];
}

- (void)loginWithEmail:(NSString*)email password:(NSString*)password verificationToken:(NSString*)verificationToken
{
    if (email.length && password.length)
    {
        __weak typeof (self) wSelf = self;
        
        [[MDAPIClient sharedClient]
         authenticateSessionWithEmail:email
         password:password
         verificationToken:verificationToken
         singleUse:NO
         callback:
             ^(MDAccount *localUser, MDFault *fault)
             {
                 if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginEmail"])
                     [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"MedableLoginEmail"];
                 else
                     [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MedableLoginEmail"];
                 
                 if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginPassword"])
                     [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
                 else
                     [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
                 
                 if (fault)
                 {
                     if ([fault.code isEqualToString:kMDAPIErrorUnverifiedLocation] ||
                         [fault.code isEqualToString:kMDAPIErrorNewLocation])
                     {
                         [wSelf displayAlertWithFault:fault];
                     }
                     else if ([fault.code isEqualToString:@"kInvalidCredentials"])
                     {
                         [wSelf showLoginDialog];
                     }
                     else
                     {
                         [wSelf displayAlertWithMessage:fault.text];
                     }
                 }
             }
         ];
    }
}

- (void)logout
{
    __weak typeof (self) wSelf = self;
    
    [[MDAPIClient sharedClient] logout:^(MDFault *fault)
     {
         if (fault)
         {
             [wSelf displayAlertWithFault:fault];
         }
     }];
}

- (BOOL)isLoggedIn
{
    return ([[MDAPIClient sharedClient] localUser] != nil);
}

- (void)showLoginDialog
{
    if (!self.loginDialog)
    {
        self.loginDialog = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Medable Login", nil)
                                   message:NSLocalizedString(@"Enter your credentials", nil)
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                   otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        
        self.loginDialog.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginEmail"])
        {
            // the user has requested that we cache the login information for convenience
            // see if we have any cached info, and auto-login if so
            NSString * email = [[NSUserDefaults standardUserDefaults] stringForKey:@"MedableLoginEmail"];
            if (email != nil)
            {
                [self.loginDialog textFieldAtIndex:0].text = email;
                [[self.loginDialog textFieldAtIndex:1] becomeFirstResponder]; // sadly this doesn't work, need to do it in the UIAlertView's viewWillAppear: method...
            }
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginPassword"])
        {
            // the user has requested that we cache the login information for convenience
            // see if we have any cached info, and auto-login if so
            NSString * password = [[NSUserDefaults standardUserDefaults] stringForKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
            if (password != nil)
            {
                [self.loginDialog textFieldAtIndex:1].text = password;
            }
        }
        
        [self.loginDialog show];
    }
}

- (void)displayAlertWithFault:(MDFault*)fault
{
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:[@"Error: " stringByAppendingString:fault.code]
                          message:fault.text
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
    
    // Received error on first login with no verification token
    if ([fault.code isEqualToString:kMDAPIErrorUnverifiedLocation] ||
        [fault.code isEqualToString:kMDAPIErrorNewLocation])
    {
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.message = [alert.message stringByAppendingString:@"\nPlease enter verfication code:"];
    }
    
    [alert show];
}

- (void)displayAlertWithMessage:(NSString*)message
{
    [[[UIAlertView alloc]
      initWithTitle:nil
      message:message
      delegate:nil
      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
      otherButtonTitles:nil] show];
}

@end
