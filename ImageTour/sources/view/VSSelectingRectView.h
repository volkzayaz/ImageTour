//
//  VSSlectingRectView.h
//  ImageTour
//
//  Created by 286 on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSSelectingViewProtocol <NSObject>

- (void) didChangeSelectedFrame:(CGRect)selectedFrame;

@end

@interface VSSelectingRectView : UIView

@property (nonatomic, weak) id<VSSelectingViewProtocol> delegate;

@end
