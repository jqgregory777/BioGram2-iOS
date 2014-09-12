//
//  CBCMedableCreateAccountController.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBCMedableCreateAccountController;

@interface CBCMedableCreateAccountController : UITableViewController <UITextFieldDelegate>

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end