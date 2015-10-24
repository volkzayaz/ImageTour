//
//  VSEditImageViewController.h
//  ImageTour
//
//  Created by 286 on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSBaseTourImageViewController.h"
#import "TourImage.h"

typedef void(^DidSelectRectCallback)(CGRect selectedRect, TourImage* selectedImage);

@interface VSEditImageViewController : VSBaseTourImageViewController

@property (nonatomic, strong) NSFetchedResultsController* selectionImagesController;
@property (nonatomic, strong) DidSelectRectCallback callback;


@end
