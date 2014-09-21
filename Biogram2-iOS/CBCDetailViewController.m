//
//  CBCDetailViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCDetailViewController.h"
#import "CBCHeartRateFeed.h"
#import "CBCAppDelegate.h"
#import "CBCSocialUtilities.h"

@interface CBCDetailViewController ()

- (void)updateUI:(NSNotification *)notification;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.displayedEvent == nil)
    {
        // if no one explicitly set my displayed event, assume we're editing the pending event
        CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];
        self.displayedEvent = [feed pendingHeartRateEvent];
    }
    NSAssert(self.displayedEvent != nil, @"CBCDetailViewController: self.displayedEvent == nil");
    
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateUI:) name:kCBCSocialPostDidComplete object:nil];
    
    [self updateUI:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:kCBCSocialPostDidComplete object:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)updateUI:(NSNotification *)notification
{
    NSAssert(self.displayedEvent != nil, @"CBCDetailViewController: self.displayedEvent == nil");

    self.postedToFacebookImgView.hidden = !self.displayedEvent.postedToFacebook.boolValue;
    self.postedToTwitterImgView.hidden = !self.displayedEvent.postedToTwitter.boolValue;
    self.postedToMedableImgView.hidden = !self.displayedEvent.postedToMedable.boolValue;
    
    self.postToFacebookButton.enabled = ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] && !(self.displayedEvent.postedToFacebook.boolValue));
    self.postToTwitterButton.enabled = ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] && !(self.displayedEvent.postedToTwitter.boolValue));
    self.postToMedableButton.enabled = NO;

    self.timeStampLabel.text = self.displayedEvent.timeStampAsString;
    self.captionLabel.text = self.displayedEvent.eventDescription;
    
    UIImage* image = [UIImage imageWithData:self.displayedEvent.photo];
    if (image != nil)
    {
        self.photoImageView.image = image;
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
    NSAssert(self.displayedEvent != nil, @"CBCDetailViewController: self.displayedEvent == nil");
    [CBCSocialUtilities postToFacebook:self.displayedEvent sender:self];
}

- (IBAction)postToTwitterTouched:(id)sender
{
    NSAssert(self.displayedEvent != nil, @"CBCDetailViewController: self.displayedEvent == nil");
    [CBCSocialUtilities postToTwitter:self.displayedEvent sender:self];
}

@end
