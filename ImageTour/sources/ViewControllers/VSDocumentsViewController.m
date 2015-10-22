//
//  MasterViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocumentsViewController.h"
#import "VSImageTourViewController.h"
#import "VSEditDocumentViewController.h"
#import "VSImagePicker.h"

#import "VSTableCell.h"

#import "VSDocument+URLManagement.h"

@interface VSDocumentsViewController ()
<
    VSTableCellDelegate,
    VSImagePickerDelegate
>

@property (nonatomic, strong) VSImagePicker* imagePicker;

@property (nonatomic, strong) NSArray<VSDocument*>* documents;

@property (nonatomic, strong) VSDocument* documentToPresent;

@end

@implementation VSDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.documents = [VSDocument localImageTourDocuments];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.imagePicker = [[VSImagePicker alloc] initWithPresentingViewController:self];
    self.imagePicker.delegate = self;
    self.imagePicker.descriptionString = @"Pick initial image for your tour";
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    
#warning refactor to proper closing of the document
    [self.documentToPresent closeWithCompletionHandler:^(BOOL success) {
        NSLog(@"Saved %@",self.documentToPresent);
    }];
}

- (void)insertNewObject:(id)sender {
#warning revert this
//    [self imagePickerDidPickImage:[UIImage imageNamed:@"a.jpg"]];
    [self.imagePicker pickAnImage];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString* segueID = [segue identifier];
    
    if ([segueID isEqualToString:@"startTour"]) {

        VSImageTourViewController *controller = (VSImageTourViewController *)[[segue destinationViewController] topViewController];
        controller.document = self.documentToPresent;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([segueID isEqualToString:@"showEditDocument"])
    {
        VSEditDocumentViewController* controller = (VSEditDocumentViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;

        controller.document = self.documentToPresent;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.documents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VSTableCell *cell = [tableView dequeueReusableCellWithIdentifier:VSTableCell.reuseIdentifier
                                                        forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(VSTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.delegate = self;
    
    VSDocument* doc = self.documents[indexPath.row];
    
    [cell setDocument:doc];
}


#pragma mark - VSTableCell delegte

#warning refactor and take care of document closing

- (void)startTourWithDocument:(VSDocument *)document
{
//    [self.documentToPresent closeWithCompletionHandler:^(BOOL success) {
//        if(success)
//        {
            self.documentToPresent = document;
#warning probably put a spinner until document is opened
            [self.documentToPresent openWithCompletionHandler:^(BOOL success) {
                if(success)
                {
                    [self performSegueWithIdentifier:@"startTour" sender:nil];
                }
            }];
            
        //}
//    }];
}

- (void)editDocument:(VSDocument *)document
{
//    [self.documentToPresent closeWithCompletionHandler:^(BOOL success) {
//        if(success)
//        {
            self.documentToPresent = document;
#warning probably put a spinner until document is opened
            [self.documentToPresent openWithCompletionHandler:^(BOOL success) {
                if(success)
                {
                    [self performSegueWithIdentifier:@"showEditDocument" sender:nil];
                }
            }];
            
        //}
//    }];
}

#pragma mark - image picker delegate

- (void) imagePickerDidPickImage:(UIImage *)image
{
    NSURL *documentURL = VSDocument.newUniqueUrlForDocument;
    VSDocument* newDocument = [VSDocument createNewLocalDocumentInURL:documentURL];
    
    [newDocument saveToURL:documentURL
          forSaveOperation:UIDocumentSaveForCreating
         completionHandler:^(BOOL success) {
#warning tour #10 does not want to create
             if(success)
             {
                [newDocument addImageWithImage:image];
                 [newDocument closeWithCompletionHandler:^(BOOL success) {
                     self.documents = [self.documents arrayByAddingObject:newDocument];
                     [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.documents.count-1 inSection:0]]
                                           withRowAnimation:UITableViewRowAnimationAutomatic];
                     
                 }];
             }
             
             
    }];
}

@end
