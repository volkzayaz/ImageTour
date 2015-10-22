//
//  VSDocument.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSTourImage.h"

@interface VSDocument : UIDocument

///Image from which tour starts
///image should also have some name string
- (VSTourImage*) initialImageForTour;

- (NSArray<VSTourImage*>*) allThumbnails;

- (VSTourImage* /*nullable*/) nextImageForTappingOnPoint:(CGPoint)point onImage:(VSTourImage*)tourImage;
- (VSTourImage*) fullScaleImageForThumbnail:(VSTourImage*)image;
- (VSTourImage*) fullScaleImageForFileKey:(NSNumber*)fileKey;

- (VSTourImage*) addImageWithImage:(UIImage*)image;

- (void) addLinkWithRect:(CGRect)linkRect fromImage:(VSTourImage*)fromImage toImage:(VSTourImage*)toImage;
- (NSArray<NSValue*>* /*CGRect*/) rectsForImage:(VSTourImage*)image;

- (void) deleteImage:(VSTourImage*)image;

@end
