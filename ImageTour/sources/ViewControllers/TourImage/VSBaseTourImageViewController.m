//
//  VSBaseTourImageViewController.m
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSBaseTourImageViewController.h"

#import "VSSelectingRectView.h"
#import "VSTourImageView.h"
#import "VSTransformUtility.h"

#import "UIImage+Resize.h"

@interface VSBaseTourImageViewController () <VSSelectingViewProtocol>

@property (weak,   nonatomic, readwrite) VSTourImageView*     mainImageView;
@property (strong, nonatomic, readwrite) VSSelectingRectView* selectingRectView;
@property (weak,   nonatomic, readwrite) UIImageView*         checkedBackground;

@property (assign, nonatomic, readwrite) CGRect selectedRect;

@end

@implementation VSBaseTourImageViewController

- (void)setDisplayImage:(UIImage *)displayImage {
    _displayImage = displayImage;
    
    self.mainImageView.image = displayImage;
    [self.mainImageView.layer addAnimation:[CATransition animation]
                                    forKey:kCATransition];

    if(self.isViewLoaded)
    {
        [self.view setNeedsLayout];
    }
}

#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage* im = [UIImage imageNamed:@"checker"];
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

#pragma mark - orientation changes

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{

    CGRect selectionViewFrame = self.selectingRectView.frame;
    CGSize viewSize = self.mainImageView.frame.size;
    CGSize upcomingImageSize = [self.displayImage niceSizeToFitInSize:size];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.selectingRectView.frame = [VSTransformUtility transformedRectFromRect:selectionViewFrame
                                                                        originSize:viewSize
                                                                   destinationSize:upcomingImageSize];
        self.selectedRect = self.selectingRectView.frame;
    } completion:nil];
    
}

#pragma mark - Selecting frame delegate

- (void)didChangeSelectedFrame:(CGRect)selectedFrame
{
    CGRect selectionViewFrame = selectedFrame;
    CGSize viewSize = self.mainImageView.frame.size;
    CGSize imageSize = self.displayImage.size;
    
    self.selectedRect = [VSTransformUtility transformedRectFromRect:selectionViewFrame
                                                       originSize:viewSize
                                                  destinationSize:imageSize];
}

#pragma mark - actions

- (void) userTappedOnImage:(UITapGestureRecognizer*)gr
{
    if([self.delegate respondsToSelector:@selector(didTapOnImageAtPoint:)])
    {
        CGPoint location = [gr locationInView:self.mainImageView];
        CGSize viewSize = self.mainImageView.frame.size;
        CGSize imageSize = self.displayImage.size;

        [self.delegate didTapOnImageAtPoint:[VSTransformUtility transformedPoint:location
                                                                    originSize:viewSize
                                                               destinationSize:imageSize]];
    }
    
}

- (void)displayRectOnMainImage:(CGRect)rect
{
    [self.mainImageView displayAttentionBoxInRect:rect];
}

@end
