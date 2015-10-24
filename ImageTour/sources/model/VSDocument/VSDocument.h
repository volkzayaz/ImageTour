//
//  VSDocument.h
//  ImageTour
//
//  Created by 286 on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TourImage.h"
#import "FullImage.h"

@class VSDocument;

typedef void(^VSImportDocumentCallback)(VSDocument* newDocument, NSError* error);

@interface VSDocument : UIManagedDocument

/**
 *  @discussion - shorthand for creating documents with irrelevant unique names/urls
 */
+ (VSDocument*) createNewLocalDocumentInURL:(NSURL*)url;

/**
 *  @discussion - method serializes document and puts to the disk as a temporary file.
 *  @returns URL for serialized temporary document which can be passed to third party applications
 */
- (NSURL*) prepareForExport;
+ (void) importDcoumentFromURL:(NSURL*)inputURL
                         toURL:(NSURL*) outputURL
              withCompletition:(VSImportDocumentCallback) calback;

////
/*  data manipulations  */
////

- (FullImage*) initialImageForTour;
- (FullImage* /*nullable*/) nextImageForTappingOnPoint:(CGPoint)point
                                               onImage:(FullImage*)tourImage;
- (FullImage*) imageForManagedObjectID:(NSManagedObjectID*)objectID;

- (NSFetchedResultsController*) allThumbnails;

- (void) addLinkWithRect:(CGRect)linkRect
               fromImage:(TourImage*)fromImage
                 toImage:(TourImage*)toImage;
- (NSArray<NSValue*>* /*CGRect*/) rectsForImage:(TourImage*)image;

- (TourImage*) addImageWithImage:(UIImage*)image;
- (void) deleteImage:(TourImage*)image;

@end
