//
//  FullImage.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "FullImage.h"

@implementation FullImage

- (UIImage*) image
{
    return [[UIImage alloc] initWithData:self.imageData];
}

@end
