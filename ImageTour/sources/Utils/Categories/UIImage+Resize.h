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
 *  @discussion - if image is smaller and narrower than passed size, than image size will be returned.
 *          Otherwise size will be calculated to fit in given size, occupy maximum space and keep aspect ratio
 */
- (CGSize) niceSizeToFitInSize:(CGSize)size;

/// fix our png represented images in terms of rotation
- (UIImage*) normalizedImage;

@end
