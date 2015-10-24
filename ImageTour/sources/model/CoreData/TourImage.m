//
//  TourImage.m
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "TourImage.h"
#import "FullImage.h"
#import "ImageLink.h"

@implementation TourImage

- (UIImage*) image
{
    return [[UIImage alloc] initWithData:self.thumbnail];
}

@end
