//
//  NSOperationQueue+Sugar.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/23/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "NSOperationQueue+Sugar.h"

@implementation NSOperationQueue (Sugar)

+ (void)dispatchJob:(id (^)())work nextUIBlock:(void (^)(id res))block
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        id result = work();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(result);
        }];
    }];
}

@end
