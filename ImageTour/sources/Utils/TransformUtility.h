//
//  TransformUtility.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

@import UIKit;

@interface TransformUtility : NSObject

+ (CGRect) transformedRectFromRect:(CGRect)rect
                        originSize:(CGSize)originSize
                   destinationSize:(CGSize)destSize;

+ (CGPoint) transformedPoint:(CGPoint)point
                        originSize:(CGSize)originSize
                   destinationSize:(CGSize)destSize;



@end
