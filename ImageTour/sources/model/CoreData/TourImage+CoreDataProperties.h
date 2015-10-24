//
//  TourImage+CoreDataProperties.h
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TourImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface TourImage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) FullImage *fullImage;
@property (nullable, nonatomic, retain) NSSet<ImageLink *> *linksOutside;
@property (nullable, nonatomic, retain) NSSet<ImageLink *> *linksInside;

@end

@interface TourImage (CoreDataGeneratedAccessors)

- (void)addLinksOutsideObject:(ImageLink *)value;
- (void)removeLinksOutsideObject:(ImageLink *)value;
- (void)addLinksOutside:(NSSet<ImageLink *> *)values;
- (void)removeLinksOutside:(NSSet<ImageLink *> *)values;

- (void)addLinksInsideObject:(ImageLink *)value;
- (void)removeLinksInsideObject:(ImageLink *)value;
- (void)addLinksInside:(NSSet<ImageLink *> *)values;
- (void)removeLinksInside:(NSSet<ImageLink *> *)values;

@end

NS_ASSUME_NONNULL_END
