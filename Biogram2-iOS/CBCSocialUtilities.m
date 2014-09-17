//
//  CBCSocialUtilities.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/16/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCSocialUtilities.h"
#import "CBCAppDelegate.h"
#import <Social/Social.h>

const char * g_biogramTagLine = "Posted by Biogram(TM)";

@implementation CBCSocialUtilities

enum ESocialServiceID
{
    SocialServiceIDFacebook,
    SocialServiceIDTwitter,
    SocialServiceIDMedable,

    SocialServiceIDCount
};
typedef NSInteger SocialServiceID;

+ (void)postDidComplete:(SocialServiceID)serviceId forEvent:(CBCHeartRateEvent *)heartRateEvent
{
    CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];

    switch (serviceId)
    {
        case SocialServiceIDFacebook:
            heartRateEvent.postedToFacebook = @YES;
            [appDelegate saveHeartRateEvent:heartRateEvent];
            break;
        case SocialServiceIDTwitter:
            heartRateEvent.postedToTwitter = @YES;
            [appDelegate saveHeartRateEvent:heartRateEvent];
            break;
        case SocialServiceIDMedable:
            heartRateEvent.postedToMedable = @YES;
            [appDelegate saveHeartRateEvent:heartRateEvent];
            break;
    }
}

#pragma mark - Facebook

+ (void)postToFacebook:(CBCHeartRateEvent *)heartRateEvent
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        NSString * biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString * message = [NSString stringWithFormat:@"%@\n%@", heartRateEvent.eventDescription, biogramTagLine];
        
        // OLD WAY: show a pop-up dialog to allow the user the post manually.
        //        self.slComposeViewController    = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        //        [self.slComposeViewController addImage:image];
        //        [self.slComposeViewController setInitialText:message];
        //        [self presentViewController:self.slComposeViewController animated:YES completion:NULL];

        // NEW WAY: auto-post based on the user's choices (via the green check boxes in CBCEditEventController)...
        
        ACAccountStore * fbAccountStore = [[ACAccountStore alloc] init];
        ACAccountType * fbAccountType = [fbAccountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierFacebook];
        
        // Specify App ID and permissions
        
        NSString * fbAppId = @"1538350369730665";
        NSString * fbAudienceKey = ACFacebookAudienceOnlyMe; // HACK FOR TESTING
        
        NSDictionary * optionsRead = @{
                                   ACFacebookAppIdKey: fbAppId,
                                   ACFacebookPermissionsKey: @[@"email"],
                                   ACFacebookAudienceKey: fbAudienceKey };

        // Frist ask for read permissions (email), then if that's granted ask for write (publish)...
        
        NSLog(@"FB: requesting read permissions...");

        [fbAccountStore requestAccessToAccountsWithType:fbAccountType options:optionsRead completion:
            ^(BOOL granted, NSError *error)
            {
                NSLog(@"FB: read permission completion: granted = %s", granted?"YES":"NO");
                if (granted && error == nil)
                {
                    /**
                     * The user granted us the basic read permission.
                     * Now we can ask for more permissions
                     **/
                    NSDictionary * optionsWrite = @{
                                               ACFacebookAppIdKey: fbAppId,
                                               ACFacebookPermissionsKey: @[@"publish_actions"],
                                               ACFacebookAudienceKey: fbAudienceKey };
                    
                    [fbAccountStore requestAccessToAccountsWithType:fbAccountType options:optionsWrite completion:
                        ^(BOOL granted, NSError *error)
                        {
                            NSLog(@"FB: write permission completion: granted = %s", granted?"YES":"NO");
                            if (granted && error == nil)
                            {
                                /**
                                 * We now should have some read permission
                                 * Now we may ask for write permissions or
                                 * do something else.
                                 **/
                                NSArray * accountsArray = [fbAccountStore accountsWithAccountType:fbAccountType];
                                if ([accountsArray count] > 0)
                                {
                                    ACAccount * fbAccount = [accountsArray objectAtIndex:0];
                                    
                                    NSDictionary * parameters = nil; //@{@"message": sendmessage};
                                    
                                    SLRequest * fbRequest
                                     = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                          requestMethod:SLRequestMethodPOST
                                                                    URL:[NSURL URLWithString:@"https://graph.facebook.com/me/photos"]
                                                             parameters:parameters];
                                    
                                    [fbRequest addMultipartData:heartRateEvent.photo
                                                       withName:@"source"
                                                           type:@"multipart/form-data"
                                                       filename:@"BioGramPhoto"];
                                    [fbRequest addMultipartData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                       withName:@"message"
                                                           type:@"multipart/form-data"
                                                       filename:nil];
                                    
                                    [fbRequest setAccount:fbAccount];
                                    
                                     NSLog(@"FB: performing request...");
                                     [fbRequest performRequestWithHandler:
                                         ^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error)
                                         {
                                             if (error == nil)
                                             {
                                                 NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                 NSLog(@"FB response data is: %@", responseString);
                                                 [CBCSocialUtilities postDidComplete:SocialServiceIDFacebook
                                                                            forEvent:heartRateEvent];
                                             }
                                             else
                                             {
                                                 NSLog(@"FB request failed -- error is: %@",error.description);
                                                 NSString * message = [NSString stringWithFormat:@"An error occurred while\nposting to Facebook:\n%@",
                                                                       [error description]];
                                                 [CBCAppDelegate showMessage:message withTitle:@"Posting Error"];
                                             }
                                         }
                                     ];
                                }
                                else
                                {
                                    NSLog(@"FB: no facebook accounts found");
                                    [CBCAppDelegate showMessage:@"Please configure a Facebook account in Settings." withTitle:@"No Account Found"];
                                }
                            }
                            else
                            {
                                NSLog(@"FB post not granted -- error is: %@",[error description]);
                                if (error != nil)
                                {
                                    NSString * message = [NSString stringWithFormat:@"An error occurred while\nrequesting Facebook permissions:\n%@",
                                                          [error description]];
                                    [CBCAppDelegate showMessage:message withTitle:@"Permissions Error"];
                                }
                            }
                        }
                    ];
                }
                else
                {
                    NSLog(@"FB read not granted -- error is: %@",[error description]);
                    if (error != nil)
                    {
                        NSString * message = [NSString stringWithFormat:@"An error occurred while\nrequesting Facebook permissions:\n%@",
                                              [error description]];
                        [CBCAppDelegate showMessage:message withTitle:@"Permissions Error"];
                    }
                }
            }
        ];
    }
    else
    {
        [CBCAppDelegate showMessage:@"Please configure a Facebook account in Settings." withTitle:@"No Account Found"];
    }
}

#pragma mark - Twitter

+ (void)postToTwitter:(CBCHeartRateEvent *)heartRateEvent
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString * biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString * message = [NSString stringWithFormat:@"%@\n%@", heartRateEvent.eventDescription, biogramTagLine];
//        UIImage * image = [UIImage imageWithData:heartRateEvent.photo];

        // OLD WAY
//        self.slComposeViewController    = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//        [self.slComposeViewController addImage:image];
//        [self.slComposeViewController setInitialText:message];
//        [self presentViewController:self.slComposeViewController animated:YES completion:NULL];
        
        // NEW WAY
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType options:nil
                                      completion:
            ^(BOOL granted, NSError *error)
            {
                if (granted == YES)
                {
                    // Get account and communicate with Twitter API
                    NSArray *arrayOfAccounts = [accountStore
                                                accountsWithAccountType:accountType];
                    
                    if ([arrayOfAccounts count] > 0)
                    {
                        ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                        
                        NSDictionary *parametersDict = @{@"status": message};
                        
                        NSURL *requestURL = [NSURL
                                             URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
                        
                        SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                    requestMethod:SLRequestMethodPOST
                                                                              URL:requestURL
                                                                       parameters:parametersDict];
                        
                        postRequest.account = twitterAccount;
                        
                        [postRequest performRequestWithHandler:
                            ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                             {
                                 NSLog(@"Twitter HTTP response: %i", [urlResponse statusCode]);
                             }
                        ];
                    }
                }
            }
        ];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Account Found" message:@"Please configure a Twitter account in Settings." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

#pragma mark - Medable

+ (void)postToMedable:(CBCHeartRateEvent *)heartRateEvent
{
    // Post to Medable
    MDAPIClient* apiClient = [MDAPIClient sharedClient];
    
    // Current account
    MDAccount* currentAccount = apiClient.localUser;
    if (currentAccount) // logged in?
    {
        UIImage* backgroundImage = [UIImage imageWithData:heartRateEvent.backgroundImage];
        UIImage* overlayImage = [UIImage imageWithData:heartRateEvent.overlayImage];
        
        NSString* biogramId = [currentAccount biogramId];
        
        [[MDAPIClient sharedClient]
         postHeartbeatWithBiogramId:biogramId
         heartbeat:[heartRateEvent.heartRate integerValue]
         image:backgroundImage
         overlay:overlayImage
         progress:nil
         finishBlock:
            ^(MDPost *post, MDFault *fault)
            {
                if (fault)
                {
                    CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];
                    [appDelegate displayAlertWithMedableFault:fault];
                }
                else
                {
                    [CBCSocialUtilities postDidComplete:SocialServiceIDMedable
                                               forEvent:heartRateEvent];
                }
            }];
    }
}

@end
