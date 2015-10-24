//
//  VSRootViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/24/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSRootViewController.h"
#import "VSDocumentsViewController.h"

@interface VSRootViewController () <UISplitViewControllerDelegate>

@property (nonatomic, weak) VSDocumentsViewController* documentsController;

@end

@implementation VSRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.delegate = self;
    
    UINavigationController *navigationController = [self.viewControllers lastObject];
    navigationController.topViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem;
    
    self.documentsController = (VSDocumentsViewController*)[self.viewControllers.firstObject topViewController];
}

-     (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
      ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return YES;
}

- (void)handleURL:(NSURL *)url
{
    self.documentsController.importedDocumentURL = url;
}

@end