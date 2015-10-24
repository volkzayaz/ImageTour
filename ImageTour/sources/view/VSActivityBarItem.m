//
//  VSActivityBarItem.m
//  ImageTour
//
//  Created by 286 on 10/23/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSActivityBarItem.h"

@interface VSActivityBarItem()

@property (nonatomic, weak) UIActivityIndicatorView* activityView;

@end

@implementation VSActivityBarItem

+ (VSActivityBarItem *)activityBarItem
{
    UIActivityIndicatorView* activityIndicator =
    [[UIActivityIndicatorView alloc]
     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    VSActivityBarItem* item = [[self alloc] initWithCustomView:activityIndicator];
    item.activityView = activityIndicator;
    
    return item;
}

- (void)startAnimating
{
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
}

- (void)stopAnimating
{
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}

@end
