//
//  DetailViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSImageTourViewController.h"

#import "VSActivityBarItem.h"
#import "VSDocumentStateManager.h"

#import "NSOperationQueue+Sugar.h"
#import "UIViewController+Messages.h"

#import "VSPreferences.h"

@interface VSImageTourViewController ()
<
    VSBaseTourImageDelegate
>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *fromBegginingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

@property (weak, nonatomic) VSActivityBarItem *activityBarItem;

@property (nonatomic, strong) FullImage* presentedImage;

@property (nonatomic, strong) NSMutableArray<NSManagedObjectID*>* backStack;
@property (nonatomic, strong) NSMutableArray<NSManagedObjectID*>* forwardStack;

@property (nonatomic, strong) id observer;

@end

@implementation VSImageTourViewController

- (void)dealloc
{
    [self nullifyDocument];
}

- (void)setPresentedImage:(FullImage *)presentedImage {
    _presentedImage = presentedImage;
    
    self.backButton.enabled = self.backStack.count > 0;
    self.fromBegginingButton.enabled = self.backStack.count > 0;
    self.forwardButton.enabled = self.forwardStack.count > 0;
    
    self.displayImage = presentedImage.image;
    
    if(VSPreferences.showsSelectionAreas)
    {
        NSArray* ar = [self.document rectsForImage:presentedImage.tourImage];
        for(NSValue* val in ar)
        {
            [self displayRectOnMainImage:[val CGRectValue]];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backStack = [NSMutableArray array];
    self.forwardStack = [NSMutableArray array];
    
    self.presentedImage = self.document.initialImageForTour;
    self.delegate = self;
    
    self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIDocumentStateChangedNotification
                                                      object:self.document
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      if(self.document.documentState == UIDocumentStateClosed)
                                                      {
                                                          [self nullifyDocument];
                                                      }
    }];
    
    VSActivityBarItem* item = [VSActivityBarItem activityBarItem];
    self.activityBarItem = item;
    NSArray* rightItems = self.navigationItem.rightBarButtonItems;
    self.navigationItem.rightBarButtonItems = [rightItems arrayByAddingObject:item];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showHintOnceWithTitle:@"Tour" message:@"Це екран перегляду турів. Червоними зонами відмічені існуючі переходи до інших картинок. Ви можете вимкнути опцію відображення цих зон в налаштуваннях вашого пристрою в розділі ImageTour. Кнопки навігації розташовані праворуч на UINavigationItem."];
}

- (void) nullifyDocument
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    self.document = nil;
    self.presentedImage = nil;
    
    [self.backStack removeAllObjects];
    [self.forwardStack removeAllObjects];
}

#pragma mark - parent method

//@override
- (void) didTapOnImageAtPoint:(CGPoint)point
{
    [self.activityBarItem startAnimating];
    [NSOperationQueue dispatchJob:^id{
        return [self.document nextImageForTappingOnPoint:point
                                                 onImage:self.presentedImage];
    } nextUIBlock:^(FullImage* nextImage) {
        if(nextImage)
        {
            [self.backStack addObject:self.presentedImage.objectID];
            
            self.presentedImage = nextImage;
        }
        [self.activityBarItem stopAnimating];
    }];
}

#pragma mark - target/actions calls

- (IBAction)forward:(id)sender {
    NSManagedObjectID* lastFileKey = self.forwardStack.lastObject;
    
    [self.forwardStack removeLastObject];
    [self.backStack addObject:self.presentedImage.objectID];
    
    [self.activityBarItem startAnimating];
    [NSOperationQueue dispatchJob:^id{
        return [self.document imageForManagedObjectID:lastFileKey];
    } nextUIBlock:^(FullImage* res) {
        [self.activityBarItem stopAnimating];
        self.presentedImage = res;
    }];
}

- (IBAction)back:(id)sender {
    NSManagedObjectID* lastFileKey = self.backStack.lastObject;
    
    [self.backStack removeLastObject];
    [self.forwardStack addObject:self.presentedImage.objectID];
    
    [self.activityBarItem startAnimating];
    [NSOperationQueue dispatchJob:^id{
        return [self.document imageForManagedObjectID:lastFileKey];
    } nextUIBlock:^(FullImage* res) {
        [self.activityBarItem stopAnimating];
        self.presentedImage = res;
    }];
}

- (IBAction)fromBeggining:(id)sender {
    [self.backStack removeAllObjects];
    [self.forwardStack removeAllObjects];
    
    [self.activityBarItem startAnimating];
    [NSOperationQueue dispatchJob:^id{
        return self.document.initialImageForTour;
    } nextUIBlock:^(FullImage* res) {
        [self.activityBarItem stopAnimating];
        self.presentedImage = res;
    }];
}

@end
