//
//  VSEditDocumentViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSEditDocumentViewController.h"
#import "VSEditImageViewController.h"

#import "VSImagePicker.h"
#import "UIViewController+Messages.h"

@interface VSEditDocumentViewController()
<
    VSImagePickerDelegate,
    NSFetchedResultsControllerDelegate
>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;

@property (nonatomic, strong) VSImagePicker* imagePicker;

@end

@implementation VSEditDocumentViewController

- (void) configureView {
    self.title = self.document.fileURL.lastPathComponent;
    
    self.fetchedResultsController = self.document.allThumbnails;
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* addEntryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                    target:self
                                                                                    action:@selector(addEntry)];
    self.navigationItem.rightBarButtonItem = addEntryButton;
    
    self.imagePicker = [[VSImagePicker alloc] initWithPresentingViewController:self];
    self.imagePicker.delegate = self;
    self.imagePicker.descriptionString = @"Pick new image for your tour";
    
    [self configureView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
#warning save document if we are returning to master controller
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {return 1;}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {return YES;}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"tourImageCell" forIndexPath:indexPath];
    
    TourImage* tourImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.imageView.image = tourImage.image;
    cell.textLabel.text = tourImage.createdDate.description;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        TourImage* tourImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [self.document deleteImage:tourImage];
    }
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TourImage* originImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    VSEditImageViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"VSEditImageViewController"];
    
    FullImage* fullScaleImage = originImage.fullImage;
    controller.displayImage = fullScaleImage.image;
    controller.selectionImagesController = [self.document allThumbnails];
    controller.showsSelectionRect = YES;
    
    __weak typeof(self) wSelf = self;
    controller.callback = ^(CGRect rect, TourImage* destinationImage){
#warning investigate long time of work
        [wSelf.document addLinkWithRect:rect
                              fromImage:originImage
                                toImage:destinationImage];
        
        [wSelf showInfoMessage:@"New tour link has been added" withTitle:@"Success"];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) addEntry {
#warning revert presentation of image picker
    [self.imagePicker pickAnImage];
//    [self imagePickerDidPickImage:[UIImage imageNamed:@"i.jpeg"]];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if(type == NSFetchedResultsChangeDelete)
    {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (type == NSFetchedResultsChangeInsert)
    {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma - mark ImagePicker delegate 

- (void)imagePickerDidPickImage:(UIImage *)image {
#warning here we can run out of memmory really quickly
    ///keeping fullscale image in memmory
    TourImage* tourImage = [self.document addImageWithImage:image];
//    
//    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
//        if(success)
//        {
//            [self.dataSource addObject:tourImage];
//            
//        }
//    }];
}

@end
