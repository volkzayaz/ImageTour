//
//  VSTourImageSelectionViewController.m
//  ImageTour
//
//  Created by 286 on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSThumbnailsSelectionViewController.h"

@implementation VSThumbnailsSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tourCell"];
    
    self.title = @"Select destination image";
    
    [self.fetchedResultsController performFetch:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tourCell"
                                                            forIndexPath:indexPath];
    
    TourImage* image = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.imageView.image = image.image;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.callback)
    {
        TourImage* image = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        self.callback(image);
    }
}

@end
