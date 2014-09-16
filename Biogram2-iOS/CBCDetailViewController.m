//
//  CBCDetailViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCDetailViewController.h"
#import "CBCAppDelegate.h"

@interface CBCDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postedToFacebookImgView;
@property (weak, nonatomic) IBOutlet UIImageView *postedToTwitterImgView;
@property (weak, nonatomic) IBOutlet UIImageView *postedToMedableImgView;

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
    
    self.timeStampLabel.text = [NSDateFormatter localizedStringFromDate:self.displayedEvent.timeStamp
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    self.descriptionLabel.text = self.displayedEvent.eventDescription;
    
    UIImage* image = [UIImage imageWithData:self.displayedEvent.photo];
    if (image != nil)
    {
        self.imageView.image = image;
    }
    
    self.postedToFacebookImgView.hidden = !self.displayedEvent.postedToFacebook.boolValue;
    self.postedToTwitterImgView.hidden = !self.displayedEvent.postedToTwitter.boolValue;
    self.postedToMedableImgView.hidden = !self.displayedEvent.postedToMedable.boolValue;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
