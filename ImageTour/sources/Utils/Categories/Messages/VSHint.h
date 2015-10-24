//
//  VSHint.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/24/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSHint : NSObject

+ (instancetype) hintWithTitle:(NSString*)title
                       message:(NSString*)message;

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* message;

@end
