//
//  NSArray+Utils.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utils)

- (NSArray*) map:(id(^)(id obj))block;

@end
