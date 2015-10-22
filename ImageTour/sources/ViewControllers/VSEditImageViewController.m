//
//  VSEditImageViewController.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "VSEditImageViewController.h"
#import "VSTourImageSelectionViewController.h"

#import "UIViewController+Messages.h"

@interface VSEditImageViewController()

@property (weak, nonatomic) UIBarButtonItem* addRectItem;

@end

@implementation VSEditImageViewController

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"selectedRect"];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* addRectItem = [[UIBarButtonItem alloc] initWithTitle:@"Destination image" style:UIBarButtonItemStylePlain target:self action:@selector(addRect:)];
    self.addRectItem = addRectItem;
    addRectItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = addRectItem;
    
    [self addObserver:self forKeyPath:@"selectedRect" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if([keyPath isEqualToString:@"selectedRect"])
    {
        self.addRectItem.enabled = !CGRectEqualToRect(self.selectedRect, CGRectZero);
    }
}

- (void) addRect:(id)sender {
    if(self.callback)
    {
        VSTourImageSelectionViewController* controller = [[VSTourImageSelectionViewController alloc] initWithStyle:UITableViewStylePlain];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        controller.dataSource = self.selectionImages;
        
        __weak typeof(self) wSelf = self;
        controller.callback = ^(VSTourImage* image) {
            [wSelf dismissViewControllerAnimated:YES completion:^{
                [wSelf.navigationController popViewControllerAnimated:YES];
                wSelf.callback(wSelf.selectedRect, image);
            }];
        };
        
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navController animated:YES completion:nil];
    }
}


@end
