//
//  CBCDetailViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCDetailViewController.h"
#import "CBCAppDelegate.h"
#import <Social/Social.h>

@interface CBCDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) SLComposeViewController *slComposeViewController;

@end

@implementation CBCDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.timeStampLabel.text = [NSDateFormatter localizedStringFromDate:self.displayedEvent.timeStamp
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    self.descriptionLabel.text = self.displayedEvent.eventDescription;
    
    UIImage* image = [UIImage imageWithData:self.displayedEvent.photo];
    if (image != nil)
    {
        self.imageView.image = image;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareToFacebook:(id)sender
{
    NSString *tempString = [NSString stringWithFormat:@"%@", _descriptionLabel.text];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        self.slComposeViewController    = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [self.slComposeViewController addImage:self.imageView.image];
        [self.slComposeViewController setInitialText:tempString];
        [self presentViewController:self.slComposeViewController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Account Found" message:@"Configure a Facebook account in setting" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

- (IBAction)shareToTwitter:(id)sender
{
    NSString *tempString = [NSString stringWithFormat:@"%@", _descriptionLabel.text];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        self.slComposeViewController    = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [self.slComposeViewController addImage:self.imageView.image];
        [self.slComposeViewController setInitialText:tempString];
        [self presentViewController:self.slComposeViewController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Account Found" message:@"Configure a Twitter account in setting" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

- (IBAction)shareToMedable:(id)sender
{
/* THIS CRASHES RIGHT NOW - LEAVING TO FER SINCE HE KNOWS THIS SDK BETTER THAN I DO...
 
    // Post to Medable
    MDAPIClient* apiClient = [MDAPIClient sharedClient];

    // Current account
    MDAccount* currentAccount = apiClient.localUser;
    if (currentAccount) // logged in?
    {
        UIImage* backgroundImage = [UIImage imageWithData:self.displayedEvent.backgroundImage];
        UIImage* overlayImage = [UIImage imageWithData:self.displayedEvent.overlayImage];

        NSString* biogramId = [currentAccount biogramId];

        [[MDAPIClient sharedClient]
         postHeartbeatWithBiogramId:biogramId
         heartbeat:[self.displayedEvent.heartRate integerValue]
         image:backgroundImage
         overlay:overlayImage
         progress:nil
         finishBlock:^(MDPost *post, MDFault *fault)
         {
             if (fault)
             {
                 CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
                 [appDelegate displayAlertWithMedableFault:fault];
             }
         }];
    }
*/
}

@end
