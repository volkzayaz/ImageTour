//
//  VSTourImage.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

@import UIKit;

@interface VSTourImage : NSObject

- (instancetype)initWithImage:(UIImage*)image fileKey:(NSNumber*)fileKey;

@property (nonatomic, strong, readonly) UIImage* image;
@property (nonatomic, strong, readonly) NSNumber* fileKey;

@end
