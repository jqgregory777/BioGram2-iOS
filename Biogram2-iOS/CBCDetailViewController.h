//
//  CBCDetailViewController.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCHeartRateEvent.h"

@interface CBCDetailViewController : UIViewController

@property (strong, nonatomic) CBCHeartRateEvent* displayedEvent;
@property (strong, nonatomic) MDPost* displayedPost;

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIButton *postToFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *postToTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *postToMedableButton;
@property (weak, nonatomic) IBOutlet UIImageView *postedToFacebookImgView;
@property (weak, nonatomic) IBOutlet UIImageView *postedToTwitterImgView;
@property (weak, nonatomic) IBOutlet UIImageView *postedToMedableImgView;

- (void)updateUI;
- (IBAction)postToFacebookTouched:(id)sender;
- (IBAction)postToTwitterTouched:(id)sender;

@end
