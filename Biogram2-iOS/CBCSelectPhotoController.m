//
//  CBCSelectPhotoController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCSelectPhotoController.h"
#import "CBCAppDelegate.h"
#import "CBCHeartRateEvent.h"

@interface CBCSelectPhotoController ()

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;

@end

@implementation CBCSelectPhotoController

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

    CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.timeStampLabel.text = [appDelegate.pendingHeartRateEvent timeStampAsString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)takePhoto:(id)sender
{
    // safe check - simulator doesn't like camera source
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController*  imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; // use camera
        [self presentViewController: imagePicker animated:YES completion:nil];
    }
}

- (IBAction)selectPhotoFromLibrary:(id)sender
{
    UIImagePickerController*  imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // use library
    [self presentViewController: imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];

    CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // extract the raw image from the info dict and cache it in the pending heart rate event
    // for processing by the CBCEditPhotoController page
    appDelegate.pendingRawImage = [info valueForKey:UIImagePickerControllerEditedImage];
    
    // move to the next and final page in the creation sequence
    [self performSegueWithIdentifier:@"editPhotoAndCaptionSegue" sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // just stay on this page
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
