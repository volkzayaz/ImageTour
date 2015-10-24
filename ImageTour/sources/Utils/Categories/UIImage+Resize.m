//
//  UIImage+Resize.m
//  ImageTour
//
//  Created by 286 on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage*)proportionalResizeForSize:(CGSize)targetSize {
    
    CGFloat aspectRatio = (float) self.size.width / (float) self.size.height;
    
    CGFloat targetHeight = targetSize.height;
    CGFloat scaledWidth = targetSize.height * aspectRatio;
    CGFloat targetWidth = (targetSize.width < scaledWidth) ? targetSize.width : scaledWidth;
    
    return [self imageByScalingAndCroppingForSize:CGSizeMake(targetWidth, targetHeight)];
    
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth  = ceil(width * scaleFactor);
        scaledHeight = ceil(height * scaleFactor);
        
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (CGSize)niceSizeToFitInSize:(CGSize)size
{
    CGSize imageSize = self.size;
    CGSize viewSize = size;
    
    if(imageSize.width > viewSize.width ||
       imageSize.width > viewSize.height)
    {
        CGFloat aspectRatio = imageSize.width / imageSize.height;
        
        CGFloat difference = (imageSize.width - viewSize.width) - (imageSize.height - viewSize.height);
        CGFloat newWidth = 0;
        CGFloat newHeight = 0;
        if(difference > 0) // image is wider than taller relating to given size
        {
            newWidth = viewSize.width;
            newHeight = newWidth / aspectRatio;
        }
        else// image is taller than wider relating to view
        {
            newHeight = viewSize.height;
            newWidth = newHeight * aspectRatio;
        }
        
        imageSize = (CGSize){newWidth, newHeight};
    }
    
    return imageSize;
}

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}


@end
