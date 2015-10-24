//
//  VSHint.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/24/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSHint.h"

@implementation VSHint

+ (instancetype)hintWithTitle:(NSString *)title message:(NSString *)message{
    
    VSHint* hint = [VSHint new];
    hint.title = title;
    hint.message = message;
    return hint;
    
}

- (BOOL) isEqual:(VSHint*)object
{
    return
    [object         isMemberOfClass:[VSHint class]] &&
    [object.message isEqualToString:self.message] &&
    [object.title   isEqualToString:self.title];
}

@end
