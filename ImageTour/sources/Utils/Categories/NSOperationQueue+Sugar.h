//
//  NSOperationQueue+Sugar.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/23/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (Sugar)

+ (void) dispatchJob:(id(^)())work nextUIBlock:(void(^)(id res))block;

@end
