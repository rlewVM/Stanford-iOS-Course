//
//  UIImage+Photomania.m
//  Photomania
//
//  Created by Rachel Lew on 3/12/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "UIImage+Photomania.h"

@implementation UIImage (Photomania)

- (UIImage *)imageByScalingToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName
{
    UIImage *filteredImage = self;
    CIImage *inputImage = [CIImage imageWithCGImage:[self CGImage]];
    if (inputImage) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        CIImage *outputImage = [filter outputImage];
        if (outputImage) {
            filteredImage = [UIImage imageWithCIImage:outputImage];
            if (filteredImage) {
                UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
                [filteredImage drawAtPoint:CGPointZero];
                filteredImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }
    
    return filteredImage;
}

@end
