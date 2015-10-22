//
//  FullImage.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

@import UIKit;
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface FullImage : NSManagedObject

- (UIImage*) image;

@end

NS_ASSUME_NONNULL_END

#import "FullImage+CoreDataProperties.h"
