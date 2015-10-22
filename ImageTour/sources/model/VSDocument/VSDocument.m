//
//  VSDocument.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocument.h"
#import "VSImageTourMapData.h"

#import "UIImage+Resize.h"
#import "NSArray+Utils.h"

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

NSString* const kTourMapDataFilename = @"tourMapData";
NSString* kFullScaleImageKeyForIndex(NSNumber* index) {
    return [NSString stringWithFormat:@"fullScaleImage_%li",index.integerValue];
}
NSString* kThumbnailImageKeyForIndex(NSNumber* index) {
    return [NSString stringWithFormat:@"thumbnailImage_%li",index.integerValue];
}
CGSize kThumbnailSize = (CGSize){100, 100};

@interface VSDocument ()

@property (nonatomic, strong) NSFileWrapper* fileWrapper;

@property (nonatomic, strong) VSImageTourMapData* tourMapData;

@property (nonatomic, strong) NSMutableArray<VSTourImage*>* imagesToSave;
@property (nonatomic, strong) NSMutableArray<VSTourImage*>* imagesToDelete;

@end

@implementation VSDocument

- (instancetype)initWithFileURL:(NSURL *)url {
    self = [super initWithFileURL:url];

    if (self)
    {
        self.imagesToSave = [NSMutableArray array];
        self.imagesToDelete = [NSMutableArray array];
        
        self.tourMapData = [[VSImageTourMapData alloc] init];
    }
    
    return self;
}

- (VSTourImage*) initialImageForTour {
    NSNumber* index = [self.tourMapData initialIndex];
    
    return [self fullScaleImageForFileKey:index];
}

- (VSTourImage *)fullScaleImageForThumbnail:(VSTourImage *)image
{
    NSData* fullScaleData = [self decodeObjectFromWrapperWithPreferredFilename:kFullScaleImageKeyForIndex(image.fileKey)];
    
    return [[VSTourImage alloc] initWithImage:[UIImage imageWithData:fullScaleData] fileKey:image.fileKey];
}

- (VSTourImage*) fullScaleImageForFileKey:(NSNumber *)fileKey
{
    return [self fullScaleImageForThumbnail:[[VSTourImage alloc] initWithImage:nil fileKey:fileKey]];
}

- (NSArray<VSTourImage *> *)allThumbnails{
    
    return [self.tourMapData.availableImageIndexes map:^id(NSNumber* index) {
        NSData* thumbnailData = [self decodeObjectFromWrapperWithPreferredFilename:kThumbnailImageKeyForIndex(index)];
        UIImage* image = [UIImage imageWithData:thumbnailData];
        
        return [[VSTourImage alloc] initWithImage:image fileKey:index];
    }];
}

- (VSTourImage*)addImageWithImage:(UIImage *)image {
    NSNumber* index = [self.tourMapData registerNewImage:image];
    
    VSTourImage* tourImage = [[VSTourImage alloc] initWithImage:image fileKey:index];
    [self.imagesToSave addObject:tourImage];
    
    return tourImage;
}

- (void)deleteImage:(VSTourImage *)image {
    [self.tourMapData unregisterImageForFileKey:image.fileKey];
    [self.imagesToDelete addObject:image];
}

- (VSTourImage *)nextImageForTappingOnPoint:(CGPoint)point onImage:(VSTourImage *)tourImage {
    
    NSNumber* index = [self.tourMapData fileIndexForPoint:point
                                                  onIndex:tourImage.fileKey];
    
    if(!index)
        return nil;
    
    NSData* thumbnailData = [self decodeObjectFromWrapperWithPreferredFilename:kFullScaleImageKeyForIndex(index)];
    UIImage* image = [UIImage imageWithData:thumbnailData];
    
    return [[VSTourImage alloc] initWithImage:image fileKey:index];
}

- (NSArray<NSValue *> *)rectsForImage:(VSTourImage *)image
{
    return [self.tourMapData rectsForOriginIndex:image.fileKey];
}

- (void)addLinkWithRect:(CGRect)linkRect
              fromImage:(VSTourImage *)fromImage
                toImage:(VSTourImage *)toImage
{
    [self.tourMapData registerRect:linkRect originIndex:fromImage.fileKey destinationIndex:toImage.fileKey];
}

#pragma mark - saving data to disk

- (void)encodeObject:(id<NSCoding>)object
          toWrappers:(NSMutableDictionary *)wrappers
   preferredFilename:(NSString *)preferredFilename {
    @autoreleasepool {
        NSMutableData * data = [NSMutableData data];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:object forKey:@"data"];
        [archiver finishEncoding];
        NSFileWrapper * wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        [wrappers setObject:wrapper forKey:preferredFilename];
    }
}

- (id)decodeObjectFromWrapperWithPreferredFilename:(NSString *)preferredFilename {
    
    NSFileWrapper * fileWrapper = [self.fileWrapper.fileWrappers objectForKey:preferredFilename];
    if (!fileWrapper) {
        NSLog(@"Unexpected error: Couldn't find %@ in file wrapper!", preferredFilename);
        return nil;
    }
    
    NSData * data = [fileWrapper regularFileContents];
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    return [unarchiver decodeObjectForKey:@"data"];
    
}


- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    ///getting proper file wrapper
    NSMutableDictionary * wrappers =
    self.fileWrapper ?
    self.fileWrapper.fileWrappers.mutableCopy :
    [NSMutableDictionary dictionary];
    
    ////encoding data
    for(VSTourImage* image in self.imagesToSave)
    {
        NSData* fullImageData = UIImagePNGRepresentation(image.image);
        NSData* thumbnailImageData = UIImagePNGRepresentation([image.image proportionalResizeForSize:kThumbnailSize]);
        
        [self encodeObject:fullImageData
                toWrappers:wrappers
         preferredFilename:kFullScaleImageKeyForIndex(image.fileKey)];
        
        [self encodeObject:thumbnailImageData
                toWrappers:wrappers
         preferredFilename:kThumbnailImageKeyForIndex(image.fileKey)];
    }
    [self.imagesToSave removeAllObjects];
    
    for(VSTourImage* imageToDelete in self.imagesToDelete)
    {
        [wrappers removeObjectForKey:kThumbnailImageKeyForIndex(imageToDelete.fileKey)];
        [wrappers removeObjectForKey:kFullScaleImageKeyForIndex(imageToDelete.fileKey)];
    }
    [self.imagesToDelete removeAllObjects];
    
    [self encodeObject:self.tourMapData toWrappers:wrappers preferredFilename:kTourMapDataFilename];
    
    ///returning encoded data
    NSFileWrapper * fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    
    self.fileWrapper = fileWrapper;
    
    return fileWrapper;
}

- (BOOL) loadFromContents:(id)contents
                   ofType:(NSString *)typeName
                    error:(NSError * _Nullable __autoreleasing *)outError
{
    self.fileWrapper = contents;
    
    self.tourMapData = [self decodeObjectFromWrapperWithPreferredFilename:kTourMapDataFilename];
    
    return YES;
}

- (BOOL)hasUnsavedChanges {
    BOOL hasChanges = [super hasUnsavedChanges];
    
    BOOL hasUnsavedImages = self.imagesToDelete.count > 0 || self.imagesToSave.count > 0;
    
    return hasChanges || hasUnsavedImages;
}

@end
