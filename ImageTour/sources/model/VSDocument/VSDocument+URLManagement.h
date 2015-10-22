//
//  VSDocument+URLManagement.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocument.h"

#define VS_EXTENSION @"vs"

@interface VSDocument (URLManagement)

+ (NSArray<VSDocument*>*)localImageTourDocuments;

+ (NSURL*) newUniqueUrlForDocument;

@end
