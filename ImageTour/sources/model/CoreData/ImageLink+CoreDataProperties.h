//
//  ImageLink+CoreDataProperties.h
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ImageLink.h"

NS_ASSUME_NONNULL_BEGIN

@class TourImage;

@interface ImageLink (CoreDataProperties)

@property (nullable, nonatomic, retain) NSValue* linkRect;
@property (nullable, nonatomic, retain) TourImage *fromTourImage;
@property (nullable, nonatomic, retain) TourImage *toTourImage;

@end

NS_ASSUME_NONNULL_END
