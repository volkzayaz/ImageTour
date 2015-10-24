//
//  DetailViewController.h
//  ImageTour
//
//  Created by 286 on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSBaseTourImageViewController.h"
#import "VSDocument.h"

@interface VSImageTourViewController : VSBaseTourImageViewController

@property (weak, nonatomic) VSDocument* document;

@end

