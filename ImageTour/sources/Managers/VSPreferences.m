//
//  VSPreferences.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/24/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSPreferences.h"

@implementation VSPreferences

+ (void)load
{
    [super load];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"com.286.showHints-preference" : @YES,
                                                              @"com.286.showSelections-preference" : @YES
                                                              }];
}

+ (BOOL)showsHintsOnViews
{
    BOOL a = [[NSUserDefaults standardUserDefaults] boolForKey:@"com.286.showHints-preference"];
    return a;
}

+ (BOOL)showsSelectionAreas
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"com.286.showSelections-preference"];
}

@end
