//
//  CBCSocialUtilities.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/16/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCSocialUtilities.h"
#import <Social/Social.h>

const char * g_biogramTagLine = "Posted by BioGram(TM)";

@implementation CBCSocialUtilities

+ (BOOL)postToFacebook:(CBCHeartRateEvent *)pendingEvent
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        NSString * biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString * message = [NSString stringWithFormat:@"%@\n%@", pendingEvent.eventDescription, biogramTagLine];
        
        //        self.slComposeViewController    = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        //        [self.slComposeViewController addImage:image];
        //        [self.slComposeViewController setInitialText:message];
        //        [self presentViewController:self.slComposeViewController animated:YES completion:NULL];
        
        ACAccountStore * facebookaccount = [[ACAccountStore alloc] init];
        ACAccountType * facebookaccountType = [facebookaccount accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierFacebook];
        
        // Specify App ID and permissions
        NSDictionary * options = @{
                                   ACFacebookAppIdKey: @"1234567899876543",
                                   ACFacebookPermissionsKey: @[@"publish_stream"],
                                   ACFacebookAudienceKey: ACFacebookAudienceFriends };
        
        [facebookaccount requestAccessToAccountsWithType:facebookaccountType
                                                 options:options
                                              completion:
            ^(BOOL granted, NSError *error)
            {
                if (granted)
                {
                    NSArray * accountsArray = [facebookaccount accountsWithAccountType:facebookaccountType];
                    if ([accountsArray count] > 0)
                    {
                        ACAccount * facebookAccount = [accountsArray objectAtIndex:0];

                        NSDictionary * parameters = nil; //@{@"message": sendmessage};
                        
                        SLRequest * facebookRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                         requestMethod:SLRequestMethodPOST
                                                                                   URL:[NSURL URLWithString:@"https://graph.facebook.com/me/photos"]
                                                                            parameters:parameters];

                        [facebookRequest addMultipartData:pendingEvent.photo
                                                 withName:@"source"
                                                     type:@"multipart/form-data"
                                                 filename:@"BioGramPhoto"];
                        [facebookRequest addMultipartData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                 withName:@"message"
                                                     type:@"multipart/form-data"
                                                 filename:nil];

                        [facebookRequest setAccount:facebookAccount];

                        [facebookRequest performRequestWithHandler:
                            ^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error)
                            {
                                if (error == nil)
                                {
                                    NSLog(@"responsedata:%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                                }
                                else
                                {
                                    NSLog(@"%@",error.description);
                                }
                            }
                         ];
                    }
                    else
                    {
                        NSLog(@"no facebook accounts found");
                    }
                }
                else
                {
                    NSLog(@"facebook error description : %@",[NSString stringWithFormat:@"%@", error.localizedDescription]);
                }
            }
        ];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Account Found" message:@"Configure a Facebook account in setting" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
    return YES;
}

+ (BOOL)postToTwitter:(CBCHeartRateEvent *)pendingEvent
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString * biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString * message = [NSString stringWithFormat:@"%@\n%@", pendingEvent.eventDescription, biogramTagLine];
//        UIImage * image = [UIImage imageWithData:pendingEvent.photo];
        
//        self.slComposeViewController    = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//        [self.slComposeViewController addImage:image];
//        [self.slComposeViewController setInitialText:message];
//        [self presentViewController:self.slComposeViewController animated:YES completion:NULL];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No Account Found" message:@"Configure a Twitter account in setting" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
    return YES;
}


@end
