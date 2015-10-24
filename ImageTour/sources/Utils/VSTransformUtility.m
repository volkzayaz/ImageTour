//
//  TransformUtility.m
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSTransformUtility.h"

@implementation VSTransformUtility

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
