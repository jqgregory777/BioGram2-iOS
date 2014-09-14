//
//  CBCSelectPhotoController.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBCSelectPhotoController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhotoFromLibrary:(id)sender;

@end