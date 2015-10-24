//
//  UIViewController+Messages.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "UIViewController+Messages.h"

#import "VSPreferences.h"
#import "VSHint.h"

static NSMutableArray* hintQueue = nil;
NSMutableArray* getHintQueue() {
    if(!hintQueue)
        hintQueue = [NSMutableArray array];
    return hintQueue;
}

static NSMutableArray* shownHints = nil;
NSMutableArray* getShownHints() {
    if(!shownHints)
        shownHints = [NSMutableArray array];
    return shownHints;
}

@implementation UIViewController (Messages)

#pragma mark - regular info messages

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

#pragma mark - hints

- (void)showGreeting
{
    [self showHintOnceWithTitle:@"Вітаю в ImageTour!" message:@"Такі підказки будуть з'являтися на кожному екрані, щоб допомогти вам зорієнтуватися і дати підказки по користуванню додатком. Ось і перша підказка: ви можете вимкнути всі підказки в налаштуваннях вашого пристрою в розділі додатку ImageTour 😊"];
}

- (void)showHintOnceWithTitle:(NSString *)title message:(NSString *)message
{
    VSHint* hint = [VSHint hintWithTitle:title message:message];
    
    if(![getShownHints() containsObject:hint])
    {
        [self dispathcHint:hint];
    }
}

#pragma mark - hints diplaying queue

- (void) dispathcHint:(VSHint*)hint{
    if(![VSPreferences showsHintsOnViews])
        return;
    
    [getHintQueue() addObject:hint];
    if(getHintQueue().count == 1)//queue was empty
        [self displayHint:hint];
    
}

- (void) displayHint:(VSHint*)hint
{
    if(!hint)
        return;
    
    [self showInfoMessage:hint.message withTitle:hint.title callback:^{
        VSHint* hint = [getHintQueue() firstObject];
        [getHintQueue() removeObject:hint];
        [getShownHints() addObject:hint];
        
        [self displayHint:getHintQueue().firstObject];
    }];

}

@end

