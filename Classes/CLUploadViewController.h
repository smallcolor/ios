//
//  CLUploadViewController.h
//  CloudApp
//
//  Created by Nick Paulson on 3/9/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLIlluminatedArrowView.h"

@class NPHUDView;

@interface CLUploadViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, CLIlluminatedArrowViewDelegate> {
	IBOutlet UINavigationBar *navBar;
	IBOutlet UIImageView *placeholderImageView;
	IBOutlet UIImageView *realImageView;
	IBOutlet UIImagePickerController *imagePickerController;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIActivityIndicatorView *spinnerView;
	UIImage *_selectedImage;
	UIImage *_checkedBackgroundImage;
	UIView *_tempDisableInteractionView;
	CLIlluminatedArrowView *_arrowView;
	NPHUDView *_hudView;
	NSString *_connectionID;
	UIWindow *_initialWindow;
}

- (IBAction)addUploadPressed:(id)sender;
- (IBAction)settingsPressed:(id)sender;

@end
