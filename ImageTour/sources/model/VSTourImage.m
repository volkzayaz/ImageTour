//
//  VSTourImage.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSTourImage.h"

@interface VSTourImage()

@property (nonatomic, strong, readwrite) UIImage* image;
@property (nonatomic, strong, readwrite) NSNumber* fileKey;

@end

@implementation VSTourImage

- (instancetype)initWithImage:(UIImage *)image fileKey:(NSNumber *)fileKey
{
    self = [super init];
    
    if(self)
    {
        self.image = image;
        self.fileKey = fileKey;
    }
    
    return self;
}

@end
