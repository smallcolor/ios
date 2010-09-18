//
//  CLSettingsViewController.m
//  CloudApp
//
//  Created by Nick Paulson on 7/25/10.
//  Copyright (c) 2010 Linebreak. All rights reserved.
//

#import "CLSettingsViewController.h"
#import "NPImageNavigationBar.h"
#import "CLAPIEngine.h"
#import "NPHUDController.h"
#import "CLCredentialHandler.h"

@interface CLSettingsViewController ()
- (BOOL)_allTextFieldsReady;
- (void)_receivedTextDidChangeNotification:(NSNotification *)theNotification;
@end

@implementation CLSettingsViewController

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        engine = [[CLAPIEngine alloc] initWithDelegate:self];
		[engine setClearsCookies:YES];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.frame = [[UIScreen mainScreen] applicationFrame];
	[navBar setImage:[UIImage imageNamed:@"BlueNavBarBG.png"]];
	
	_saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_saveButton setBackgroundImage:[UIImage imageNamed:@"BlueBarItemNormal.png"] forState:UIControlStateNormal];
	[_saveButton setBackgroundImage:[UIImage imageNamed:@"BlueBarItemDisabled.png"] forState:UIControlStateDisabled];
	[_saveButton setBackgroundImage:[UIImage imageNamed:@"BlueBarItemHighlighted.png"] forState:UIControlStateHighlighted];
	[_saveButton setBounds:CGRectMake(0, 0, 49, 30)];
	[_saveButton setTitle:@"Save" forState:UIControlStateNormal];
	_saveButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
	_saveButton.titleLabel.shadowColor = [UIColor blackColor];
	_saveButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
	[_saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:_saveButton];
	[[navBar topItem] setRightBarButtonItem:barItem];
	
	CGFloat xValue = 117;
	_emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(xValue, 12, [loginTableView frame].size.width - 20 - xValue, [loginTableView rowHeight] - 20)];
	[_emailTextField setTextColor:[UIColor colorWithRed:0.1451 green:0.2902 blue:0.4941 alpha:1.0000]];
	[_emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
	[_emailTextField setClearsOnBeginEditing:NO];
	[_emailTextField setEnablesReturnKeyAutomatically:YES];
	[_emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emailTextField setReturnKeyType:UIReturnKeyNext];
	[_emailTextField setDelegate:self];
	
	_emailTextField.text = [CLCredentialHandler email];
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(xValue, 12, [loginTableView frame].size.width - 20 - xValue, [loginTableView rowHeight] - 20)];
	[_passwordTextField setTextColor:[UIColor colorWithRed:0.1451 green:0.2902 blue:0.4941 alpha:1.0000]];
	[_passwordTextField setKeyboardType:UIKeyboardTypeDefault];
	[_passwordTextField setSecureTextEntry:YES];
	[_passwordTextField setClearsOnBeginEditing:NO];
	[_passwordTextField setEnablesReturnKeyAutomatically:YES];
	[_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_passwordTextField setReturnKeyType:UIReturnKeyDone];
	[_passwordTextField setDelegate:self];
	
	_passwordTextField.text = [CLCredentialHandler password];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_emailTextField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_passwordTextField];
	
	[loginTableView setAllowsSelection:NO];
	[loginTableView setBackgroundColor:[UIColor clearColor]];
	
	BOOL allReady = [self _allTextFieldsReady];
	_saveButton.enabled = allReady;
	_saveButton.titleLabel.alpha = allReady ? 1.0 : 0.6;
}

- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[_emailTextField becomeFirstResponder];
}

- (void)saveButtonPressed:(id)sender {
	if (!_hasChangedSinceLastCheck) {
		[self.parentViewController dismissModalViewControllerAnimated:YES];
		return;
	}
	if ([self _allTextFieldsReady]) {
		if ([_emailTextField isFirstResponder]) {
			_lastResponder = _emailTextField;
			[_emailTextField resignFirstResponder];
		} else if ([_passwordTextField isFirstResponder]) {
			_lastResponder = _passwordTextField;
			[_passwordTextField resignFirstResponder];
		}
		hudController = [[[NPHUDController alloc] initWithBigSpinner] autorelease];
		hudController.text = @"Logging in...";
		[hudController showWindow];
		[engine setEmail:_emailTextField.text];
		[engine setPassword:_passwordTextField.text];
		[engine getRecentItemsStartingAtPage:1 count:1];
		_saveButton.enabled = NO;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _emailTextField) {
		[_passwordTextField becomeFirstResponder];
	} else if (textField == _passwordTextField) {
		if ([self _allTextFieldsReady]) {
			[self saveButtonPressed:_saveButton];
			return YES;
		}
	}
	return NO;
}

- (void)recentItemsReceived:(NSArray *)recentItems forRequest:(NSString *)connectionIdentifier {
	UIImageView *tempView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)] autorelease];
	tempView.image = [UIImage imageNamed:@"SuccessGlyph.png"];
	[hudController setCustomView:tempView animated:YES];
	hudController.text = @"Login Success";
	[CLCredentialHandler setEmail:_emailTextField.text];
	[CLCredentialHandler setPassword:_passwordTextField.text];
	[[NSNotificationCenter defaultCenter] postNotificationName:CLCredentialChangedNotification object:self];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5e9), dispatch_get_main_queue(), ^{
		[hudController close];
		_hasChangedSinceLastCheck = NO;
		[self.parentViewController dismissModalViewControllerAnimated:YES];
	});
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	[CLCredentialHandler clearCredentials];
	[[NSNotificationCenter defaultCenter] postNotificationName:CLCredentialChangedNotification object:self];
	UIImageView *tempView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)] autorelease];
	tempView.image = [UIImage imageNamed:@"ErrorGlyph.png"];
	[hudController setCustomView:tempView animated:YES];
	hudController.text = [error localizedDescription];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2e9), dispatch_get_main_queue(), ^{
		[hudController close];
		[_lastResponder becomeFirstResponder];
		_lastResponder = nil;
		_saveButton.enabled = [self _allTextFieldsReady];
	});
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)_allTextFieldsReady {
	return [[_emailTextField text] length] > 0 && [[_passwordTextField text] length] > 0;
}

- (void)_receivedTextDidChangeNotification:(NSNotification *)theNotification {
	BOOL allReady = [self _allTextFieldsReady];
	_saveButton.enabled = allReady;
	_saveButton.titleLabel.alpha = allReady ? 1.0 : 0.6;
	_hasChangedSinceLastCheck = YES;
}

#pragma mark -
#pragma mark Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"LoginTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		if ([indexPath row] == 0)
			[cell addSubview:_emailTextField];
		else
			[cell addSubview:_passwordTextField];
	}
	
	if ([indexPath row] == 0)
		cell.textLabel.text = @"Email";
	else
		cell.textLabel.text = @"Password";
	
    return cell;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if ([_emailTextField isFirstResponder])
		[_emailTextField resignFirstResponder];
	else if ([_passwordTextField isFirstResponder])
		[_passwordTextField resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_emailTextField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_passwordTextField];
	[_emailTextField release];
	[_passwordTextField release];
	[engine release];
	[navBar release];
    [super dealloc];
}


@end
