//
//  VSImageTourMapData.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit.UIImage;

@interface VSImageTourMapData : NSObject <NSCoding>

/**
 *  @returns - index of image that is initial fro this image tour
 */
- (NSNumber*) initialIndex;

/**
 *  @discussion - method stores appropriate metadata to register passed image.
 *  @returns - unique fileKey image index. Can be used to name images. This index is to be used in all other methods of this class as an input
 */
- (NSNumber*) registerNewImage:(UIImage*)image;
- (void) unregisterImageForFileKey:(NSNumber*) key;


- (NSArray<NSNumber*>*) availableImageIndexes;

- (NSNumber*) fileIndexForPoint:(CGPoint)point onIndex:(NSNumber*)index;

- (void) registerRect:(CGRect)rect originIndex:(NSNumber*)originIndex destinationIndex:(NSNumber*)destIndex;

- (NSArray<NSValue*>*) rectsForOriginIndex:(NSNumber*) index;

@end
