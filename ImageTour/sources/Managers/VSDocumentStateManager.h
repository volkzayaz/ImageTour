//
//  VSDocumentStateManager.h
//  ImageTour
//
//  Created by 286 on 10/23/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSDocument.h"

typedef void(^VSDocumentStateCallback)(VSDocument* doc);

@interface VSDocumentStateManager : NSObject

+ (instancetype) sharedInstance;

- (VSDocument* /*nullable*/) currentlyOpenedDocument;

- (void) ensureOpenedDocument:(VSDocument*)document andDo:(VSDocumentStateCallback)block;
- (void) ensureClosedDocument:(VSDocument*)document andDo:(VSDocumentStateCallback)block;

- (void) explicitlySaveDocumentWithCallback:(VSDocumentStateCallback)block;
- (void) explicitlyCreateDocumetWithCallback:(VSDocumentStateCallback)block;

@end
