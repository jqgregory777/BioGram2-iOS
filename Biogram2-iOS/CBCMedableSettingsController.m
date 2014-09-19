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


@interface CBCMedableSettingsController ()

@property (weak, nonatomic) IBOutlet UISwitch *cacheLoginEmailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cacheLoginPasswordSwitch;

@end

@implementation CBCMedableSettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    self.cacheLoginEmailSwitch.on = [defaults boolForKey:@"CacheMedableLoginEmail"];
    self.cacheLoginPasswordSwitch.on = [defaults boolForKey:@"CacheMedableLoginPassword"];
}

#pragma mark - Navigation

- (IBAction)switchDidChange:(id)sender
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL cacheLoginEmail = self.cacheLoginEmailSwitch.on;
    BOOL cacheLoginPassword = self.cacheLoginPasswordSwitch.on;

    [defaults setBool:cacheLoginEmail forKey:@"CacheMedableLoginEmail"];
    [defaults setBool:cacheLoginPassword forKey:@"CacheMedableLoginPassword"];

    if (!cacheLoginEmail)
    {
        [defaults setObject:nil forKey:@"MedableLoginEmail"];
    }
    if (!cacheLoginPassword)
    {
        [defaults setObject:nil forKey:@"MedableLoginPassword"];
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
