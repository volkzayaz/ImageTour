//
//  DetailViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSImageTourViewController.h"

@interface VSImageTourViewController () <VSBaseTourImageDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *fromBegginingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

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
}

- (void) didTapOnImageAtPoint:(CGPoint)point
{
    FullImage* nextImage = [self.document nextImageForTappingOnPoint:point
                                                               onImage:self.presentedImage];
    if(nextImage)
    {
#warning optionally present transition animation
        [self.backStack addObject:self.presentedImage.objectID];
        self.presentedImage = nextImage;
    }
}

- (IBAction)forward:(id)sender {
    NSManagedObjectID* lastFileKey = self.forwardStack.lastObject;
    
    [self.forwardStack removeLastObject];
    [self.backStack addObject:self.presentedImage.objectID];

    self.presentedImage = [self.document imageForManagedObjectID:lastFileKey];
}

- (IBAction)back:(id)sender {
    NSManagedObjectID* lastFileKey = self.backStack.lastObject;
    
    [self.backStack removeLastObject];
    [self.forwardStack addObject:self.presentedImage.objectID];
    
    self.presentedImage = [self.document imageForManagedObjectID:lastFileKey];
}

- (IBAction)fromBeggining:(id)sender {
    [self.backStack removeAllObjects];
    [self.forwardStack removeAllObjects];
    
    FullImage* image = self.document.initialImageForTour;
    self.presentedImage = image;
}

@end
