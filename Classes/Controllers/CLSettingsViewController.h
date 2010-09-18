//
//  CLSettingsViewController.h
//  CloudApp
//
//  Created by Nick Paulson on 7/25/10.
//  Copyright (c) 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLAPIEngineDelegate.h"

@class NPImageNavigationBar, CLAPIEngine, NPHUDController;

@interface CLSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLAPIEngineDelegate> {
	IBOutlet NPImageNavigationBar *navBar;
	UITextField *_emailTextField;
	UITextField *_passwordTextField;
	IBOutlet UITableView *loginTableView;
	UIButton *_saveButton;
	CLAPIEngine *engine;
	NPHUDController *hudController;
	UIResponder *_lastResponder;
	
	BOOL _hasChangedSinceLastCheck;
}

- (void)saveButtonPressed:(id)sender;


@end
