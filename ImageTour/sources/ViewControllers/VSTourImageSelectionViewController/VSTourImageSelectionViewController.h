//
//  VSTourImageSelectionViewController.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSTourImage.h"

typedef void(^TourImageSelectionCallback)(VSTourImage* selectedTourImage);

@interface VSTourImageSelectionViewController : UITableViewController

@property (nonatomic, strong) NSArray<VSTourImage*>* dataSource;
@property (nonatomic, strong) TourImageSelectionCallback callback;

@end
