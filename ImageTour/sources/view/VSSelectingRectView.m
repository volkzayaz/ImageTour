//
//  VSSlectingRectView.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/21/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSSelectingRectView.h"

const CGFloat deviation = 40.;
const CGFloat minSize = 30.;

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

@property (nonatomic, weak) UIImageView* baseThumbForDragging;

@end

@implementation VSSelectingRectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        self.upperLeftThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle.png"]];
        self.upperRightThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle.png"]];
        self.bottomLeftThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle.png"]];
        self.bottomRightThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Circle.png"]];
        
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
    
    if(distance(location, upperLeftCenter) < deviation){
        self.baseThumbForDragging = self.upperLeftThumb;
    }
    else if (distance(location, upperRightCenter) < deviation) {
        self.baseThumbForDragging = self.upperRightThumb;
    }
    else if(distance(location, bottomLeftCenter) < deviation) {
        self.baseThumbForDragging = self.bottomLeftThumb;
    }
    else if (distance(location, bottomRightCenter) < deviation) {
        self.baseThumbForDragging = self.bottomRightThumb;
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
    
    ///we don't want to drag view beyond superview
    if(moveLocation.x < 0 || moveLocation.x > parentViewSize.width ||
       moveLocation.y < 0 || moveLocation.y > parentViewSize.height)
        return;
    
    CGRect previosRect = self.frame;
    CGRect newRect = previosRect;
    
    if(self.baseThumbForDragging == self.upperLeftThumb &&
       CGRectGetMaxX(previosRect) - moveLocation.x > minSize &&//we don't want view to be smaller than allowed size
       CGRectGetMaxY(previosRect) - moveLocation.y > minSize)
    {
        newRect = CGRectMake(moveLocation.x,
                             moveLocation.y,
                             CGRectGetMaxX(previosRect) - moveLocation.x,
                             CGRectGetMaxY(previosRect) - moveLocation.y);
    }
    else if (self.baseThumbForDragging == self.upperRightThumb &&
             moveLocation.x - CGRectGetMinX(previosRect) > minSize &&
             CGRectGetMaxY(previosRect) - moveLocation.y > minSize)
    {
        newRect = CGRectMake(previosRect.origin.x,
                             moveLocation.y,
                             moveLocation.x - CGRectGetMinX(previosRect),
                             CGRectGetMaxY(previosRect) - moveLocation.y);
    }
    else if (self.baseThumbForDragging == self.bottomLeftThumb &&
             CGRectGetMaxX(previosRect) - moveLocation.x > minSize &&
             moveLocation.y - CGRectGetMinY(previosRect) > minSize)
    {
        newRect = CGRectMake(moveLocation.x,
                             previosRect.origin.y,
                             CGRectGetMaxX(previosRect) - moveLocation.x,
                             moveLocation.y - CGRectGetMinY(previosRect));
    }
    else if (self.baseThumbForDragging == self.bottomRightThumb &&
             moveLocation.x - CGRectGetMinX(previosRect) > minSize &&
             moveLocation.y - CGRectGetMinY(previosRect) > minSize)
    {
        newRect = CGRectMake(previosRect.origin.x,
                             previosRect.origin.x,
                             moveLocation.x - CGRectGetMinX(previosRect),
                             moveLocation.y - CGRectGetMinY(previosRect));
    }
    
    self.frame = newRect;
    
    [self.delegate didChangeSelectedFrame:newRect];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    
    self.upperLeftThumb.frame = CGRectMake(0, 0, 10, 10);
    self.upperRightThumb.frame = CGRectMake(0, 0, 10, 10);
    self.bottomLeftThumb.frame = CGRectMake(0, 0, 10, 10);
    self.bottomRightThumb.frame = CGRectMake(0, 0, 10, 10);
    
    self.upperLeftThumb.center = CGPointZero;
    self.upperRightThumb.center = (CGPoint){viewSize.width,0};
    self.bottomLeftThumb.center = (CGPoint){0,viewSize.height};
    self.bottomRightThumb.center = (CGPoint){viewSize.width,viewSize.height};
}


@end
