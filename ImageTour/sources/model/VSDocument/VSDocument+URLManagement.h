//
//  VSDocument+URLManagement.h
//  ImageTour
//
//  Created by 286 on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocument.h"

#define VS_EXTENSION @"vs"

@interface VSDocument (URLManagement)

+ (NSArray<VSDocument*>*)localImageTourDocuments;

+ (NSURL*) newUniqueUrlForDocument;
+ (NSURL*) urlForExampleDocument;
+ (NSURL*) urlForTemporaryDocument;

+ (BOOL) validateURL: (NSURL*)tourImageDocumentURL;

@end
