//
//  VSDocument.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

@import CoreData;

#import "VSDocument.h"

#import "UIImage+Resize.h"
#import "VSDocument+URLManagement.h"
#import "ImageLink.h"

/**
 *  Document structure is the following:
 *                                    Root directory
 *                                /        |           \
 *                               /         |            \
 *                    tourMapData     image_thumbnails..  full_scale_image...
 * obj-c types  VSImageTourMapData*   UIImage               UIImage
 *
 * Each full_scale and thumbnail images are encoded as a seperate NSFileWrappers inside root directory
 */

CGSize kThumbnailSize = (CGSize){100, 100};

@interface VSDocument ()

@property (nonatomic, strong) NSManagedObjectModel *myManagedObjectModel;

@end

@implementation VSDocument

- (instancetype)initWithFileURL:(NSURL *)url {
    self = [super initWithFileURL:url];

    if (self)
    {
    }
    
    return self;
}

+ (VSDocument*) createNewLocalDocumentInURL:(NSURL *)documentURL
{
    VSDocument* newDocument = [[VSDocument alloc] initWithFileURL:documentURL];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};
    newDocument.persistentStoreOptions = options;
    
    return newDocument;
}

- (void)deleteDocumentWithCompletition:(void (^)(BOOL success))callback
{
    
}

#pragma mark - document import/export

- (NSURL *)prepareForExport
{
    NSError* error = nil;
    NSURL *url = self.fileURL;
    NSFileWrapper *dirWrapper = [[NSFileWrapper alloc] initWithURL:url options:0 error:&error];
    if (dirWrapper == nil) {
        NSLog(@"Error creating directory wrapper: %@", error.localizedDescription);
        return nil;
    }
    
    NSData* data = [dirWrapper serializedRepresentation];
    NSURL* exportURL = [VSDocument urlForTemporaryDocument];
    [data writeToURL:exportURL atomically:YES];

    return exportURL;
}

+ (void)importDcoumentFromURL:(NSURL *)inputURL
                        toURL:(NSURL *)outputURL
             withCompletition:(VSImportDocumentCallback)callback
{
#warning - take care of bad code structure
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSData* serializedData = [NSData dataWithContentsOfURL:inputURL];
        NSURL* newDocumentURl = outputURL;
        
        NSFileWrapper* fw = [[NSFileWrapper alloc] initWithSerializedRepresentation:serializedData];
        
        NSError* er = nil;
        if(![fw writeToURL:newDocumentURl
                   options:0
       originalContentsURL:nil///copying files rather than links to passed URL
                     error:&er])
        {
            if(callback)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    callback(nil,er);
                }];
            }
        }
        
        VSDocument* newDoc = [VSDocument createNewLocalDocumentInURL:newDocumentURl];
        
        if(callback)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                callback(newDoc,nil);
            }];
        }
    }];
}

#pragma mark - document managament

-(NSManagedObjectModel*)myManagedObjectModel {
    if (_myManagedObjectModel)
        return _myManagedObjectModel;
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *modelPath = [bundle pathForResource:@"TourImageModel" ofType:@"momd"];
    _myManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
    return _myManagedObjectModel;
}

-(NSManagedObjectModel*)managedObjectModel {
    return self.myManagedObjectModel;
}

- (FullImage*) initialImageForTour {
    NSEntityDescription* entityDescr = [NSEntityDescription entityForName:NSStringFromClass([FullImage class])
                                                   inManagedObjectContext:self.managedObjectContext.parentContext];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescr];
    [request setFetchLimit:1];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"tourImage.createdDate" ascending:YES]]];

    FullImage* image = [self.managedObjectContext.parentContext executeFetchRequest:request error:nil].firstObject;
    
    return image;
}

- (NSFetchedResultsController*) allThumbnails{
    
    NSString *cacheName = [NSString stringWithFormat:@"VSTourImage-Cache-%@", NSStringFromClass([self class])];
    
    NSEntityDescription* entityDescr = [NSEntityDescription entityForName:NSStringFromClass([TourImage class])
                                                   inManagedObjectContext:self.managedObjectContext];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescr];
    [request setFetchBatchSize:20];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:YES]]];
    
    NSFetchedResultsController *controller =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:cacheName];
    
    return controller;
}

- (TourImage*)addImageWithImage:(UIImage *)image {
    NSData* fullImageData = UIImagePNGRepresentation(image);
    NSData* thumbnailImageData = UIImagePNGRepresentation([image proportionalResizeForSize:kThumbnailSize]);

    
    NSEntityDescription* entityDescr = [NSEntityDescription entityForName:NSStringFromClass([TourImage class])
                                                   inManagedObjectContext:self.managedObjectContext];
    NSEntityDescription* fullImageEntityDescr = [NSEntityDescription entityForName:NSStringFromClass([FullImage class])
                                                   inManagedObjectContext:self.managedObjectContext];
    
    
    TourImage* thumbImage = [[TourImage alloc] initWithEntity:entityDescr
                          insertIntoManagedObjectContext:self.managedObjectContext];
    FullImage* fullImage = [[FullImage alloc] initWithEntity:fullImageEntityDescr
                              insertIntoManagedObjectContext:self.managedObjectContext];
    
    thumbImage.fullImage = fullImage;
    thumbImage.thumbnail = thumbnailImageData;
    thumbImage.createdDate = [NSDate date];
    
    fullImage.imageData = fullImageData;
    
#warning set up error handling
    [self.managedObjectContext save:nil];
    [self.managedObjectContext refreshObject:thumbImage mergeChanges:NO];
    [self.managedObjectContext refreshObject:fullImage mergeChanges:NO];
    [self updateChangeCount:UIDocumentChangeDone];
    
    return thumbImage;
}

- (void)deleteImage:(TourImage *)image {
    [image.managedObjectContext deleteObject:image];
    
    [self.managedObjectContext save:nil];
}

- (FullImage *)nextImageForTappingOnPoint:(CGPoint)point onImage:(FullImage *)tourImage {

    NSFetchRequest* allLinksRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ImageLink class])];
    allLinksRequest.predicate = [NSPredicate predicateWithFormat:@"fromTourImage.fullImage == %@",tourImage];
    
    NSArray* allLinks = [self.managedObjectContext executeFetchRequest:allLinksRequest error:nil];
    
    for(ImageLink* link in allLinks) {
        
        CGRect rect = [link.linkRect CGRectValue];
        
        if(CGRectContainsPoint(rect, point))
        {
            return link.toTourImage.fullImage;
        }
    }
    
    ///no links for point found
    return nil;
}

- (FullImage *)imageForManagedObjectID:(NSManagedObjectID *)objectID
{
    return [self.managedObjectContext objectWithID:objectID];
}

- (NSArray<NSValue *> *)rectsForImage:(TourImage *)image
{
    NSFetchRequest* allLinksRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ImageLink class])];
    allLinksRequest.predicate = [NSPredicate predicateWithFormat:@"fromTourImage == %@",image];
    
    NSArray* allLinks = [self.managedObjectContext executeFetchRequest:allLinksRequest error:nil];

    return [allLinks valueForKey:@"linkRect"];
}

- (void)addLinkWithRect:(CGRect)linkRect
              fromImage:(TourImage *)fromImage
                toImage:(TourImage *)toImage
{
    NSEntityDescription* entityDescr = [NSEntityDescription entityForName:NSStringFromClass([ImageLink class])
                                                   inManagedObjectContext:self.managedObjectContext];
    
    ImageLink* link = [[ImageLink alloc] initWithEntity:entityDescr
                         insertIntoManagedObjectContext:self.managedObjectContext];
    
    link.linkRect = [NSValue valueWithCGRect:linkRect];
    link.fromTourImage = [self.managedObjectContext existingObjectWithID:fromImage.objectID error:nil];
    link.toTourImage = [self.managedObjectContext existingObjectWithID:toImage.objectID error:nil];
    
    [self.managedObjectContext save:nil];
    

}

@end
