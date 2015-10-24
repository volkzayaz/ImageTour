//
//  VSSlectingRectView.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSSelectingRectView.h"

const CGFloat kDeviation = 40.;
const CGFloat kMinSize = 50.;

const CGFloat distance(CGPoint p1, CGPoint p2) {
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

@interface VSSelectingRectView()

@property (nonatomic, strong) UIImageView* upperLeftThumb;
@property (nonatomic, strong) UIImageView* upperRightThumb;
@property (nonatomic, strong) UIImageView* bottomLeftThumb;
@property (nonatomic, strong) UIImageView* bottomRightThumb;

@property (nonatomic, weak)   UIImageView* baseThumbForDragging;

@end

@implementation VSSelectingRectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.upperLeftThumb   = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
        self.upperRightThumb  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
        self.bottomLeftThumb  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
        self.bottomRightThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
        
        [self addSubview:self.upperRightThumb];
        [self addSubview:self.upperLeftThumb];
        [self addSubview:self.bottomLeftThumb];
        [self addSubview:self.bottomRightThumb];
        
        self.layer.borderWidth = 1.;
        self.layer.borderColor = [UIColor orangeColor].CGColor;
        
        self.clipsToBounds = NO;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [touches.anyObject locationInView:self];
    
    CGPoint upperLeftCenter = self.upperLeftThumb.center;
    CGPoint upperRightCenter = self.upperRightThumb.center;
    CGPoint bottomLeftCenter = self.bottomLeftThumb.center;
    CGPoint bottomRightCenter = self.bottomRightThumb.center;
    
    if(distance(location, upperLeftCenter) < kDeviation){
        self.baseThumbForDragging = self.upperLeftThumb;
    }
    else if (distance(location, upperRightCenter) < kDeviation) {
        self.baseThumbForDragging = self.upperRightThumb;
    }
    else if(distance(location, bottomLeftCenter) < kDeviation) {
        self.baseThumbForDragging = self.bottomLeftThumb;
    }
    else if (distance(location, bottomRightCenter) < kDeviation) {
        self.baseThumbForDragging = self.bottomRightThumb;
    }
    else
    {
        self.baseThumbForDragging = nil;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.baseThumbForDragging = nil;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint moveLocation = [touches.anyObject locationInView:self.superview];
    
    CGSize parentViewSize = self.superview.bounds.size;
    CGSize selfSize = self.bounds.size;
    
    ///we don't want to drag view beyond superview
    if(moveLocation.x <= 0 || moveLocation.x >= parentViewSize.width ||
       moveLocation.y <= 0 || moveLocation.y >= parentViewSize.height)
        return;
    
    CGRect previosRect = self.frame;
    CGRect newRect = previosRect;
    
    if(self.baseThumbForDragging == self.upperLeftThumb &&
       CGRectGetMaxX(previosRect) - moveLocation.x > kMinSize &&//we don't want view to be smaller than allowed size
       CGRectGetMaxY(previosRect) - moveLocation.y > kMinSize)
    {
        newRect = CGRectMake(moveLocation.x,
                             moveLocation.y,
                             CGRectGetMaxX(previosRect) - moveLocation.x,
                             CGRectGetMaxY(previosRect) - moveLocation.y);
    }
    else if (self.baseThumbForDragging == self.upperRightThumb &&
             moveLocation.x - CGRectGetMinX(previosRect) > kMinSize &&
             CGRectGetMaxY(previosRect) - moveLocation.y > kMinSize)
    {
        newRect = CGRectMake(previosRect.origin.x,
                             moveLocation.y,
                             moveLocation.x - CGRectGetMinX(previosRect),
                             CGRectGetMaxY(previosRect) - moveLocation.y);
    }
    else if (self.baseThumbForDragging == self.bottomLeftThumb &&
             CGRectGetMaxX(previosRect) - moveLocation.x > kMinSize &&
             moveLocation.y - CGRectGetMinY(previosRect) > kMinSize)
    {
        newRect = CGRectMake(moveLocation.x,
                             previosRect.origin.y,
                             CGRectGetMaxX(previosRect) - moveLocation.x,
                             moveLocation.y - CGRectGetMinY(previosRect));
    }
    else if (self.baseThumbForDragging == self.bottomRightThumb &&
             moveLocation.x - CGRectGetMinX(previosRect) > kMinSize &&
             moveLocation.y - CGRectGetMinY(previosRect) > kMinSize)
    {
        newRect = CGRectMake(previosRect.origin.x,
                             previosRect.origin.y,
                             moveLocation.x - CGRectGetMinX(previosRect),
                             moveLocation.y - CGRectGetMinY(previosRect));
    }
    else if (self.baseThumbForDragging == nil &&
             moveLocation.x + selfSize.width  / 2 <= parentViewSize.width  &&//right border
             moveLocation.x - selfSize.width  / 2 >= 0                     &&//leftBorder
             moveLocation.y + selfSize.height / 2 <= parentViewSize.height &&//bottom border
             moveLocation.y - selfSize.height / 2 >= 0)
    {
        newRect = CGRectMake(moveLocation.x - previosRect.size.width  / 2,
                             moveLocation.y - previosRect.size.height / 2,
                             previosRect.size.width,
                             previosRect.size.height);
    }
    
    self.frame = newRect;
    
    [self.delegate didChangeSelectedFrame:newRect];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    CGFloat r = 5;
    CGFloat twoR = r * 2;
    
    self.upperLeftThumb.frame   = CGRectMake(0, 0, twoR, twoR);
    self.upperRightThumb.frame  = CGRectMake(0, 0, twoR, twoR);
    self.bottomLeftThumb.frame  = CGRectMake(0, 0, twoR, twoR);
    self.bottomRightThumb.frame = CGRectMake(0, 0, twoR, twoR);
    
    self.upperLeftThumb.center   = (CGPoint){r,r};
    self.upperRightThumb.center  = (CGPoint){viewSize.width - r,r};
    self.bottomLeftThumb.center  = (CGPoint){r,viewSize.height - r};
    self.bottomRightThumb.center = (CGPoint){viewSize.width - r,viewSize.height - r};
}


@end
