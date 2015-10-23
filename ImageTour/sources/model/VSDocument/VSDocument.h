//
//  VSDocument.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TourImage.h"
#import "FullImage.h"

@class VSDocument;

typedef void(^VSImportDocumentCallback)(VSDocument* newDocument, NSError* error);

@interface VSDocument : UIManagedDocument

+ (VSDocument*) createNewLocalDocumentInURL:(NSURL*)url;

- (NSURL*) prepareForExport;
+ (void) importDcoumentFromURL:(NSURL*)inputURL
                         toURL:(NSURL*) outputURL
              withCompletition:(VSImportDocumentCallback) calback;

///Image from which tour starts
///image should also have some name string
- (FullImage*) initialImageForTour;

- (NSFetchedResultsController*) allThumbnails;

- (FullImage* /*nullable*/) nextImageForTappingOnPoint:(CGPoint)point onImage:(FullImage*)tourImage;
- (FullImage*) imageForManagedObjectID:(NSManagedObjectID*)objectID;

- (TourImage*) addImageWithImage:(UIImage*)image;

- (void) addLinkWithRect:(CGRect)linkRect fromImage:(TourImage*)fromImage toImage:(TourImage*)toImage;
- (NSArray<NSValue*>* /*CGRect*/) rectsForImage:(TourImage*)image;

- (void) deleteImage:(TourImage*)image;

- (void) deleteDocumentWithCompletition:(void(^)(BOOL success))callback;

@end
