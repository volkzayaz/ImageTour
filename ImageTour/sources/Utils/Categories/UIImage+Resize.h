//
//  UIImage+Resize.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>
#warning remove all names Vlad Soroka from file headers
@interface UIImage (Resize)

- (UIImage*)proportionalResizeForSize:(CGSize)targetSize;

/**
 *  @discussion - if self is smaller and narrower than passed targetSize, than image size will be returned.
 *          Otherwise ansewer fits in given targetSize, occupying maximum space and keeping original aspect ratio
 */
- (CGSize) niceSizeToFitInSize:(CGSize)targetSize;

- (UIImage*) normalizedImage;

@end
