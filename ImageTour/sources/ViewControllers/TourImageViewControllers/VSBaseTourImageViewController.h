//
//  VSBaseTourImageViewController.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSBaseTourImageDelegate <NSObject>

@optional
///@param point is calculated based on image size and is resolution independent
- (void) didTapOnImageAtPoint:(CGPoint)point;

@end

@interface VSBaseTourImageViewController : UIViewController

@property (nonatomic, weak) id<VSBaseTourImageDelegate> delegate;
@property (nonatomic, assign) BOOL showsSelectionRect;

///@param rect is calculated based on image size and is resolution independent
@property (nonatomic, assign, readonly) CGRect selectedRect;

- (void) displayRectOnMainImage:(CGRect)rect;

@property (nonatomic, strong) UIImage* displayImage;

@end
