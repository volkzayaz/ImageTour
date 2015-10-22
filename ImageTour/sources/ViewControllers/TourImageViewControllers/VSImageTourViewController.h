//
//  DetailViewController.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSBaseTourImageViewController.h"
#import "VSDocument.h"

@interface VSImageTourViewController : VSBaseTourImageViewController

@property (strong, nonatomic) VSDocument* document;

@end

