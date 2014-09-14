//
//  CBCImageUtilities.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/14/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCImageUtilities.h"

@implementation CBCImageUtilities

+ (UIImage *)cropImage:(UIImage *)image
{
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width != height) {
        CGFloat newDimension = MIN(width, height);
        CGFloat widthOffset = (width - newDimension) / 2;
        CGFloat heightOffset = (height - newDimension) / 2;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension, newDimension), NO, 0.0);
        [image drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
                 blendMode:kCGBlendModeCopy
                     alpha:1.];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}


// to scale images without changing aspect ratio
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    float width = newSize.width;
    float height = newSize.height;
    
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    //indent in case of width or height difference
    float offset = (width - height) / 2;
    if (offset > 0) {
        rect.origin.y = offset;
    }
    else {
        rect.origin.x = -offset;
    }
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

+ (UIImage *)addText:(UIImage *)img text:(NSString *)text1
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    int pw, ph, fontsize;
    
    //    if (w < 612) {
    //        pw = 125;
    //        ph = 45;
    //        fontsize = 35;
    //        NSLog(@"w < 612");
    //    } else {
    //        pw = 250;
    //        ph = 90;
    //        fontsize = 70;
    //
    //    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    //UIGraphicsBeginImageContext(CGSizeMake(w, h));
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)(kCGImageAlphaPremultipliedFirst & kCGBitmapAlphaInfoMask);
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, bitmapInfo);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context, 0.0, 1.0, 1.0, 1);
    if (text1 == NULL) {
        text1 = @"00";
    }
    char* text = (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];
    //NSLog(@"text1 = %@", text1);
    
    if (strlen(text) == 1) {
        pw = 125/1.35;
        ph = 45/0.65;
        //fontsize = 35;
        fontsize = 50;
    }
    else if (strlen(text) == 2) {
        pw = 125/1.17;
        ph = 45/0.65;
        //fontsize = 35;
        fontsize = 50;
    }
    else if (strlen(text) == 3) {
        pw = 125/1.03;
        ph = 45/0.65;
        //fontsize = 35;
        fontsize = 50;
    }
    else {
        // handle abnormal case
        pw = 125;
        ph = 45;
        fontsize = 35;
    }
    
    CGContextSelectFont(context, "Avenir-Black", fontsize, kCGEncodingMacRoman);
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 255, 255, 255, 1.0);
    
    CGContextShowTextAtPoint(context, w-pw, ph, text, strlen(text));
    
    
    //Create image ref from the context
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    //UIGraphicsEndImageContext();
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return [UIImage imageWithCGImage:imageMasked];
}

+ (UIImage *)generatePhoto:(UIImage *)backgroundImage frame:(CGRect)backgroundFrame
                 watermark:(UIImage *)watermarkImage watermarkFrame:(CGRect)watermarkFrame;
{
    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    //[watermarkImage drawInRect:CGRectMake(backgroundImage.size.width - watermarkImage.size.width - 10, backgroundImage.size.height - watermarkImage.size.height - 10, watermarkImage.size.width, watermarkImage.size.height)];
    [watermarkImage drawInRect:CGRectMake((watermarkFrame.origin.x - backgroundFrame.origin.x)*2, (watermarkFrame.origin.y - backgroundFrame.origin.y)*2, watermarkImage.size.width, watermarkImage.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

@end
