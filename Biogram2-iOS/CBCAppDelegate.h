//
//  CBCAppDelegate.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBCHeartRateEvent.h"
#import "AliveHMViewController.h"

extern NSString* const kCBCActivityDidStart;
extern NSString* const kCBCActivityDidStop;

@interface CBCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (CBCAppDelegate*)appDelegate;

#pragma mark - Utilities

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title;

@end
