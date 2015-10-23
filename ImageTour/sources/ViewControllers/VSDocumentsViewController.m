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
#import "VSActivityBarItem.h"

#import "VSDocument+URLManagement.h"
#import "UIViewController+Messages.h"

#import "NSOperationQueue+Sugar.h"

@import MessageUI;

@interface VSDocumentsViewController ()
<
    VSTableCellDelegate,
    VSImagePickerDelegate
>

@property (nonatomic, strong) VSImagePicker* imagePicker;
@property (nonatomic, weak)   VSActivityBarItem* activityItem;

@property (nonatomic, strong) NSArray<VSDocument*>* documents;

@property (nonatomic, strong) VSDocument* documentToPresent;

@property (nonatomic, strong) UIDocumentInteractionController* documentController;

@end

@implementation VSDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.documents = [VSDocument localImageTourDocuments];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;

    self.imagePicker = [[VSImagePicker alloc] initWithPresentingViewController:self];
    self.imagePicker.delegate = self;
    self.imagePicker.descriptionString = @"Pick initial image for your tour";
    
    VSActivityBarItem* item = [VSActivityBarItem activityBarItem];
    self.activityItem = item;
    NSArray* rightItems = self.navigationItem.rightBarButtonItems;
    self.navigationItem.rightBarButtonItems = [rightItems arrayByAddingObject:item];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    
#warning refactor to proper closing of the document
    [self.documentToPresent closeWithCompletionHandler:^(BOOL success) {
        NSLog(@"Saved %@",self.documentToPresent);
    }];
    
}

- (void)setUrl:(NSURL *)url
{
    [self.activityItem startAnimating];
    [VSDocument importDcoumentFromURL:url
                                toURL:[VSDocument newUniqueUrlForDocument]
                     withCompletition:^(VSDocument *newDocument, NSError *error) {
                         
                         self.documents = [self.documents arrayByAddingObject:newDocument];
                         [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.documents.count-1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationAutomatic];
                         [self.activityItem stopAnimating];
 }];
}

- (void)insertNewObject:(id)sender {
#warning revert this
    //[self imagePickerDidPickImage:[UIImage imageNamed:@"a.jpg"]];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VSTableCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    VSDocument* selectedDocument = self.documents[indexPath.row];
    
    self.documentToPresent = selectedDocument;
    
    #warning refactor and take care of document closing
    [cell startAnimatingProgress];
    [self.documentToPresent openWithCompletionHandler:^(BOOL success) {
        if(success)
        {
            [cell stopAnimationProgress];

            [self performSegueWithIdentifier:@"startTour" sender:nil];
        }
    }];
}

- (void)configureCell:(VSTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.delegate = self;
    
    VSDocument* doc = self.documents[indexPath.row];
    
    [cell setDocument:doc];
}


#pragma mark - VSTableCell delegte

- (void)tableCell:(VSTableCell *)cell exportDocument:(VSDocument *)document
{
#warning close document before proceeding

    [cell startAnimatingProgress];

    [NSOperationQueue dispatchJob:^id{
        return document.prepareForExport;
    } nextUIBlock:^(NSURL* res) {
        [cell stopAnimationProgress];
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:res];
        self.documentController.UTI = @"com.286.vs";
        [self.documentController presentOpenInMenuFromRect:cell.exportButton.frame
                                                    inView:cell.contentView
                                                  animated:YES];
    }];

}

- (void)tableCell:(VSTableCell *)cell editDocument:(VSDocument *)document
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
    [self.activityItem startAnimating];
    NSURL *documentURL = VSDocument.newUniqueUrlForDocument;
    VSDocument* newDocument = [VSDocument createNewLocalDocumentInURL:documentURL];
    
#warning investigate memmory leak in image picker
    
    [newDocument saveToURL:documentURL
          forSaveOperation:UIDocumentSaveForCreating
         completionHandler:^(BOOL success) {
#warning tour #10 does not want to create
             if(success)
             {
                 [NSOperationQueue dispatchJob:^id{
                    return [newDocument addImageWithImage:image];
                 } nextUIBlock:^(id _) {
                     [newDocument closeWithCompletionHandler:^(BOOL success) {
                        [self.activityItem stopAnimating];
                         self.documents = [self.documents arrayByAddingObject:newDocument];
                         [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.documents.count-1 inSection:0]]
                                               withRowAnimation:UITableViewRowAnimationAutomatic];
                         
                     }];
                }];
             }
    }];
}

@end
