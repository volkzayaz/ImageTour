//
//  VSImagePickerControllerViewController.h
//  ImageTour
//
//  Created by 286 on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSImagePickerDelegate <NSObject>

- (void) imagePickerDidPickImage: (UIImage*) image;

@end

@interface VSImagePicker : NSObject

- (instancetype) initWithPresentingViewController:(UIViewController*) presentingViewController;

@property (nonatomic, weak) id<VSImagePickerDelegate> delegate;
@property (nonatomic, strong) NSString* descriptionString;

- (void) pickAnImage;

@end
