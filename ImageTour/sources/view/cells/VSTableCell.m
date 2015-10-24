//
//  VSTableCell.m
//  ImageTour
//
//  Created by 286 on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSTableCell.h"

@interface VSTableCell ()

@property (weak, nonatomic) IBOutlet UILabel  *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@property (nonatomic, strong) VSDocument* doc;

@end

@implementation VSTableCell

+ (NSString *)reuseIdentifier{
    return @"com.vsDocumentCell";
}

- (IBAction)editDocumentAction:(id)sender {
    [self.delegate tableCell:self editDocument:self.doc];
}

- (IBAction)exportAction:(id)sender {
    [self.delegate tableCell:self exportDocument:self.doc];
}

- (CGRect)exportButtonFrame {
    return self.exportButton.frame;
}

- (void)setDocument:(VSDocument *)document{
    self.doc = document;
    self.titleLabel.text = document.fileURL.lastPathComponent;
}

- (void) startAnimatingProgress
{
    [self.activityIndicator startAnimating];
    self.widthConstraint.constant = 20.;
    [UIView animateWithDuration:0.5 animations:^{
        [self.contentView layoutIfNeeded];
        self.activityIndicator.alpha = 1.;
    }];
}

- (void) stopAnimationProgress
{
    self.widthConstraint.constant = 0.;
    [UIView animateWithDuration:0.5 animations:^{
        [self.contentView layoutIfNeeded];
        self.activityIndicator.alpha = 0.;
    } completion:^(BOOL finished) {
        [self.activityIndicator stopAnimating];
    }];
}

@end
