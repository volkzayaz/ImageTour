//
//  NSOperationQueue+Sugar.h
//  ImageTour
//
//  Created by 286 on 10/23/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (Sugar)

/**
 *  @discussion - shorthand for executing some job on background and execute comletition block on main thread
 *  @param work - may returns arbitrary object. It will be passed to nextUIBlock as @param res.
 */
+ (void) dispatchJob:(id(^)())work
         nextUIBlock:(void(^)(id res))block;

@end
