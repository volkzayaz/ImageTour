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
#import "UIViewController+Messages.h"

@import MessageUI;

@interface VSDocumentsViewController ()
<
    VSTableCellDelegate,
    VSImagePickerDelegate,
    MFMailComposeViewControllerDelegate
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

- (void)setUrl:(NSURL *)url
{
    if(!url)
    {
        return;
    }
    
    NSData* serializedData = [NSData dataWithContentsOfURL:url];
    NSURL* newDocumentURl = VSDocument.newUniqueUrlForDocument;
    
    NSFileWrapper* fw = [[NSFileWrapper alloc] initWithSerializedRepresentation:serializedData];
    
    NSError* er = nil;
    BOOL a = [fw writeToURL:newDocumentURl options:0 originalContentsURL:url error:&er];
    
    VSDocument* newDoc = [[VSDocument alloc] initWithFileURL:newDocumentURl];
    
    
    self.documents = [self.documents arrayByAddingObject:newDoc];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.documents.count-1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self showInfoMessage:url.absoluteString withTitle:@"Received URL"];
}

- (void)insertNewObject:(id)sender {
#warning revert this
//    [self imagePickerDidPickImage:[UIImage imageNamed:@"i.jpeg"]];
    
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
    
//    NSURL* url = [document.fileURL URLByAppendingPathComponent:@"StoreContent"];
//
//    NSArray* ar = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:&er];
//    
//    NSArray* secAr = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:ar.firstObject includingPropertiesForKeys:nil options:0 error:nil];
//    
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

- (void)exportDocument:(VSDocument *)document
{
    NSError* error = nil;
    NSURL *url = document.fileURL;
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:&error];
    if (dirWrapper == nil) {
        NSLog(@"Error creating directory wrapper: %@", error.localizedDescription);
        return;
    }
    
    NSData *dirData = [dirWrapper serializedRepresentation];
    
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:@";Subject Goes Here."];
    [mailViewController setMessageBody:@";Your message goes here." isHTML:NO];
    [mailViewController addAttachmentData:dirData mimeType:@"application/x-vs" fileName:document.fileURL.lastPathComponent];
    
    [self presentViewController:mailViewController animated:YES completion:nil];
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
    
#warning investigate memmory leak in image picker
    
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

#pragma mark - mail

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
