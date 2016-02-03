//
//  VSDocument+URLManagement.m
//  ImageTour
//
//  Created by 286 on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocument+URLManagement.h"

#define FILE_NAME_SEPARATOR @"_"
#define TEMP_FILE_NAME @"export"

@implementation VSDocument (URLManagement)

+ (NSURL *)localRoot {
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask];

    return [paths objectAtIndex:0];
}

+ (NSString*) documentFileNameForIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%li%@ImageTour.%@",(long)index,FILE_NAME_SEPARATOR,VS_EXTENSION];
}

+ (NSURL *)docURLForFileName:(NSString *)filename {
    return [self.localRoot URLByAppendingPathComponent:filename];
}

#pragma mark - interface implementation

+ (NSURL*) newUniqueUrlForDocument {
    NSArray<NSString*>* documentsLastPaths = [[
                                               [self localImageTourDocuments] valueForKeyPath:@"fileURL.lastPathComponent"] sortedArrayUsingComparator:
                                              ^NSComparisonResult(NSString*  _Nonnull obj1,
                                                                  NSString* _Nonnull obj2) {
        return [@([obj1 intValue]) compare:@([obj2 intValue])];
    }];
    
    NSString* biggestIndexName = documentsLastPaths.lastObject;
    NSInteger newDocumentIndex =
    biggestIndexName ?
    [biggestIndexName componentsSeparatedByString:FILE_NAME_SEPARATOR].firstObject.integerValue + 1
    : 0;
    
    return [self docURLForFileName:[self documentFileNameForIndex:newDocumentIndex]];
}

+ (NSURL *)urlForTemporaryDocument
{
    return [[self.localRoot URLByAppendingPathComponent:TEMP_FILE_NAME] URLByAppendingPathExtension:VS_EXTENSION];
}

+ (NSURL*)urlForExampleDocument
{
    return [[self.localRoot URLByAppendingPathComponent:@"0_Example"] URLByAppendingPathExtension:VS_EXTENSION];
}

+ (NSArray<VSDocument*>*)localImageTourDocuments {
    
    NSArray * localDocumentsURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot
                                                             includingPropertiesForKeys:nil
                                                                                options:0
                                                                                  error:nil];
    
    NSString* tempFileLastComponent = [NSString stringWithFormat:@"%@.%@",TEMP_FILE_NAME, VS_EXTENSION];
    NSIndexSet* vsDocsIndexes = [localDocumentsURLs indexesOfObjectsPassingTest:^BOOL(NSURL * fileURL,
                                                                                      NSUInteger idx,
                                                                                      BOOL * _Nonnull stop) {
         return [[fileURL pathExtension]     isEqualToString:VS_EXTENSION] &
               ![[fileURL lastPathComponent] isEqualToString:tempFileLastComponent];
    }];
    
    NSMutableArray* answer = [NSMutableArray array];
    
    for(NSURL* url in [localDocumentsURLs objectsAtIndexes:vsDocsIndexes])
    {
        [answer addObject:[[VSDocument alloc] initWithFileURL:url]];
    }
    
    return answer.copy;
}

+ (BOOL)validateURL:(NSURL *)tourImageDocumentURL
{
    return tourImageDocumentURL != nil &&
    [tourImageDocumentURL.lastPathComponent.pathExtension isEqualToString:VS_EXTENSION];
}

@end
