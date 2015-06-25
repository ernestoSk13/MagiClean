//
//  UIImage+customProperties.m
//  MyCV
//
//  Created by Ernesto Sánchez Kuri on 14/08/14.
//  Copyright (c) 2014 SK Labs. All rights reserved.
//

#import "UIImage+customProperties.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (customProperties)
-(UIImage *)detectFaceInImage:(UIImageView *)imageView
{
    return nil;
}



+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
+(UIImageView *)captureBlur:(UIImageView *)imageView
{
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *currentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur
    CIImage *imageToBlur = [CIImage imageWithCGImage:currentImage.CGImage];
    CIFilter *gaussianBlur = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlur setValue:imageToBlur forKey:@"inputImage"];
    CIImage *outputImage = [gaussianBlur valueForKey:@"outputImage"];
    
    UIImage *blurredI = [[UIImage alloc]initWithCIImage:outputImage];
    
    UIImageView *newView = [[UIImageView alloc]initWithFrame:imageView.bounds];
    newView.image = blurredI;
   // newView.contentMode = UIViewContentModeCenter;
    return newView;
    
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (UIImage *)imageWithRoundCorner:(UIImage*)img andCornerSize:(CGSize)size
{
    UIImage * newImage = nil;
    
    if( nil != img)
    {
        @autoreleasepool {
            int w = img.size.width;
            int h = img.size.height;
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
            
            CGContextBeginPath(context);
            CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
            addRoundedRectToPath(context, rect, size.width, size.height);
            CGContextClosePath(context);
            CGContextClip(context);
            
            CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
            
            CGImageRef imageMasked = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            CGColorSpaceRelease(colorSpace);
            
            newImage = [UIImage imageWithCGImage:imageMasked];
            
            CGImageRelease(imageMasked);
            
        }
    }
    
    return newImage;
}
+ (UIImage *)imageWithImage:(UIImage *)image scaledToNewSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)loadImageFromDocumentDirectory:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      imageName ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+(void)saveImageToDocumentsDirectory:(UIImage *)image withName:(NSString *)imageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString:[NSString stringWithFormat:@"%@",imageName]]];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
}

@end
