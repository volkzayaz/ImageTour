//
//  UIViewController+Messages.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "UIViewController+Messages.h"

@implementation UIViewController (Messages)

- (void) showInfoMessage:(NSString *)text withTitle:(NSString *)title
{
    [self showInfoMessage:text withTitle:title callback:nil];
}

- (void) showInfoMessage:(NSString *)text withTitle:(NSString *)title callback:(MessageCallback)callback
{
    UIAlertController* controler = [UIAlertController alertControllerWithTitle:title message:text
                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    [controler addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if(callback)
            callback();
    }]];
    
    [self presentViewController:controler animated:YES completion:nil];
}


@end
