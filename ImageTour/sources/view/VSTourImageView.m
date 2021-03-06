//
//  VSTourImageView.m
//  ImageTour
//
//  Created by 286 on 10/22/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSTourImageView.h"
#import "VSTransformUtility.h"

@interface VSTourImageView()

@property (nonatomic, strong) NSMutableDictionary<NSValue*,UIView*>* attentionViews;

@end

@implementation VSTourImageView

- (NSMutableDictionary *)attentionViews {
    if(!_attentionViews)
        _attentionViews = [NSMutableDictionary dictionary];
    return _attentionViews;
}

- (void)displayAttentionBoxInRect:(CGRect)rect
{
    UIView* rectView = [[UIView alloc] initWithFrame:rect];
    rectView.userInteractionEnabled = NO;
    rectView.layer.borderColor = [UIColor redColor].CGColor;
    rectView.layer.borderWidth = 1.;
    [self addSubview:rectView];
    
    self.attentionViews[[NSValue valueWithCGRect:rect]] = rectView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for(NSValue* val in self.attentionViews.allKeys)
    {
        UIView* view = self.attentionViews[val];
        
        view.frame = [VSTransformUtility transformedRectFromRect:val.CGRectValue
                                                      originSize:self.image.size
                                                 destinationSize:self.frame.size];
    }
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    
    [self.attentionViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.attentionViews removeAllObjects];
}

@end
