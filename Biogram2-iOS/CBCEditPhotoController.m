//
//  CBCEditPhotoController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/14/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCEditPhotoController.h"
#import "CBCAppDelegate.h"
#import "CBCHeartRateEvent.h"
#import "CBCImageUtilities.h"

@interface CBCEditPhotoController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *overlayImageView;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;

@end

@implementation CBCEditPhotoController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    [super viewDidLoad];
    [self registerForKeyboardNotifications];

    // retrieve the pending heart rate event
    CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
    CBCHeartRateEvent *pendingEvent = appDelegate.pendingHeartRateEvent;
    
    // crop image to a square
    UIImage *croppedImage = [CBCImageUtilities cropImage:appDelegate.pendingRawImage];
    
    CGSize size = CGSizeMake(self.backgroundImageView.frame.size.width*2,self.backgroundImageView.frame.size.height*2);
    
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
    self.backgroundImageView.image = backgroundImage;

    self.timeStampLabel.text = [pendingEvent timeStampAsString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pan Gesture Recognizer

- (IBAction)handlePan:(id)sender {
    
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
    
    //    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
    //        CGPoint nextPoint = [recognizer translationInView:self.view];
    //        CGPoint currentPoint = self.watermarkImageView.center;
    //
    //        currentPoint.x += nextPoint.x;
    //        currentPoint.y += nextPoint.y;
    //
    //        self.watermarkImageView.center = currentPoint;
    //
    //        [recognizer setTranslation:CGPointZero inView:self.view];
    //    }
    //
    //    if (recognizer.state == UIGestureRecognizerStateEnded) {
    //        self.watermarkImageView.center = originalPoint;
    //        [recognizer setTranslation:CGPointZero inView:self.view];
    //    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint currentPoint = self.overlayImageView.center;
    
    currentPoint.x += translation.x;
    currentPoint.y += translation.y;
    
    CGRect bounds = CGRectMake(self.backgroundImageView.frame.origin.x + self.overlayImageView.frame.size.width/2,self.backgroundImageView.frame.origin.y + self.overlayImageView.frame.size.height/2,self.backgroundImageView.frame.size.width - self.overlayImageView.frame.size.width,self.backgroundImageView.frame.size.height - self.overlayImageView.frame.size.height);
    
    if (CGRectContainsPoint(bounds, currentPoint)) {
        // Point lies inside the bounds
        self.overlayImageView.center = currentPoint;
    }
    
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    
    //    CGPoint translation = [recognizer translationInView:self.view];
    //    CGRect recognizerFrame = self.watermarkImageView.frame;
    //
    //    recognizerFrame.origin.x += translation.x;
    //    recognizerFrame.origin.y += translation.y;
    //
    //    // Check if UIImageView is completely inside its superView
    //    if (CGRectContainsRect(self.imageView.bounds, recognizerFrame)) {
    //        recognizer.view.frame = recognizerFrame;
    //    }
    //    // Else check if UIImageView is vertically and/or horizontally outside of its
    //    // superView. If yes, then set UImageView's frame accordingly.
    //    // This is required so that when user pans rapidly then it provides smooth translation.
    //    else {
    //        // Check vertically
    //        if (recognizerFrame.origin.y < self.imageView.bounds.origin.y) {
    //            recognizerFrame.origin.y = 0;
    //        }
    //        else if (recognizerFrame.origin.y + recognizerFrame.size.height > self.imageView.bounds.size.height) {
    //            recognizerFrame.origin.y = self.imageView.bounds.size.height - recognizerFrame.size.height;
    //        }
    //
    //        // Check horizantally
    //        if (recognizerFrame.origin.x < self.imageView.bounds.origin.x) {
    //            recognizerFrame.origin.x = 0;
    //        }
    //        else if (recognizerFrame.origin.x + recognizerFrame.size.width > self.imageView.bounds.size.width) {
    //            recognizerFrame.origin.x = self.imageView.bounds.size.width - recognizerFrame.size.width;
    //        }
    //    }
    //    
    //    // Reset translation so that on next pan recognition
    //    // we get correct translation value
    //    [recognizer setTranslation:CGPointZero inView:self.view];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

#pragma mark - Done Button

- (IBAction)keyboardDoneButtonTouched:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)saveButtonTouched:(id)sender
{
    CBCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    CBCHeartRateEvent *pendingEvent = appDelegate.pendingHeartRateEvent;
    
    // set the remaining attributes (the other attributes like timeStamp and heartRate were set by prior controllers in the sequence)
    pendingEvent.eventDescription = self.captionTextField.text; // whatever the user types in
    
    UIImage* backgroundImage = self.backgroundImageView.image;
    UIImage* overlayImage = self.overlayImageView.image;
    
    pendingEvent.backgroundImage = UIImagePNGRepresentation(backgroundImage);
    pendingEvent.overlayImage = UIImagePNGRepresentation(self.overlayImageView.image);

    // present image
    self.backgroundImageView.image = [CBCImageUtilities generatePhoto:backgroundImage
                                                                frame:self.backgroundImageView.frame
                                                            watermark:overlayImage
                                                       watermarkFrame:self.overlayImageView.frame];

    NSData * photoData = UIImagePNGRepresentation(self.backgroundImageView.image);
    pendingEvent.photo = photoData;
    
    if ([appDelegate savePendingHeartRateEvent])
    {
// NO -- post to medable only from the Details view page via the PostToMedable button, just like posting to Facebook (right?)
//        // ----------------------------------------------------------------------------------------------------
//        // Post to Medable
//        MDAPIClient* apiClient = [MDAPIClient sharedClient];
//        
//        // Current account
//        MDAccount* currentAccount = apiClient.localUser;
//        if (currentAccount) // logged in?
//        {
//            NSString* biogramId = [currentAccount biogramId];
//            
//            [[MDAPIClient sharedClient]
//             postHeartbeatWithBiogramId:biogramId
//             heartbeat:[self.heartRate integerValue]
//             image:backgroundImage
//             overlay:overlay
//             progress:nil
//             finishBlock:^(MDPost *post, MDFault *fault)
//             {
//                 if (fault)
//                 {
//                     [[JSDAppDelegate appDelegate] displayAlertWithFault:fault];
//                 }
//             }];
//        }
    }

    [self performSegueWithIdentifier:@"unwindToCreateHeartRateEventSegue" sender:self];
}

@end
