//
//  VSImageTourMapData.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSImageTourMapData.h"

@interface VSImageTourMapData()

@property (nonatomic, strong) NSMutableDictionary<NSNumber*,//index of initial image
                                                  NSMutableDictionary<NSValue*,NSNumber*>*///CGRect, index of target image
                                                 >* tourMap;

@property (nonatomic, strong) NSNumber* imageFileNameIncrement;

@end

@implementation VSImageTourMapData

- (instancetype)initWithTourMap:(NSMutableDictionary<NSNumber*, NSMutableDictionary<NSValue*,NSNumber*>*>*)map
                      increment:(NSNumber*)increment
{
    self = [super init];
    
    if (self)
    {
        self.tourMap = map;
        self.imageFileNameIncrement = increment;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithTourMap:[NSMutableDictionary dictionary] increment:@(0)];
}

- (NSNumber*)registerNewImage:(UIImage *)image
{
    NSNumber* answer = self.imageFileNameIncrement.copy;
    
    self.tourMap[self.imageFileNameIncrement] = [NSMutableDictionary dictionary];
    self.imageFileNameIncrement = @(self.imageFileNameIncrement.integerValue + 1);
    
    return answer;
}

- (void)unregisterImageForFileKey:(NSNumber *)fileKey {
    [self.tourMap removeObjectForKey:fileKey];
#warning optimize deleting
    ///here we itterate over all other image links and trying to find images that have links to currently deleted image
    for(NSMutableDictionary<NSValue*,NSNumber*>* value in self.tourMap.allValues) {
        for(NSValue* key in value.allKeys.copy)
        {
            NSNumber* index = value[key];
            if([index isEqualToNumber:fileKey]) {
                [value removeObjectForKey:key];
            }
        }
    }
}

- (NSNumber *)fileIndexForPoint:(CGPoint)point onIndex:(NSNumber *)index {
    NSMutableDictionary<NSValue*, NSNumber*>* links = self.tourMap[index];

    for(NSValue* value in links.allKeys) {
        
        CGRect rect = [value CGRectValue];
        
        if(CGRectContainsPoint(rect, point))
        {
            return links[value];
        }
    }
    
    ///point does not match any rectangles
    return nil;
}

- (void)registerRect:(CGRect)rect originIndex:(NSNumber *)originIndex destinationIndex:(NSNumber *)destIndex {
    NSMutableDictionary* links = self.tourMap[originIndex];
    links[[NSValue valueWithCGRect:rect]] = destIndex;
}

- (NSArray<NSNumber *> *)availableImageIndexes {
    
    return self.tourMap.allKeys;
    
}

- (NSNumber *)initialIndex {
    return self.tourMap.allKeys.firstObject;
}

- (NSArray<NSValue *> *)rectsForOriginIndex:(NSNumber *)index
{
    return [self.tourMap[index] allKeys];
}

#pragma mark NSCoding

#define kMapKey @"map"
#define kIncrementKey @"increment"

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.tourMap forKey:kMapKey];
    [encoder encodeObject:self.imageFileNameIncrement forKey:kIncrementKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    return [self initWithTourMap:[decoder decodeObjectForKey:kMapKey]
                       increment:[decoder decodeObjectForKey:kIncrementKey]];
}

@end
