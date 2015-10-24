//
//  VSPreferences.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/24/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSPreferences.h"

NSString* const kShowHintsKey = @"com.286.showHints-preference";
NSString* const kShowSelectionKey = @"com.286.showSelections-preference";

@implementation VSPreferences

+ (void)load
{
    [super load];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kShowHintsKey     : @YES,
                                                              kShowSelectionKey : @YES
                                                              }];
}

+ (BOOL)showsHintsOnViews
{
    BOOL a = [[NSUserDefaults standardUserDefaults] boolForKey:kShowHintsKey];
    return a;
}

+ (BOOL)showsSelectionAreas
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShowSelectionKey];
}

@end
