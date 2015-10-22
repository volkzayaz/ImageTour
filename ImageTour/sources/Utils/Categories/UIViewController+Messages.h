//
//  UIViewController+Messages.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MessageCallback)();

@interface UIViewController (Messages)

- (void) showInfoMessage:(NSString *)text withTitle:(NSString *)title;

- (void) showInfoMessage:(NSString *)text withTitle:(NSString *)title callback:(MessageCallback)callback;


@end
