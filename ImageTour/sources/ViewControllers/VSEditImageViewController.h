//
//  VSEditImageViewController.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSBaseTourImageViewController.h"
#import "VSTourImage.h"

typedef void(^DidSelectRectCallback)(CGRect selectedRect, VSTourImage* selectedImage);

@interface VSEditImageViewController : VSBaseTourImageViewController

@property (nonatomic, strong) NSArray<VSTourImage*>*selectionImages;
@property (nonatomic, strong) DidSelectRectCallback callback;


@end
