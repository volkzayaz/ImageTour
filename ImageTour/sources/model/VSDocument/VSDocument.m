//
//  VSDocument.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

@import CoreData;
#import "VSDocument.h"
#import "ImageLink.h"

#import "UIImage+Resize.h"
#import "VSDocument+URLManagement.h"
#import "NSOperationQueue+Sugar.h"

CGSize kThumbnailSize = (CGSize){100, 100};

@interface VSDocument ()

@property (nonatomic, strong) NSManagedObjectModel *vsManagedObjectModel;

@end

@implementation VSDocument

+ (VSDocument*) createNewLocalDocumentInURL:(NSURL *)documentURL
{
    VSDocument* newDocument = [[VSDocument alloc] initWithFileURL:documentURL];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES};
    newDocument.persistentStoreOptions = options;
    
    return newDocument;
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
    [NSOperationQueue dispatchJob:^id{
        NSData* serializedData = [NSData dataWithContentsOfURL:inputURL];
        NSURL* newDocumentURl = outputURL;
        
        NSFileWrapper* fw = [[NSFileWrapper alloc] initWithSerializedRepresentation:serializedData];
        
        NSError* error = nil;
        if(![fw writeToURL:newDocumentURl
                   options:0
       originalContentsURL:nil///copying files rather than links to passed URL
                     error:&error])
        {
            return error;
        }
        
        return [VSDocument createNewLocalDocumentInURL:newDocumentURl];
    } nextUIBlock:^(id res) {
        if(callback)
        {
            if ([res isKindOfClass:[NSError class]])
                callback(nil,res);
            
            callback(res, nil);
        }
    }];
}

-(NSManagedObjectModel*)vsManagedObjectModel {
    if (_vsManagedObjectModel)
        return _vsManagedObjectModel;
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"TourImageModel"
                                                          ofType:@"momd"];
    _vsManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:
                             [NSURL fileURLWithPath:modelPath]];
    
    return _vsManagedObjectModel;
}

-(NSManagedObjectModel*)managedObjectModel {
    return self.vsManagedObjectModel;
}

#pragma mark - document managament

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

- (TourImage*)addImageWithImage:(UIImage *)inputImage {
    UIImage* image = [inputImage normalizedImage];
    
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

- (FullImage *)nextImageForTappingOnPoint:(CGPoint)point onImage:(FullImage *)tourImage{

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
