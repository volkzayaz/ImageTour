//
//  DetailViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSImageTourViewController.h"

#import "VSActivityBarItem.h"

#import "NSOperationQueue+Sugar.h"

@interface VSImageTourViewController () <VSBaseTourImageDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *fromBegginingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

@property (weak, nonatomic)        VSActivityBarItem *activityBarItem;

@property (nonatomic, strong) FullImage* presentedImage;

@property (nonatomic, strong) NSMutableArray<NSManagedObjectID*>* backStack;
@property (nonatomic, strong) NSMutableArray<NSManagedObjectID*>* forwardStack;

@end

@implementation VSImageTourViewController

- (void)setPresentedImage:(FullImage *)presentedImage {
    _presentedImage = presentedImage;
    
    self.backButton.enabled = self.backStack.count > 0;
    self.fromBegginingButton.enabled = self.backStack.count > 0;
    self.forwardButton.enabled = self.forwardStack.count > 0;
    
    self.displayImage = presentedImage.image;
    
    NSArray* ar = [self.document rectsForImage:presentedImage.tourImage];
    for(NSValue* val in ar)
    {
        [self displayRectOnMainImage:[val CGRectValue]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backStack = [NSMutableArray array];
    self.forwardStack = [NSMutableArray array];
    
    self.presentedImage = self.document.initialImageForTour;
    self.delegate = self;
    
    VSActivityBarItem* item = [VSActivityBarItem activityBarItem];
    self.activityBarItem = item;
    NSArray* rightItems = self.navigationItem.rightBarButtonItems;
    self.navigationItem.rightBarButtonItems = [rightItems arrayByAddingObject:item];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) didTapOnImageAtPoint:(CGPoint)point
{
    [self.activityBarItem startAnimating];
    [NSOperationQueue dispatchJob:^id{
        return [self.document nextImageForTappingOnPoint:point
                                                 onImage:self.presentedImage];
    } nextUIBlock:^(FullImage* nextImage) {
        if(nextImage)
        {
#warning optionally present transition animation
            [self.backStack addObject:self.presentedImage.objectID];
            self.presentedImage = nextImage;
        }
        [self.activityBarItem stopAnimating];
    }];
}

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
