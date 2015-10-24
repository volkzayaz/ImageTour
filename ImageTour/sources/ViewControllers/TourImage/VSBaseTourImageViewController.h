//
//  VSBaseTourImageViewController.h
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSBaseTourImageDelegate <NSObject>

@optional
/**
 *  @param point - calculated based on image size and is resolution independent
 */
- (void) didTapOnImageAtPoint:(CGPoint)point;

@end

@interface VSBaseTourImageViewController : UIViewController

@property (nonatomic, weak  ) id<VSBaseTourImageDelegate> delegate;
@property (nonatomic, strong) UIImage*                    displayImage;
@property (nonatomic, assign) BOOL                        showsSelectionRect;

/**
 *  @param rect - calculated based on image size and is resolution independent
 */
@property (nonatomic, assign, readonly) CGRect selectedRect;
- (void) displayRectOnMainImage:(CGRect)rect;

@end
