//
//  VSTableCell.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSTableCell.h"

@interface VSTableCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (nonatomic, strong) VSDocument* doc;

@end

@implementation VSTableCell

+ (NSString *)reuseIdentifier{
    return @"com.vsDocumentCell";
}

- (IBAction)startTourAction:(id)sender {
    [self.delegate startTourWithDocument:self.doc];
}

- (IBAction)editDocumentAction:(id)sender {
    [self.delegate editDocument:self.doc];
}

- (void)setDocument:(VSDocument *)document{
    self.doc = document;
    self.titleLabel.text = document.fileURL.lastPathComponent;
//    [document openWithCompletionHandler:^(BOOL success) {
//        
//        self.titleLabel.text = document.tourName;
//        
//        
//    }];
}

@end
