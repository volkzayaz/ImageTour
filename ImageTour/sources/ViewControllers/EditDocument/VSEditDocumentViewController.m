//
//  VSEditDocumentViewController.m
//  ImageTour
//
//  Created by 286 on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSEditDocumentViewController.h"
#import "VSEditImageViewController.h"

#import "VSActivityBarItem.h"
#import "VSImagePicker.h"
#import "VSDocumentStateManager.h"

#import "UIViewController+Messages.h"
#import "NSOperationQueue+Sugar.h"

@interface VSEditDocumentViewController()
<
    VSImagePickerDelegate,
    NSFetchedResultsControllerDelegate
>

@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, weak  ) UIBarButtonItem* addEntryItem;

@property (nonatomic, strong) VSImagePicker* imagePicker;
@property (nonatomic, weak)   VSActivityBarItem* activityItem;

@property (nonatomic, strong) id observer;

@end

@implementation VSEditDocumentViewController

- (void) dealloc
{
    [self nullifyDocument];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.imagePicker = [[VSImagePicker alloc] initWithPresentingViewController:self];
        self.imagePicker.delegate = self;
        self.imagePicker.descriptionString = @"Pick new image for your tour";
        
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIDocumentStateChangedNotification
                                                                          object:self.document
                                                                           queue:[NSOperationQueue mainQueue]
                                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                                          if(self.document.documentState == UIDocumentStateClosed)
                                                                          {
                                                                              [self nullifyDocument];
                                                                          }
                                                                      }];
    }
    
    return self;
}

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fetchedResultsController = self.document.allThumbnails;
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    
    UIBarButtonItem* addEntryButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                    target:self
                                                                                    action:@selector(addEntry)];
    self.navigationItem.rightBarButtonItem = addEntryButton;
    self.addEntryItem = addEntryButton;
    
    self.title = self.document.fileURL.lastPathComponent;
    
    VSActivityBarItem* item = [VSActivityBarItem activityBarItem];
    self.activityItem = item;
    NSArray* rightItems = self.navigationItem.rightBarButtonItems;
    self.navigationItem.rightBarButtonItems = [rightItems arrayByAddingObject:item];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showHintOnceWithTitle:@"Edit tour" message:@"Це екран редагування турів. Тут відображаються усі картинки, які ви додали в тур. Додати нову картинку можна за допомогою кнопки '+'. Для видалення картинки зробіть swipe вліво на ній. Пам'ятайте, ваш тур завжди починатиметься з картинки, яка йде першою в списку."];
    
    [self showHintOnceWithTitle:@"Edit tour" message:@"Щоб створити нове посилання між картинками клацніть на картинці, яка буде містити це посилання."];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.fetchedResultsController.fetchedObjects.count < 2)
        return [self showInfoMessage:@"You need to have at least two images in your tour to add links. Try adding new images using '+' button"
                           withTitle:@"Error"];
    
    
    TourImage* originImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    VSEditImageViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"VSEditImageViewController"];
    
    controller.displayImage = originImage.fullImage.image;
    controller.selectionImagesController = [self.document allThumbnails];
    controller.showsSelectionRect = YES;
    
    __weak typeof(self) wSelf = self;
    controller.callback = ^(CGRect rect, TourImage* destinationImage){
        [wSelf.document addLinkWithRect:rect
                              fromImage:originImage
                                toImage:destinationImage];
        
        [wSelf showInfoMessage:@"New tour link has been added" withTitle:@"Success"];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - actions

- (void) addEntry {
    [self.imagePicker pickAnImage];
}

- (void) nullifyDocument
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    self.document = nil;
    self.addEntryItem.enabled = NO;
    
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - fetched results controller

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
    [self.activityItem startAnimating];
    [NSOperationQueue dispatchJob:^id{
        return [self.document addImageWithImage:image];
    } nextUIBlock:^(id _) {
        [self.activityItem stopAnimating];
    }];
}

@end
