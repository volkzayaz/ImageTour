//
//  TransformUtility.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "TransformUtility.h"

@implementation TransformUtility

+ (CGAffineTransform) transformForOriginSize:(CGSize)originSize
                             destinationSize:(CGSize)destSize
{
    return CGAffineTransformMakeScale(destSize.width / originSize.width,
                                      destSize.height / originSize.height);
}

+ (CGPoint)transformedPoint:(CGPoint)point
                 originSize:(CGSize)originSize
            destinationSize:(CGSize)destSize
{
    return CGPointApplyAffineTransform(point, [self transformForOriginSize:originSize
                                                           destinationSize:destSize]);
}

+ (CGRect)transformedRectFromRect:(CGRect)rect
                       originSize:(CGSize)originSize
                  destinationSize:(CGSize)destSize
{
    return CGRectApplyAffineTransform(rect, [self transformForOriginSize:originSize
                                                         destinationSize:destSize]);
}

@end
