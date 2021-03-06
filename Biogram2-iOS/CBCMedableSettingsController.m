//
//  CBCMedableSettingsController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCMedableSettingsController.h"
#import "CBCAppDelegate.h"
#import "EXTPhoneNumberFormatter.h"
#import "CBCMedableMainTableViewController.h"
#import "CBCMedable.h"


@interface CBCMedableSettingsController ()

@property (weak, nonatomic) IBOutlet UISwitch *cacheLoginEmailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cacheLoginPasswordSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoLoginSwitch;

@end

@implementation CBCMedableSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL cacheLoginEmail = [defaults boolForKey:@"CacheMedableLoginEmail"];
    BOOL cacheLoginPassword = [defaults boolForKey:@"CacheMedableLoginPassword"];
    
    BOOL allowAutoLogin = (cacheLoginEmail && cacheLoginPassword);
    
    BOOL autoLogin = [defaults boolForKey:@"MedableAutoLogin"];
    if (!allowAutoLogin)
    {
        autoLogin = NO;
        [defaults setBool:NO forKey:@"MedableAutoLogin"];
    }

    self.cacheLoginEmailSwitch.on = cacheLoginEmail;
    self.cacheLoginPasswordSwitch.on = cacheLoginPassword;
    self.autoLoginSwitch.on = autoLogin;
}

#pragma mark - Navigation

- (IBAction)switchDidChange:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL cacheLoginEmail = self.cacheLoginEmailSwitch.on;
    BOOL cacheLoginPassword = self.cacheLoginPasswordSwitch.on;
    BOOL autoLogin = self.autoLoginSwitch.on;
    
    BOOL allowAutoLogin = (cacheLoginEmail && cacheLoginPassword);
    if (!allowAutoLogin)
    {
        self.autoLoginSwitch.on = NO;
        autoLogin = NO;
    }
    self.autoLoginSwitch.enabled = allowAutoLogin;
    
    [defaults setBool:cacheLoginEmail forKey:@"CacheMedableLoginEmail"];
    [defaults setBool:cacheLoginPassword forKey:@"CacheMedableLoginPassword"];
    [defaults setBool:autoLogin forKey:@"MedableAutoLogin"];

    [[CBCMedable singleton] cacheCredentials];
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
