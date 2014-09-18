//
//  CBCDetailViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCDetailViewController.h"
#import "CBCAppDelegate.h"
#import "CBCSocialUtilities.h"

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
    CBCAppDelegate * appDelegate = [CBCAppDelegate appDelegate];
    appDelegate.detailViewController = self;
    
    [super viewDidLoad];

    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateUI) name:kCBCSocialPostDidComplete object:nil];

    [self updateUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    CBCAppDelegate * appDelegate = [CBCAppDelegate appDelegate];
    appDelegate.detailViewController = nil;
    
    [super viewWillDisappear:animated];
}

- (void)updateUI
{
    self.postedToFacebookImgView.hidden = !self.displayedEvent.postedToFacebook.boolValue;
    self.postedToTwitterImgView.hidden = !self.displayedEvent.postedToTwitter.boolValue;
    self.postedToMedableImgView.hidden = !self.displayedEvent.postedToMedable.boolValue;
    
    self.postToFacebookButton.enabled = ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] && !(self.displayedEvent.postedToFacebook.boolValue));
    self.postToTwitterButton.enabled = ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && !(self.displayedEvent.postedToTwitter.boolValue));
    self.postToMedableButton.enabled = ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && !(self.displayedEvent.postedToMedable.boolValue));
    
    if (self.displayedEvent)
    {
        self.timeStampLabel.text = self.displayedEvent.timeStampAsString;
        self.captionLabel.text = self.displayedEvent.eventDescription;
        
        UIImage* image = [UIImage imageWithData:self.displayedEvent.photo];
        if (image != nil)
        {
            self.photoImageView.image = image;
        }
    }
    else if (self.displayedPost)
    {
        NSUInteger heartbeat = 0;
        
        NSArray* body = [self.displayedPost body];
        for (NSDictionary* bodyDict in body)
        {
            NSString* segmentType = [bodyDict objectForKey:kTypeKey];
            if ([segmentType isEqualToString:kIntegerKey])
            {
                NSNumber* heartbeatNumber = [bodyDict objectForKey:kValueKey];
                heartbeat = [heartbeatNumber unsignedIntegerValue];
            }
        }
        
        self.timeStampLabel.text = [NSDateFormatter
                                    localizedStringFromDate:self.displayedPost.created
                                    dateStyle:NSDateFormatterMediumStyle
                                    timeStyle:NSDateFormatterShortStyle];
        
        self.captionLabel.text = self.displayedPost.text;
        
        __weak typeof (self) wSelf = self;
        
        [self.displayedPost postPicsWithUpdateBlock:^BOOL(NSString *imageId, UIImage *image, BOOL lastImage)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                wSelf.photoImageView.image = image;
                            });
             
             return YES;
         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Posting (aka Sharing)

- (IBAction)postToFacebookTouched:(id)sender
{
    if (self.displayedEvent)
    {
        [CBCSocialUtilities postToFacebook:self.displayedEvent sender:self];
    }
}

- (IBAction)postToTwitterTouched:(id)sender
{
    if (self.displayedEvent)
    {
        [CBCSocialUtilities postToTwitter:self.displayedEvent sender:self];
    }
}

- (IBAction)postToMedableTouched:(id)sender
{
    if (self.displayedEvent)
    {
        [CBCSocialUtilities postToMedable:self.displayedEvent sender:self];
    }
}

@end
