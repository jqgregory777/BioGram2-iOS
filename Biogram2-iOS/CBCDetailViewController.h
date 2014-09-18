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

@property (weak, nonatomic) CBCHeartRateEvent * displayedEvent;

- (void)updateUI;

@end
