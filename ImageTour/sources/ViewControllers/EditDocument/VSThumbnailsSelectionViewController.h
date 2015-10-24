//
//  VSTourImageSelectionViewController.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourImage.h"

typedef void(^TourImageSelectionCallback)(TourImage* selectedTourImage);

@interface VSThumbnailsSelectionViewController : UITableViewController

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) TourImageSelectionCallback callback;

@end
