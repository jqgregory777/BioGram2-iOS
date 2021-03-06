//
//  CBCEditPhotoController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/14/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCEditPhotoController.h"
#import "CBCAppDelegate.h"
#import "CBCMedable.h"
#import "CBCHeartRateEvent.h"
#import "CBCHeartRateFeed.h"
#import "CBCImageUtilities.h"
#import "CBCSocialUtilities.h"

#import <Social/Social.h>

@interface CBCEditPhotoController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *postToMedableLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *feedTypeSegmented;

- (IBAction)feedTypeChanged:(id)sender;

@end

@implementation CBCEditPhotoController

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    self.displayedEvent = nil;
    
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    
    // retrieve the pending heart rate event
    CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];
    CBCHeartRateEvent * pendingEvent = [feed pendingHeartRateEvent];
    
    // crop image to a square
    UIImage *croppedImage = [CBCImageUtilities cropImage:feed.pendingRawImage];
    
    CGSize size = CGSizeMake(self.photoImageView.frame.size.width*2,self.photoImageView.frame.size.height*2);
    
    UIImage *scaledImage = [CBCImageUtilities scaleImage:croppedImage toSize:size];
    
    // resize watermark - delete later
    //CGSize targetSize = CGSizeMake(size.width/4,size.height/4);
    //UIImage *watermark = [self scaleImage:[UIImage imageNamed:@"watermark.png"] toSize:targetSize];
    
    // add watermark
    UIImage *backgroundImage = scaledImage;
    UIImage *watermark = [UIImage imageNamed:@"watermark_heart"];
    
    // add text to watermark
    UIImage *watermarkImage = [CBCImageUtilities addText:watermark text:pendingEvent.heartRate];
    
    self.overlayImageView.image = watermarkImage;
    self.photoImageView.image = backgroundImage;
    
    // Overlay initial position and size
    NSUInteger overlaySquareSideSize = 77;
    NSUInteger overlayOffsetFromPicture = 10;
    
    self.overlayImageView.frame = CGRectMake(self.photoImageView.frame.origin.x + self.photoImageView.frame.size.width - (overlaySquareSideSize + overlayOffsetFromPicture),
                                             self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height - (overlaySquareSideSize + overlayOffsetFromPicture),
                                             overlaySquareSideSize,
                                             overlaySquareSideSize);

    self.timeStampLabel.text = [pendingEvent timeStampAsString];

    self.displayedEvent = pendingEvent;
    NSLog(@"CBCEditPhotoController: viewDidLoad: pendingEvent.heartRate = %@", pendingEvent.heartRate);
    
    // update UI based on whether user is logged in to Medable or not
    // we don't need an NSNotification because if the user logs in or out,
    // the feed changes, and any pending heart rate event is canceled anyway
    BOOL isLoggedIn = [[CBCMedable singleton] isLoggedIn];
    self.postToMedableLabel.enabled = isLoggedIn;
    self.feedTypeSegmented.enabled = isLoggedIn;

    if (isLoggedIn)
    {
        self.feedTypeSegmented.selectedSegmentIndex = self.displayedEvent.medableFeedType.integerValue;
    }
    else
    {
        self.feedTypeSegmented.selectedSegmentIndex = 0;
    }
}

- (void)medableLoggedInDidChange:(NSNotification *)notification
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Pan Gesture Recognizer

- (IBAction)handlePan:(id)sender
{
    UIPanGestureRecognizer* recognizer = (UIPanGestureRecognizer*)sender;
    
    CGPoint touchLocation = [recognizer locationInView:self.view];
    
    CGRect bounds = CGRectMake(self.photoImageView.frame.origin.x + self.overlayImageView.frame.size.width/2,
                               self.photoImageView.frame.origin.y + self.overlayImageView.frame.size.height/2,
                               self.photoImageView.frame.size.width - self.overlayImageView.frame.size.width,
                               self.photoImageView.frame.size.height - self.overlayImageView.frame.size.height);
    
    if (CGRectContainsPoint(bounds, touchLocation))
    {
        CGPoint touchTranslatedToUpperLeftCorner = CGPointMake(touchLocation.x - self.overlayImageView.frame.size.width/2,
                                                               touchLocation.y - self.overlayImageView.frame.size.height/2);
        
        CGRect overlayFrame = self.overlayImageView.frame;
        overlayFrame.origin = touchTranslatedToUpperLeftCorner;
        self.overlayImageView.frame = overlayFrame;
    }
}

#pragma mark - Keyboard/View Management

- (void)keyboardWasShown:(NSNotification*)notification
{
    //[self.view removeConstraints:self.view.constraints]; // do this to prevent the overlayImageView from getting reset whenever we scroll
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.captionTextField.frame.origin) )
    {
        CGPoint scrollPoint = CGPointMake(0.0, self.captionTextField.frame.origin.y - kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    // How do I get it to animate back into position?
    //CGPoint scrollPoint = CGPointMake(0.0, 0.0);
    //[self.scrollView setContentOffset:scrollPoint animated:YES];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)keyboardDoneButtonTouched:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - Post Private/Public

- (IBAction)feedTypeChanged:(id)sender
{
    CBCFeedType type = (CBCFeedType)self.feedTypeSegmented.selectedSegmentIndex;
    self.displayedEvent.medableFeedType = [NSNumber numberWithInteger:type];
    NSLog(@"]] changed Medable feed type to %@", [CBCFeed typeAsString:type]);
}

#pragma mark - Save Button

- (void)updatePendingEventFromUI
{
    // set the remaining attributes (the other attributes like timeStamp and heartRate were set by prior controllers in the sequence)
    self.displayedEvent.eventDescription = self.captionTextField.text; // whatever the user types in
    
    UIImage* backgroundImage = self.photoImageView.image;
    UIImage* overlayImage = self.overlayImageView.image;
    
    self.displayedEvent.backgroundImage = UIImagePNGRepresentation(backgroundImage);
    
    // present image
    NSArray* generatedImages = [CBCImageUtilities generatePhoto:backgroundImage
                                                          frame:self.photoImageView.frame
                                                      watermark:overlayImage
                                                 watermarkFrame:self.overlayImageView.frame];

    UIImage* compositedImage        = (UIImage*)generatedImages[0];
    UIImage* compositedOverlayImage = (UIImage*)generatedImages[1];
    
    NSData * photoData = UIImagePNGRepresentation(compositedImage);
    self.displayedEvent.photo = photoData;
    
    NSData * overlayData = UIImagePNGRepresentation(compositedOverlayImage);
    self.displayedEvent.overlayImage = overlayData;

    // HACK: I couldn't figure out how to override setPhoto: to automatically nil this out!
    // But this is the ONLY place we set the photo, so screw it - just do it here.
    self.displayedEvent.thumbnail = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self updatePendingEventFromUI];
    
    CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];
    if ([feed savePendingHeartRateEvent])
    {
        // yay
    }
    else
    {
        [CBCAppDelegate showMessage:@"Unable to save event to Core Data." withTitle:@"Save Failure"];
    }

    CBCDetailViewController * controller = [segue destinationViewController];
    controller.displayedEvent = self.displayedEvent;

    NSLog(@"CBCEditPhotoController: prepareForSegue: self.displayedEvent.heartRate = %@", self.displayedEvent.heartRate);
}

@end
