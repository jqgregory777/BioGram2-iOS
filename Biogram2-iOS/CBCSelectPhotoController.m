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
    
    self.timeStampLabel.text = [appDelegate.pendingHeartRateEvent.timeStamp descriptionWithLocale:[NSLocale currentLocale]];
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
    
}

- (IBAction)selectPhotoFromLibrary:(id)sender
{
    
}

@end
