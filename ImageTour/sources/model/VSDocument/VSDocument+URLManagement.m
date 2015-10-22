//
//  VSDocument+URLManagement.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/20/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocument+URLManagement.h"

#define FILE_NAME_SEPARATOR @"_"

@implementation VSDocument (URLManagement)

+ (NSURL *)localRoot {
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask];

    return [paths objectAtIndex:0];
}

+ (NSString*) documentFileNameForIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%li%@ImageTour.%@",index,FILE_NAME_SEPARATOR,VS_EXTENSION];
}

+ (NSURL *)docURLForFileName:(NSString *)filename {
    return [self.localRoot URLByAppendingPathComponent:filename];
}

+ (NSURL*) newUniqueUrlForDocument {
    NSArray<NSString*>* documentsLastPaths = [[
                                               [self localImageTourDocuments] valueForKeyPath:@"fileURL.lastPathComponent"] sortedArrayUsingComparator:
                                              ^NSComparisonResult(NSString*  _Nonnull obj1,
                                                                  NSString* _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSString* biggestIndexName = documentsLastPaths.lastObject;
    NSInteger newDocumentIndex =
    biggestIndexName ?
    [biggestIndexName componentsSeparatedByString:FILE_NAME_SEPARATOR].firstObject.integerValue + 1
    : 0;
    
    return [self docURLForFileName:[self documentFileNameForIndex:newDocumentIndex]];
}

+ (NSArray<VSDocument*>*)localImageTourDocuments {
    
    NSArray * localDocumentsURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot
                                                             includingPropertiesForKeys:nil
                                                                                options:0
                                                                                  error:nil];
    
    NSIndexSet* vsDocsIndexes = [localDocumentsURLs indexesOfObjectsPassingTest:^BOOL(NSURL * fileURL,
                                                                                      NSUInteger idx,
                                                                                      BOOL * _Nonnull stop) {
        return [[fileURL pathExtension] isEqualToString:VS_EXTENSION];
    }];
    
    NSMutableArray* answer = [NSMutableArray array];
    
    for(NSURL* url in [localDocumentsURLs objectsAtIndexes:vsDocsIndexes])
    {
        [answer addObject:[[VSDocument alloc] initWithFileURL:url]];
    }
    
    return answer.copy;
}

@end
