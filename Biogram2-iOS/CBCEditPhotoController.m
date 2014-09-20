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
#import "CBCImageUtilities.h"
#import "CBCSocialUtilities.h"

#import <Social/Social.h>

@interface CBCEditPhotoController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;

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
    CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];
    CBCHeartRateEvent *pendingEvent = appDelegate.pendingHeartRateEvent;
    
    // crop image to a square
    UIImage *croppedImage = [CBCImageUtilities cropImage:appDelegate.pendingRawImage];
    
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

    self.timeStampLabel.text = [pendingEvent timeStampAsString];

    self.displayedEvent = pendingEvent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pan Gesture Recognizer

- (IBAction)handlePan:(id)sender
{
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint currentPoint = self.overlayImageView.center;
    
    currentPoint.x += translation.x;
    currentPoint.y += translation.y;
    
    CGRect bounds = CGRectMake(self.photoImageView.frame.origin.x + self.overlayImageView.frame.size.width/2,self.photoImageView.frame.origin.y + self.overlayImageView.frame.size.height/2,self.photoImageView.frame.size.width - self.overlayImageView.frame.size.width,self.photoImageView.frame.size.height - self.overlayImageView.frame.size.height);
    
    if (CGRectContainsPoint(bounds, currentPoint)) {
        // Point lies inside the bounds
        self.overlayImageView.center = currentPoint;
    }
    
    [recognizer setTranslation:CGPointZero inView:self.view];
}

#pragma mark - Keyboard/View Management

- (void)keyboardWasShown:(NSNotification*)notification
{
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

#pragma mark - Posting (aka Sharing)

- (void)updateUI
{
    // nothing to customize here (yet)
    [super updateUI];
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
    
    CBCAppDelegate * appDelegate = [CBCAppDelegate appDelegate];
    if ([appDelegate savePendingHeartRateEvent])
    {
        // yay
    }
    else
    {
        [CBCAppDelegate showMessage:@"Unable to save event to Core Data." withTitle:@"Save Failure"];
    }

    if ([[CBCMedable singleton] isLoggedIn])
    {
        // when in medable mode, we never save to Core Data, so clean up the pending object
        [[CBCAppDelegate appDelegate] cancelPendingHeartRateEvent];
    }

    CBCDetailViewController * controller = [segue destinationViewController];
    controller.displayedEvent = self.displayedEvent;
}

@end
