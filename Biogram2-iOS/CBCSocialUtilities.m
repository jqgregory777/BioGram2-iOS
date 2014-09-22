//
//  CBCSocialUtilities.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/16/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCSocialUtilities.h"
#import "CBCAppDelegate.h"
#import "CBCHeartRateFeed.h"
#import "CBCMedable.h"
#import "CBCDetailViewController.h"
#import <Social/Social.h>

const char * g_biogramTagLine = "Posted by Biogram(TM)";
BOOL g_useSLComposeViewController = YES; // waaaay easier, and it's the ONLY way to do it for Twitter AFAIK!

NSString* const kCBCSocialPostDidComplete = @"kCBCSocialPostDidComplete";

@implementation CBCSocialUtilities

+ (void)postDidComplete:(SocialServiceID)serviceId forEvent:(CBCHeartRateEvent *)heartRateEvent withPost:(MDPost *)post
{
    CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];

    switch (serviceId)
    {
        case SocialServiceIDFacebook:
            heartRateEvent.postedToFacebook = @YES;
            [feed updateHeartRateEvent:heartRateEvent];
            break;
        case SocialServiceIDTwitter:
            heartRateEvent.postedToTwitter = @YES;
            [feed updateHeartRateEvent:heartRateEvent];
            break;
        case SocialServiceIDMedable:
            heartRateEvent.postedToMedable = @YES;
            [feed updateHeartRateEvent:heartRateEvent];
            [feed didPostEvent:heartRateEvent forMedablePost:post];
            break;
    }

    NSDictionary * userInfo = @{ @"SocialServiceID" : [NSNumber numberWithInt:serviceId] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kCBCSocialPostDidComplete object:nil userInfo:userInfo];
}

#pragma mark - Facebook

+ (void)postToFacebookWithCaption:(NSString*)caption photo:(UIImage*)photo sender:(id)sender finishCallback:(void (^)())callback
{
    if (g_useSLComposeViewController)
    {
        // show a pop-up dialog to allow the user the post manually
        
        SLComposeViewController * slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [slComposeViewController addImage:photo];
        [slComposeViewController setInitialText:caption];
        slComposeViewController.completionHandler =
        ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                callback();
            }
        };
        
        [sender presentViewController:slComposeViewController animated:YES completion:nil];
    }
    else
    {
        // auto-post based on the user's choices (via the green check boxes in CBCEditEventController)...
        
        ACAccountStore* fbAccountStore = [[ACAccountStore alloc] init];
        ACAccountType* fbAccountType = [fbAccountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierFacebook];
        
        // Specify App ID and permissions
        
        NSString* fbAppId = @"1538350369730665";
        NSString* fbAudienceKey = ACFacebookAudienceOnlyMe; // HACK FOR TESTING
        
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
                              
                              [fbRequest addMultipartData:UIImagePNGRepresentation(photo)
                                                 withName:@"source"
                                                     type:@"multipart/form-data"
                                                 filename:@"BioGramPhoto"];
                              [fbRequest addMultipartData:[caption dataUsingEncoding:NSUTF8StringEncoding]
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
                                       NSString* responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                       NSLog(@"FB response data is: %@", responseString);
                                       
                                       callback();
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
}

/*
+ (void)postMDPostToFacebook:(MDPost *)heartRatePost sender:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        NSString* biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString* message = [NSString stringWithFormat:@"%@\n%@", heartRatePost.text, biogramTagLine];
        
        [heartRatePost postPicsWithUpdateBlock:^BOOL(NSString *imageId, UIImage *image, BOOL lastImage)
        {
            [CBCSocialUtilities
             postToFacebookWithCaption:message
             photo:image
             sender:sender
             finishCallback:^
             {
                 // TODO: is this needed?
//                 [CBCSocialUtilities postDidComplete:SocialServiceIDFacebook
//                                            forEvent:?? withPost:nil];
             }];
            
            return YES;
        }];
    }
    else
    {
        [CBCAppDelegate showMessage:@"Please configure a Facebook account in Settings." withTitle:@"No Account Found"];
    }
}
*/

+ (void)postToFacebook:(CBCHeartRateEvent *)heartRateEvent sender:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        NSString* biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString* message = [NSString stringWithFormat:@"%@\n%@", heartRateEvent.eventDescription, biogramTagLine];
        UIImage* photo = [UIImage imageWithData:heartRateEvent.photo];
        
        [CBCSocialUtilities
         postToFacebookWithCaption:message
         photo:photo
         sender:sender
         finishCallback:^
         {
             [CBCSocialUtilities postDidComplete:SocialServiceIDFacebook
                                        forEvent:heartRateEvent
                                        withPost:nil];
         }];
    }
    else
    {
        [CBCAppDelegate showMessage:@"Please configure a Facebook account in Settings." withTitle:@"No Account Found"];
    }
}

#pragma mark - Twitter

+ (void)postToTwitterWithCaption:(NSString*)caption photo:(UIImage*)photo sender:(id)sender finishCallback:(void (^)())callback
{
    if (g_useSLComposeViewController)
    {
        // show a pop-up dialog to allow the user the post manually
        
        SLComposeViewController * slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [slComposeViewController addImage:photo];
        [slComposeViewController setInitialText:caption];
        slComposeViewController.completionHandler =
        ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone)
            {
                callback();
            }
        };
        
        [sender presentViewController:slComposeViewController animated:YES completion:nil];
    }
    else
    {
        // auto-post based on the user's choices (via the green check boxes in CBCEditEventController)...
        
        // THIS DOES NOT WORK BECAUSE IT LACKS OAUTH AUTHORIZATION, WHICH APPEARS TO BE IMPOSSIBLE WITHOUT
        // REDIRECTING THE USER TO A WEB PAGE (THREE-LEGGED AUTH OR PIN-BASED AUTH).
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];
        
        NSLog(@"TWTR: requesting access");
        [accountStore requestAccessToAccountsWithType:accountType options:nil
                                           completion:
         ^(BOOL granted, NSError *error)
         {
             NSLog(@"FB: access completion: granted = %s", granted?"YES":"NO");
             if (granted == YES)
             {
                 // Get account and communicate with Twitter API
                 NSArray *arrayOfAccounts = [accountStore
                                             accountsWithAccountType:accountType];
                 
                 if ([arrayOfAccounts count] > 0)
                 {
                     ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                     
                     NSDictionary *parametersDict = @{@"status": caption};
                     
                     NSURL *requestURL = [NSURL
                                          URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                     
                     SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                 requestMethod:SLRequestMethodPOST
                                                                           URL:requestURL
                                                                    parameters:parametersDict];
                     
                     postRequest.account = twitterAccount;
                     
                     NSLog(@"TWTR: sending post request");
                     [postRequest performRequestWithHandler:
                      ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                      {
                          NSLog(@"TWTR: post response: %i", [urlResponse statusCode]);
                      }
                      ];
                 }
                 else
                 {
                     [CBCAppDelegate showMessage:@"Please configure a Twitter account in Settings." withTitle:@"No Account Found"];
                 }
             }
         }
         ];
    }
}

/*
+ (void)postMDPostToTwitter:(MDPost *)heartRatePost sender:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString* biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString* message = [NSString stringWithFormat:@"%@\n%@", heartRatePost.text, biogramTagLine];
        
        [heartRatePost postPicsWithUpdateBlock:^BOOL(NSString *imageId, UIImage *image, BOOL lastImage)
         {
             [CBCSocialUtilities
              postToTwitterWithCaption:message
              photo:image
              sender:sender
              finishCallback:^
              {
                  // TODO: is this needed?
                  //                  [CBCSocialUtilities postDidComplete:SocialServiceIDTwitter
                  //                                             forEvent:??? withPost:nil];
              }];
             
             return YES;
         }];
    }
    else
    {
        [CBCAppDelegate showMessage:@"Please configure a Twitter account in Settings." withTitle:@"No Account Found"];
    }
}
*/

+ (void)postToTwitter:(CBCHeartRateEvent *)heartRateEvent sender:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString* biogramTagLine = [NSString stringWithCString:g_biogramTagLine encoding:NSUTF8StringEncoding];
        NSString* message = [NSString stringWithFormat:@"%@\n%@", heartRateEvent.eventDescription, biogramTagLine];
        UIImage* photo = [UIImage imageWithData:heartRateEvent.photo];
        
        [CBCSocialUtilities
         postToTwitterWithCaption:message
         photo:photo
         sender:sender
         finishCallback:^
         {
             [CBCSocialUtilities postDidComplete:SocialServiceIDTwitter
                                        forEvent:heartRateEvent
                                        withPost:nil];
         }];
    }
    else
    {
        [CBCAppDelegate showMessage:@"Please configure a Twitter account in Settings." withTitle:@"No Account Found"];
    }
}

/*
//    Use below code to do post image and text without showing ViewContoller . This is called silent Post.

+ (void)postToTwitter:(NSDictionary *)dataDict withAccount:(ACAccount *)twitterAccount
{
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:dataDict];
    
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"icon@2x.png"]);
    
    [request addMultipartData:imageData
                     withName:@"media[]"
                         type:@"image/jpeg"
                     filename:@"image.jpg"];
    
    request.account = twitterAccount;
    
    [request performRequestWithHandler:
        ^(NSData *data, NSHTTPURLResponse *response, NSError *error)
        {
            if(!error)
            {
                NSDictionary *list =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                if(![list objectForKey:@"errors"]){
                    
                    if([list objectForKey:@"error"]!=nil){
                        
                        //Delegate For Fail
                        return;
                    }
                }
            }
        }
    ];
}

+ (void) shareOnTwitterWithMessage:(NSString *)message
{
    ACAccountStore *twitterAccountStore = [[ACAccountStore alloc]init];
    ACAccountType *TWaccountType= [twitterAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [twitterAccountStore requestAccessToAccountsWithType:TWaccountType options:nil completion:
        ^(BOOL granted, NSError *e)
        {
             if (granted)
             {
                 NSArray *accounts = [twitterAccountStore accountsWithAccountType:TWaccountType];
                 
                 ACAccount *twitterAccount = [accounts lastObject];
                 
                 NSDictionary *dataDict = @{@"status": message};
                 
                 [CBCSocialUtilities postToTwitter:dataDict withAccount:twitterAccount];
             }
             else
             {
                 return ;
             }
         }
    ];
}
*/

#pragma mark - Medable

+ (void)postToMedable:(CBCHeartRateEvent *)heartRateEvent postToPublicFeed:(BOOL)postToPublicFeed completion:(void (^)(MDPost* post, MDFault* fault))finishBlock
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
         postToPublicFeed:postToPublicFeed
         image:backgroundImage
         overlay:overlayImage
         progress:nil
         finishBlock:finishBlock];
    }
}

+ (void)postToMedable:(CBCHeartRateEvent *)heartRateEvent postToPublicFeed:(BOOL)postToPublicFeed
{
    [CBCSocialUtilities postToMedable:heartRateEvent postToPublicFeed:postToPublicFeed completion:
        ^(MDPost *post, MDFault *fault)
        {
            if (fault)
            {
                [[CBCMedable singleton] displayAlertWithFault:fault];
            }
            else
            {
                [CBCSocialUtilities postDidComplete:SocialServiceIDMedable
                                           forEvent:heartRateEvent
                                           withPost:post];
            }
        }
    ];
}

@end
