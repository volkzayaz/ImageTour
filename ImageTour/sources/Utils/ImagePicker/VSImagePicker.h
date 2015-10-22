//
//  VSImagePickerControllerViewController.h
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSImagePickerDelegate <NSObject>

- (void) imagePickerDidPickImage: (UIImage*) image;

@end

@interface VSImagePicker : NSObject

- (instancetype) initWithPresentingViewController:(UIViewController*) presentingViewController;

//will be used into action sheet
@property (nonatomic, strong) NSString* descriptionString;

@property (nonatomic, weak) id<VSImagePickerDelegate> delegate;

- (void) pickAnImage;

@end
