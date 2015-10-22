//
//  DetailViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "ImageTourViewController.h"

@interface ImageTourViewController () <VSBaseTourImageDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *fromBegginingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;

@property (nonatomic, strong) VSTourImage* presentedImage;

@property (nonatomic, strong) NSMutableArray<NSNumber*>* backStack;
@property (nonatomic, strong) NSMutableArray<NSNumber*>* forwardStack;

@end

@implementation ImageTourViewController

- (void)setPresentedImage:(VSTourImage *)presentedImage {
    _presentedImage = presentedImage;
    
    self.backButton.enabled = self.backStack.count > 0;
    self.fromBegginingButton.enabled = self.backStack.count > 0;
    self.forwardButton.enabled = self.forwardStack.count > 0;
    
    self.displayImage = presentedImage.image;
    
    for(NSValue* val in [self.document rectsForImage:presentedImage])
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
    VSTourImage* nextImage = [self.document nextImageForTappingOnPoint:point
                                                               onImage:self.presentedImage];
    if(nextImage)
    {
#warning optionally present transition animation
        [self.backStack addObject:self.presentedImage.fileKey];
        self.presentedImage = nextImage;
        
    }
}

- (IBAction)forward:(id)sender {
    NSNumber* lastFileKey = self.forwardStack.lastObject;
    
    [self.forwardStack removeLastObject];
    [self.backStack addObject:self.presentedImage.fileKey];
    
    VSTourImage* image = [self.document fullScaleImageForFileKey:lastFileKey];
    self.presentedImage = image;
}

- (IBAction)back:(id)sender {
    NSNumber* lastFileKey = self.backStack.lastObject;
    
    [self.backStack removeLastObject];
    [self.forwardStack addObject:self.presentedImage.fileKey];
    
    VSTourImage* image = [self.document fullScaleImageForFileKey:lastFileKey];
    self.presentedImage = image;
}

- (IBAction)fromBeggining:(id)sender {
    [self.backStack removeAllObjects];
    [self.forwardStack removeAllObjects];
    
    VSTourImage* image = self.document.initialImageForTour;
    self.presentedImage = image;
}

@end
