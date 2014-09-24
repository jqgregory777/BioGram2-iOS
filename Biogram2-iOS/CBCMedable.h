//
//  CBCMedable.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/20/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBCMedable : UIResponder <UIAlertViewDelegate>

+ (CBCMedable *) singleton;

- (void)showLoginDialog;
- (void)showMedableInfoDialog:(id)sender;
- (void)loginWithEmail:(NSString*)email password:(NSString*)password verificationToken:(NSString*)verificationToken;
- (void)logout;
- (BOOL)isLoggedIn;
- (void)checkForValidSession;
- (void)cacheCredentials;
- (void)displayAlertWithFault:(MDFault*)fault;

@end
