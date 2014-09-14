//
//  CBCImageUtilities.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/14/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBCImageUtilities : NSObject

+ (UIImage *)cropImage:(UIImage *)image;
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
+ (UIImage *)addText:(UIImage *)img text:(NSString *)text1;
+ (UIImage *)generatePhoto:(UIImage *)backgroundImage frame:(CGRect)backgroundFrame watermark:(UIImage *)watermarkImage watermarkFrame:(CGRect)watermarkFrame;

@end
