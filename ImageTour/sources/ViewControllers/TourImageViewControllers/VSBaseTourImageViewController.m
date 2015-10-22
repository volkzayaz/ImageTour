//
//  VSBaseTourImageViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSBaseTourImageViewController.h"

#import "VSSelectingRectView.h"
#import "VSTourImageView.h"

#import "UIImage+Resize.h"

#import "TransformUtility.h"

@interface VSBaseTourImageViewController () <VSSelectingViewProtocol>

@property (weak,   nonatomic, readwrite) VSTourImageView *mainImageView;
@property (assign, nonatomic, readwrite) CGRect selectedRect;

@property (strong, nonatomic, readwrite) VSSelectingRectView* selectingRectView;

@property (weak,   nonatomic, readwrite) UIImageView* checkedBackground;

@end

@implementation VSBaseTourImageViewController

- (void)setDisplayImage:(UIImage *)displayImage {
    _displayImage = displayImage;
    
    self.mainImageView.image = displayImage;
    if(self.isViewLoaded)
    {
        [self.view setNeedsLayout];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage* im = [UIImage imageNamed:@"checker.png"];
    UIImageView* checker = [[UIImageView alloc] initWithImage:im];
    checker.contentMode = UIViewContentModeScaleAspectFill;
    checker.alpha = 0.2;
    self.checkedBackground = checker;
    [self.view addSubview:checker];

    
    VSTourImageView* imageView = [[VSTourImageView alloc] initWithImage:self.displayImage];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    self.mainImageView = imageView;

    
    UITapGestureRecognizer* gr =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(userTappedOnImage:)];
    
    [self.mainImageView addGestureRecognizer:gr];

    self.selectedRect = CGRectZero;
    
    if(self.showsSelectionRect)
    {
        self.selectingRectView = [[VSSelectingRectView alloc] initWithFrame:(CGRect){100,100,100,100}];
        self.selectingRectView.delegate = self;
        [self.mainImageView addSubview:self.selectingRectView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.checkedBackground.hidden = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.checkedBackground.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize imageSize = [self.displayImage niceSizeToFitInSize:self.view.frame.size];
    
    self.mainImageView.frame = (CGRect){0,0,imageSize};
    self.mainImageView.center = self.view.center;
    
    self.checkedBackground.frame = self.view.bounds;
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{

    CGRect selectionViewFrame = self.selectingRectView.frame;
    CGSize viewSize = self.mainImageView.frame.size;
    CGSize upcomingImageSize = [self.displayImage niceSizeToFitInSize:size];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.selectingRectView.frame = [TransformUtility transformedRectFromRect:selectionViewFrame
                                                                      originSize:viewSize
                                                                 destinationSize:upcomingImageSize];
        self.selectedRect = self.selectingRectView.frame;
    } completion:nil];
    
}

- (void)didChangeSelectedFrame:(CGRect)selectedFrame
{
    CGRect selectionViewFrame = selectedFrame;
    CGSize viewSize = self.mainImageView.frame.size;
    CGSize imageSize = self.displayImage.size;
    
    self.selectedRect = [TransformUtility transformedRectFromRect:selectionViewFrame
                                                       originSize:viewSize
                                                  destinationSize:imageSize];
}

- (void)displayRectOnMainImage:(CGRect)rect
{
    [self.mainImageView displayAttentionBoxInRect:rect];
}

#pragma mark - actions

- (void) userTappedOnImage:(UITapGestureRecognizer*)gr
{
    if([self.delegate respondsToSelector:@selector(didTapOnImageAtPoint:)])
    {
        CGPoint location = [gr locationInView:self.mainImageView];
        CGSize viewSize = self.mainImageView.frame.size;
        CGSize imageSize = self.displayImage.size;

        [self.delegate didTapOnImageAtPoint:[TransformUtility transformedPoint:location
                                                                    originSize:viewSize
                                                               destinationSize:imageSize]];
    }
    
}

@end
