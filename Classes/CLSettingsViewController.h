//
//  CLSettingsViewController.h
//  CloudApp
//
//  Created by Nick Paulson on 2/27/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLLoginTableViewController, NPHUDView;

@interface CLSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	IBOutlet UINavigationBar *navBar;
	UIButton *_saveButton;
	IBOutlet UITableView *_loginTableView;
	UITextField *_userTextField;
	UITextField *_passwordTextField;
	NPHUDView *_hudView;
}

@end
