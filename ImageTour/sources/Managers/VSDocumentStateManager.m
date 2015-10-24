//
//  VSDocumentStateManager.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/23/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSDocumentStateManager.h"

#import "VSDocument+URLManagement.h"

@interface VSDocumentStateManager()

@property (nonatomic, strong) VSDocument* openedDocument;

@end

@implementation VSDocumentStateManager

@synthesize openedDocument = _openedDocument;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static VSDocumentStateManager* sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[VSDocumentStateManager alloc] init];
    });
    
    return sharedManager;
}

- (void)ensureOpenedDocument:(VSDocument *)document andDo:(VSDocumentStateCallback)block
{
    [self setOpenedDocument:document withCompletition:^{
        block(document);
    }];
}

- (void)ensureClosedDocument:(VSDocument *)document andDo:(VSDocumentStateCallback)block
{
    [self safeCloseDocument:document block:^{
        block(document);
    }];
}

- (VSDocument *)currentlyOpenedDocument
{
    return self.openedDocument;
}

- (void)explicitlySaveDocumentWithCallback:(VSDocumentStateCallback)block
{
    if(!self.openedDocument)
        return block(nil);
    
    [self.openedDocument saveToURL:self.openedDocument.fileURL
                  forSaveOperation:UIDocumentSaveForOverwriting
                 completionHandler:^(BOOL success) {
                     block(self.openedDocument);
                 }];
}

- (void)explicitlyCreateDocumetWithCallback:(VSDocumentStateCallback)block
{
    NSURL *documentURL = VSDocument.newUniqueUrlForDocument;
    VSDocument* newDocument = [VSDocument createNewLocalDocumentInURL:documentURL];
    
    [newDocument saveToURL:documentURL
                  forSaveOperation:UIDocumentSaveForCreating
                 completionHandler:^(BOOL success) {
                     self.openedDocument = newDocument;
                     block(self.openedDocument);
                 }];
}

- (VSDocument *)openedDocument
{
    if(_openedDocument.documentState != UIDocumentStateNormal)
    {
        return nil;
    }
    
    return _openedDocument;
}

- (void) setOpenedDocument:(VSDocument *)openedDocument withCompletition:(void(^)())block{
    
    if(openedDocument == _openedDocument)
        return block();
    
    
    __weak typeof (self) wSelf = self;
    [self safeCloseDocument:_openedDocument
                      block:^{
        _openedDocument = openedDocument;
        [wSelf safeOpenDocument:_openedDocument
                          block:block];
    }];
    
}

#pragma mark - opening/closing of UIDocument

- (void) safeCloseDocument:(VSDocument*) doc block:(void(^)())block
{
    if(doc == nil)
        return block();
    
    if(doc.documentState != UIDocumentStateClosed)
    {
        [doc closeWithCompletionHandler:^(BOOL success) {
            if(success)
            {
                block();
            }
        }];
    }
    else
    {
        block();
    }
    
}

- (void) safeOpenDocument:(VSDocument*) doc block:(void(^)())block
{
    if(doc == nil)
        return block();
    
    if (doc.documentState != UIDocumentStateNormal)
    {
        [doc openWithCompletionHandler:^(BOOL success) {
            if(success)
            {
                block();
            }
        }];
    }
    else
    {
        block();
    }
}

@end
