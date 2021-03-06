//
//  TourImage.h
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

@import UIKit;
#import <CoreData/CoreData.h>

@class FullImage, ImageLink;

NS_ASSUME_NONNULL_BEGIN

@interface TourImage : NSManagedObject

- (UIImage*) image;

@end

NS_ASSUME_NONNULL_END

#import "TourImage+CoreDataProperties.h"
