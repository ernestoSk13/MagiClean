//
//  UIImage+customProperties.h
//  MyCV
//
//  Created by Ernesto Sánchez Kuri on 14/08/14.
//  Copyright (c) 2014 SK Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreImage;
@interface UIImage (customProperties)

-(UIImage *)detectFaceInImage: (UIImage *)image;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToNewSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImageView *)captureBlur:(UIImageView *)imageView;
+ (UIImage *)imageWithRoundCorner:(UIImage*)img andCornerSize:(CGSize)size;
+ (UIImage*)loadImageFromDocumentDirectory:(NSString *)imageName;

+(void)saveImageToDocumentsDirectory:(UIImage *)image withName:(NSString *)imageName;

@end
