//
//  VSTableCell.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSDocument.h"

@protocol VSTableCellDelegate <NSObject>

- (void) startTourWithDocument:(VSDocument*)document;
- (void) editDocument:(VSDocument*)document;

@end

@interface VSTableCell : UITableViewCell

+ (NSString*) reuseIdentifier;
@property (nonatomic, weak) id<VSTableCellDelegate> delegate;

- (void) setDocument:(VSDocument*) document;

@end
