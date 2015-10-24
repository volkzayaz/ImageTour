//
//  MasterViewController.m
//  ImageTour
//
//  Created by 286 on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocumentsViewController.h"
#import "VSImageTourViewController.h"
#import "VSEditDocumentViewController.h"

#import "VSImagePicker.h"
#import "VSDocumentStateManager.h"

#import "VSTableCell.h"
#import "VSActivityBarItem.h"

#import "VSDocument+URLManagement.h"
#import "UIViewController+Messages.h"
#import "NSOperationQueue+Sugar.h"

@interface VSDocumentsViewController ()
<
    VSTableCellDelegate,
    VSImagePickerDelegate
>

@property (nonatomic, strong) VSImagePicker* imagePicker;
@property (nonatomic, weak)   VSActivityBarItem* activityItem;

@property (nonatomic, strong) NSArray<VSDocument*>* documents;

@property (nonatomic, strong) UIDocumentInteractionController* documentController;

@end

@implementation VSDocumentsViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        self.documents = [VSDocument localImageTourDocuments];
        if(self.documents.count == 0)
        {
            [self addExampleDocument];
        }
        
        self.imagePicker = [[VSImagePicker alloc] initWithPresentingViewController:self];
        self.imagePicker.delegate = self;
        self.imagePicker.descriptionString = @"Pick initial image for your tour";
    }
    
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;

    VSActivityBarItem* item = [VSActivityBarItem activityBarItem];
    self.activityItem = item;
    NSArray* rightItems = self.navigationItem.rightBarButtonItems;
    self.navigationItem.rightBarButtonItems = [rightItems arrayByAddingObject:item];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self showGreeting];
    [self showHintOnceWithTitle:@"Image Tours" message:@"Тут відображається список усіх наявних документів-турів. Додати один тур можна за допомогою кнопки '+'. При додаванні туру ви маєте обрати стартову картинку для нього."];
    
    [self showHintOnceWithTitle:@"Image Tours" message:@"Розпочати перегляд тура можна клацнувши на комірку з ним. Щоб редагувати тур клацніть 'Edit'. Для видалення тура, зробіть swipe вліво на ньому."];
}

#pragma mark - actions

- (void) addExampleDocument
{
    NSURL* exampleDocURL = [VSDocument urlForExampleDocument];
    [VSDocument importDcoumentFromURL:[[NSBundle mainBundle] URLForResource:@"Example_Tour"
                                                              withExtension:@"vs"]
                                toURL:exampleDocURL
                     withCompletition:nil];
    self.documents = @[[[VSDocument alloc] initWithFileURL:exampleDocURL]];
}

- (void)insertNewObject {
    [self.imagePicker pickAnImage];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString* segueID = [segue identifier];
    
    VSDocument* doc = [[VSDocumentStateManager sharedInstance] currentlyOpenedDocument];
    NSAssert(doc != nil, @"At least one document must be opened before performing any segues");
    
    if ([segueID isEqualToString:@"startTour"]) {

        VSImageTourViewController *controller = (VSImageTourViewController *)[[segue destinationViewController] topViewController];
        controller.document = doc;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
    else if ([segueID isEqualToString:@"showEditDocument"])
    {
        VSEditDocumentViewController* controller = (VSEditDocumentViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;

        controller.document = doc;
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
    cell.delegate = self;
    
    VSDocument* doc = self.documents[indexPath.row];
    [cell setDocument:doc];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {return YES;}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VSTableCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    VSDocument* selectedDocument = self.documents[indexPath.row];

    [cell startAnimatingProgress];
    [[VSDocumentStateManager sharedInstance] ensureOpenedDocument:selectedDocument andDo:^(VSDocument *doc) {
        [cell stopAnimationProgress];
        
        [self performSegueWithIdentifier:@"startTour" sender:nil];
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.activityItem startAnimating];
        VSDocument* doc = self.documents[indexPath.row];
        
        [[VSDocumentStateManager sharedInstance]
         ensureClosedDocument:doc
                        andDo:^(VSDocument *doc) {
                            NSFileManager* fileManager = [[NSFileManager alloc] init];
                            if([fileManager removeItemAtURL:doc.fileURL error:nil])
                            {
                                [self.activityItem stopAnimating];
                                self.documents = [self.documents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != %@",doc]];
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                            }
                        }];
    }
}

#pragma mark - VSTableCell delegte


- (void)tableCell:(VSTableCell *)cell editDocument:(VSDocument *)document
{
    [cell startAnimatingProgress];
    [[VSDocumentStateManager sharedInstance]
                ensureOpenedDocument:document
                               andDo:^(VSDocument *doc) {
         
        [cell stopAnimationProgress];
        [self performSegueWithIdentifier:@"showEditDocument" sender:nil];
         
    }];
}

#pragma mark - export/import docoments

- (void)tableCell:(VSTableCell *)cell exportDocument:(VSDocument *)document
{
#if TARGET_IPHONE_SIMULATOR
    [self showInfoMessage:@"Document exporting is not supported on simulators. Try installing app on iphone/ipad" withTitle:@"Ouch"];
#else
    [cell startAnimatingProgress];
    [[VSDocumentStateManager sharedInstance] explicitlySaveDocumentWithCallback:^(VSDocument* _) {
        [NSOperationQueue dispatchJob:^id{
            return document.prepareForExport;
        } nextUIBlock:^(NSURL* res) {
            [cell stopAnimationProgress];
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:res];
            self.documentController.UTI = @"com.286.vs";
            [self.documentController presentOpenInMenuFromRect:cell.exportButtonFrame
                                                        inView:cell.contentView
                                                      animated:YES];
        }];
    }];
#endif
    
    
}

- (void)setImportedDocumentURL:(NSURL *)url
{
    if(![VSDocument validateURL:url])
        return;
    
    [self.activityItem startAnimating];
    [VSDocument importDcoumentFromURL:url
                                toURL:[VSDocument newUniqueUrlForDocument]
                     withCompletition:^(VSDocument *newDocument, NSError *error) {
                         
                         if(!error)
                         {
                             self.documents = [self.documents arrayByAddingObject:newDocument];
                             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.documents.count-1 inSection:0]]
                                                   withRowAnimation:UITableViewRowAnimationAutomatic];
                             
                             [[VSDocumentStateManager sharedInstance]
                                    ensureOpenedDocument:newDocument
                                                   andDo:^(VSDocument *doc) {
                                 [self.activityItem stopAnimating];
                                 [self performSegueWithIdentifier:@"startTour" sender:nil];
                                 
                             }];
                             [self showInfoMessage:@"Your document has been imported"
                                         withTitle:@"Success"];
                         }
                         else
                         {
                             [self showInfoMessage:error.localizedDescription
                                         withTitle:@"Error importing document"];
                         }
                     }];
}

#pragma mark - image picker delegate

- (void) imagePickerDidPickImage:(UIImage *)image
{
    [self.activityItem startAnimating];
    
    [[VSDocumentStateManager sharedInstance] explicitlyCreateDocumetWithCallback:^(VSDocument *newDocument) {
        [NSOperationQueue dispatchJob:^id{
            return [newDocument addImageWithImage:image];
        } nextUIBlock:^(id _) {
            
            [self.activityItem stopAnimating];
            self.documents = [self.documents arrayByAddingObject:newDocument];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.documents.count-1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];

            [self performSegueWithIdentifier:@"showEditDocument" sender:nil];
        }];
    }];
}

@end
