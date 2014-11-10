//
//  CBCMedable.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/20/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedable.h"
#import "CBCTabBarController.h"

static CBCMedable * _medableSingleton = nil;

typedef enum : NSInteger
{
    CBCMedableAlertViewLogin,       // username, password login dialog
    CBCMedableAlertViewPin,         // enter your verification PIN code
    CBCMedableAlertViewLoginFault,  // error logging in (e.g. pw is incorrect)
    CBCMedableAlertViewFault,       // general Medable error
    CBCMedableAlertViewInfo         // show info about Medable then take the user to the Medable Settings view
} CBCMedableAlertViewType;

// -------------------------------------------------------------------------------------------------------------------

@interface CBCMedableAlertView : UIAlertView

@property (nonatomic) CBCMedableAlertViewType type;
@property (nonatomic, weak) UIViewController* requester;

@end

@implementation CBCMedableAlertView

@end

// -------------------------------------------------------------------------------------------------------------------

@interface CBCMedable ()

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * verificationToken;
@property (nonatomic, strong) CBCMedableAlertView * loginAlertView;
@property (nonatomic, strong) CBCMedableAlertView * alertView;

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

- (void)alertView:(UIAlertView *)rawAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CBCMedableAlertView * alertView = (CBCMedableAlertView *)rawAlertView;
    
    switch (alertView.type)
    {
        case CBCMedableAlertViewLogin:
        {
            if (buttonIndex == 1)
            {
                UITextField* emailTextField = [alertView textFieldAtIndex:0];
                UITextField* passwordTextField = [alertView textFieldAtIndex:1];
                
                [self loginWithEmail:emailTextField.text
                            password:passwordTextField.text
                   verificationToken:self.verificationToken];
            }
            else if (buttonIndex == 2)
            {
                CBCTabBarController * tabBarCtrl = (CBCTabBarController *)alertView.requester.tabBarController;
                [tabBarCtrl goToMedableSettings];
            }
            
            break;
        }
            
        case CBCMedableAlertViewPin:
        {
            UITextField* codeTextField = [alertView textFieldAtIndex:0];
            self.verificationToken = codeTextField.text;
            
            [self loginWithEmail:self.email
                        password:self.password
               verificationToken:self.verificationToken];
            
            break;
        }
            
        case CBCMedableAlertViewLoginFault:
        {
            [self showLoginDialog];
            break;
        }
            
        case CBCMedableAlertViewFault:
            break;

        case CBCMedableAlertViewInfo:
        {
            if (buttonIndex == 0)
            {
                CBCTabBarController * tabBarCtrl = (CBCTabBarController *)alertView.requester.tabBarController;
                [tabBarCtrl goToMedableSettings];
            }
            break;
        }
            
        default:
            break;
    }
    
    if (alertView == self.loginAlertView)
    {
        self.loginAlertView = nil;
    }
    if (alertView == self.alertView)
    {
        self.alertView = nil;
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
                NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                if ([userDefaults boolForKey:@"MedableAutoLogin"])
                {
                    NSString * email = [userDefaults stringForKey:@"MedableLoginEmail"];
                    NSString * password = [userDefaults stringForKey:@"MedableLoginPassword"];
                    
                    [wSelf loginWithEmail:email
                                 password:password
                        verificationToken:wSelf.verificationToken];
                }
                else
                {
                    [wSelf showLoginDialog];
                }
            }
        }
    ];
}

- (void)cacheCredentials
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginEmail"])
        [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:@"MedableLoginEmail"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MedableLoginEmail"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginPassword"])
        [[NSUserDefaults standardUserDefaults] setObject:self.password forKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
    else
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"MedableLoginPassword"];
}

- (void)loginWithEmail:(NSString*)email password:(NSString*)password verificationToken:(NSString*)verificationToken
{
    // not sure if this is necessary, but Fer had it guarded against empty username and/or password so do this
    if (email == nil || email.length == 0)
        email = @" ";
    if (password == nil || password.length == 0)
        password = @" ";

    self.email = email;
    self.password = password;
    
    __weak typeof (self) wSelf = self;
    
    NSLog(@")) medable login '%@' pw '%@'", email, password);
    
    [[MDAPIClient sharedClient]
     authenticateSessionWithEmail:email
     password:password
     verificationToken:verificationToken
     singleUse:NO
     callback:
         ^(MDAccount *localUser, MDFault *fault)
         {
             // cache the login credentials if the user allows it
             [self cacheCredentials];
             
             NSLog(@")) medable login complete: fault = %@ (%@)", fault, (fault != nil) ? fault.text : @"");

             if (fault != nil)
             {
                 [wSelf displayAlertWithLoginFault:fault];
             }
         }
     ];
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
    if (!self.loginAlertView && !self.alertView)
    {
        self.loginAlertView = [[CBCMedableAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Medable Login", nil)
                                   message:NSLocalizedString(@"Enter your credentials.", nil)
                                   delegate:self
                                   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                   otherButtonTitles:NSLocalizedString(@"Login", nil), NSLocalizedString(@"Sign Up", nil), nil];
        
        self.loginAlertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginEmail"])
        {
            // the user has requested that we cache the login information for convenience
            // see if we have any cached info, and auto-login if so
            NSString * email = [[NSUserDefaults standardUserDefaults] stringForKey:@"MedableLoginEmail"];
            if (email != nil)
            {
                [self.loginAlertView textFieldAtIndex:0].text = email;
                [[self.loginAlertView textFieldAtIndex:1] becomeFirstResponder]; // sadly this doesn't work, need to do it in the UIAlertView's viewWillAppear: method...
            }
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CacheMedableLoginPassword"])
        {
            // the user has requested that we cache the login information for convenience
            // see if we have any cached info, and auto-login if so
            NSString * password = [[NSUserDefaults standardUserDefaults] stringForKey:@"MedableLoginPassword"]; // TO DO: does Medable support an encrypted password?
            if (password != nil)
            {
                [self.loginAlertView textFieldAtIndex:1].text = password;
            }
        }
        
        [self.loginAlertView show];
    }
}

- (void)showMedableInfoDialog:(id)sender
{
    if (!self.alertView)
    {
        NSString * message = [NSString stringWithCString:
                              "Protect your heart rate data with Medable, the world’s first HIPAA-compliant medical data service. "
                              "Create an account and log in to unlock all of the features of Biogram."
                                                encoding:NSUTF8StringEncoding];
        
        self.alertView = [[CBCMedableAlertView alloc]
                              initWithTitle:@"Medable"
                              message:NSLocalizedString(message, nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Sign Up", nil)
                              otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        
        self.alertView.type = CBCMedableAlertViewInfo;
        self.alertView.requester = sender;

        [self.alertView show];
    }
}

- (void)displayAlertWithLoginFault:(MDFault*)fault
{
    if (!self.alertView)
    {
        self.alertView = [[CBCMedableAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Login Failed", nil)
                              message:fault.text
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                              otherButtonTitles:nil];
        
        self.alertView.type = CBCMedableAlertViewLoginFault;
        self.alertView.requester = nil;
        
        // Received error on first login with no verification token
        if ([fault.code isEqualToString:kMDAPIErrorUnverifiedLocation] ||
            [fault.code isEqualToString:kMDAPIErrorNewLocation])
        {
            self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            self.alertView.message = [self.alertView.message stringByAppendingString:@"\nPlease enter verfication code:"];
            self.alertView.type = CBCMedableAlertViewPin;
            self.alertView.title = NSLocalizedString(@"Medable", nil);
        }
        
        [self.alertView show];
    }
}

- (void)displayAlertWithFault:(MDFault*)fault
{
    if (!self.alertView)
    {
        self.alertView = [[CBCMedableAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Medable Error", nil)
                          message:fault.text
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
        
        self.alertView.type = CBCMedableAlertViewFault;
        self.alertView.requester = nil;
        
        // Received error on first login with no verification token
        if ([fault.code isEqualToString:kMDAPIErrorUnverifiedLocation] ||
            [fault.code isEqualToString:kMDAPIErrorNewLocation])
        {
            self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            self.alertView.message = [self.alertView.message stringByAppendingString:@"\nPlease enter verfication code:"];
            self.alertView.type = CBCMedableAlertViewPin;
            self.alertView.title = NSLocalizedString(@"Medable", nil);
        }
        
        [self.alertView show];
    }
}

@end
