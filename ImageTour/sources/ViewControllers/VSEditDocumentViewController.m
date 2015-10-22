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

@interface VSEditDocumentViewController() <VSImagePickerDelegate>

@property (nonatomic, strong) NSMutableArray<VSTourImage*>* dataSource;

@property (nonatomic, strong) VSImagePicker* imagePicker;

@end

@implementation VSEditDocumentViewController

- (void) configureView {
    self.title = self.document.fileURL.lastPathComponent;
    
    self.dataSource = self.document.allThumbnails.mutableCopy;
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {return self.dataSource.count;}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {return YES;}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"tourImageCell" forIndexPath:indexPath];
    
    VSTourImage* tourImage = self.dataSource[indexPath.row];
    
    cell.imageView.image = tourImage.image;
    cell.textLabel.text = tourImage.fileKey.stringValue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        VSTourImage* tourImage = self.dataSource[indexPath.row];
        
        [self.document deleteImage:tourImage];
        
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if(success)
            {
                [self.dataSource removeObjectAtIndex:indexPath.row];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    VSTourImage* originImage = self.dataSource[indexPath.row];
    
    VSEditImageViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"VSEditImageViewController"];
    
    VSTourImage* fullScaleImage = [self.document fullScaleImageForThumbnail:originImage];
    controller.displayImage = fullScaleImage.image;
    controller.selectionImages = self.dataSource;
    controller.showsSelectionRect = YES;
    
    __weak typeof(self) wSelf = self;
    controller.callback = ^(CGRect rect, VSTourImage* destinationImage){
#warning investigate long time of work
        [wSelf.document addLinkWithRect:rect
                              fromImage:originImage
                                toImage:destinationImage];
        
#warning refactor to proper document saving
        [wSelf.document saveToURL:wSelf.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            [wSelf showInfoMessage:@"New tour link has been added" withTitle:@"Success"];
        }];
        
        
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) addEntry {
#warning revert presentation of image picker
    [self.imagePicker pickAnImage];
//    [self imagePickerDidPickImage:[UIImage imageNamed:@"i.jpeg"]];
}

#pragma - mark ImagePicker delegate 

- (void)imagePickerDidPickImage:(UIImage *)image {
#warning here we can run out of memmory really quickly
    ///keeping fullscale image in memmory
    VSTourImage* tourImage = [self.document addImageWithImage:image];
    
    
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if(success)
        {
            [self.dataSource addObject:tourImage];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

@end
