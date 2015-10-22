//
//  NSArray+Utils.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "NSArray+Utils.h"

@implementation NSArray (Utils)

- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: [self count]];
    for(id obj in self)
        [array addObject: block(obj)];
    return array;
}

@end
