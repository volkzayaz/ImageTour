//
//  FullImage+CoreDataProperties.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FullImage.h"

NS_ASSUME_NONNULL_BEGIN

@class TourImage;

@interface FullImage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *imageData;
@property (nullable, nonatomic, retain) TourImage *tourImage;

@end

NS_ASSUME_NONNULL_END
