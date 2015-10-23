//
//  VSActivityBarItem.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/23/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSActivityBarItem : UIBarButtonItem

+ (VSActivityBarItem*) activityBarItem;

- (void) startAnimating;
- (void) stopAnimating;

@end
