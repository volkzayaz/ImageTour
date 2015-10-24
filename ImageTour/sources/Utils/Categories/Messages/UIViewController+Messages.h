//
//  UIViewController+Messages.h
//  ImageTour
//
//  Created by 286 on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MessageCallback)();

@interface UIViewController (Messages)

- (void) showInfoMessage:(NSString *)text withTitle:(NSString *)title;
- (void) showInfoMessage:(NSString *)text withTitle:(NSString *)title callback:(MessageCallback)callback;

/**
 *  @discussion - Hints differ from info messages in two ways:
 *  1) Hints tolerate user settings for "Show hints?"
 *  2) Hints can be queued once per application lifetime. So it is possible to adress multiple calls of 
 *  -showHint.
 */
- (void) showGreeting;
- (void) showHintOnceWithTitle:(NSString*)title message:(NSString*)message;

@end
