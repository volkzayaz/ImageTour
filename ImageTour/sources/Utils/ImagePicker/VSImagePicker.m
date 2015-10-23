//
//  VSImagePickerControllerViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSImagePicker.h"

@interface VSImagePicker ()
<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (nonatomic, weak) UIViewController* presentingViewController;

@end

@implementation VSImagePicker

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingViewController
{
    self = [super init];
    
    if(self){
        self.presentingViewController = presentingViewController;
    }
    
    return self;
}

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = NO;
    }
    return _imagePicker;
}

- (void)pickAnImage{
    
    UIAlertController* imagePickerAlertController = [UIAlertController alertControllerWithTitle:@"Image Picker"
                                                                                        message:self.descriptionString
                                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof (self.imagePicker) weakImagePicker = self.imagePicker;
    __weak typeof (self.presentingViewController) weakPresenter = self.presentingViewController;
    
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
    {
        [imagePickerAlertController addAction:[UIAlertAction actionWithTitle:@"Camera"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                                         weakImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                         weakImagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                                                                         [weakImagePicker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
                                                                         [weakPresenter presentViewController:weakImagePicker animated:YES completion:nil];
        }]];
    }

    [imagePickerAlertController addAction:[UIAlertAction actionWithTitle:@"Photo Library"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     weakImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                     [weakPresenter presentViewController:weakImagePicker animated:YES completion:nil];
    }]];
    
    [imagePickerAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleDestructive
                                                                 handler:nil]];
    
    imagePickerAlertController.popoverPresentationController.sourceView = self.presentingViewController.view;
    imagePickerAlertController.popoverPresentationController.sourceRect = self.presentingViewController.view.bounds;
    
    [self.presentingViewController presentViewController:imagePickerAlertController
                                                animated:YES
                                              completion:nil];
}

#pragma mark - imagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if(self.delegate)
    {
        UIImage* editedImage   = (UIImage *) info[UIImagePickerControllerEditedImage];
        UIImage* originalImage = (UIImage *) info[UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            [self.delegate imagePickerDidPickImage:editedImage];
        } else if (originalImage) {
            [self.delegate imagePickerDidPickImage:originalImage];
        }
    }
    
    
    self.imagePicker = nil;
}

@end
