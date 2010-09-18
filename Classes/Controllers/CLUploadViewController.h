//
//  CLUploadViewController.h
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLAPIEngineDelegate.h"

@class NPImageNavigationBar, NPImageToolbar, NPBlockBarButtonItem, CLArrowView, CLAPIEngine, NPHUDController;
@interface CLUploadViewController : UIViewController<CLAPIEngineDelegate> {
	IBOutlet NPImageNavigationBar *navBar;
	IBOutlet NPImageToolbar *toolBar;
	
	IBOutlet NPBlockBarButtonItem *addUploadItem;
	IBOutlet NPBlockBarButtonItem *settingsItem;
	
	IBOutlet UIImageView *topImageView;
	IBOutlet UIImageView *checkeredImageView;
	
	IBOutlet UIActivityIndicatorView *spinnerView;
	
	IBOutlet CLArrowView *arrowView;
	NPHUDController *hudController;
	
	UIImage *_toUploadImage;
	
	dispatch_queue_t _resizeImageQueue;
	dispatch_queue_t _addUploadQueue;
	
	CLAPIEngine *engine;
	
	BOOL _isUploading;
	NSString *_uploadIdentifier;
}

@end
