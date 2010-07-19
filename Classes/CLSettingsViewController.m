//
//  CLSettingsViewController.m
//  CloudApp
//
//  Created by Nick Paulson on 2/27/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "CLSettingsViewController.h"
#import "UINavigationBar+NPBackgroundImage.h"
#import "NPHUDView.h"
#import "CLPreferences.h"
#import "CLBigSpinnerView.h"
#import "CLAPIController.h"

@interface CLSettingsViewController ()
- (void)_savePressed:(id)sender;
- (BOOL)_allTextFieldsReady;
- (void)_receivedTextDidChangeNotification:(NSNotification *)theNotification;
- (void)_sendRequestToAPIController;
- (void)_dismissSelf;
- (void)_attemptLogin;
- (void)_fadeOutHUDViewAndDismiss:(NSNumber *)boolFlag;
@end

@implementation CLSettingsViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[[self view] setFrame:[[UIScreen mainScreen] applicationFrame]];
	[navBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground.png"]];
	
	UIImage *normalImage = [UIImage imageNamed:@"SaveButtonNormal.png"];
	_saveButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[_saveButton setBounds:CGRectMake(0, 0, [normalImage size].width, [normalImage size].height)];
	[_saveButton setImage:normalImage forState:UIControlStateNormal];
	[_saveButton setImage:[UIImage imageNamed:@"SaveButtonPressed.png"] forState:UIControlStateSelected];
	[_saveButton setImage:[UIImage imageNamed:@"SaveButtonDisabled.png"] forState:UIControlStateDisabled];
	[_saveButton addTarget:self action:@selector(_savePressed:) forControlEvents:UIControlEventTouchUpInside];
	[_saveButton setEnabled:[CLPreferences hasCheckedCredentials]];
	UIBarButtonItem *saveBarItem = [[UIBarButtonItem alloc] initWithCustomView:_saveButton];
	[[navBar topItem] setRightBarButtonItem:saveBarItem];
	[saveBarItem release];
	
	CGFloat xValue = 117;
	_userTextField = [[UITextField alloc] initWithFrame:CGRectMake(xValue, 12, [_loginTableView frame].size.width - 20 - xValue, [_loginTableView rowHeight] - 20)];
	[_userTextField setTextColor:[UIColor colorWithRed:0.1451 green:0.2902 blue:0.4941 alpha:1.0000]];
	[_userTextField setKeyboardType:UIKeyboardTypeEmailAddress];
	[_userTextField setClearsOnBeginEditing:NO];
	[_userTextField setEnablesReturnKeyAutomatically:YES];
	[_userTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_userTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_userTextField setReturnKeyType:UIReturnKeyNext];
	[_userTextField setDelegate:self];
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(xValue, 12, [_loginTableView frame].size.width - 20 - xValue, [_loginTableView rowHeight] - 20)];
	[_passwordTextField setTextColor:[UIColor colorWithRed:0.1451 green:0.2902 blue:0.4941 alpha:1.0000]];
	[_passwordTextField setKeyboardType:UIKeyboardTypeDefault];
	[_passwordTextField setSecureTextEntry:YES];
	[_passwordTextField setClearsOnBeginEditing:NO];
	[_passwordTextField setEnablesReturnKeyAutomatically:YES];
	[_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_passwordTextField setReturnKeyType:UIReturnKeyDone];
	[_passwordTextField setDelegate:self];
	
	if ([CLPreferences hasCheckedCredentials]) {
		[_userTextField setText:[CLPreferences user]];
		[_passwordTextField setText:[CLPreferences password]];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_userTextField];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:_passwordTextField];
	
	[_loginTableView setAllowsSelection:NO];
	[_loginTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
	[_userTextField becomeFirstResponder];
}

- (void)_savePressed:(id)sender {
	if (![CLPreferences hasCheckedCredentials]) {
		if ([self _allTextFieldsReady]) {
			if ([_userTextField isFirstResponder])
				[_userTextField resignFirstResponder];
			else if ([_passwordTextField isFirstResponder])
				[_passwordTextField resignFirstResponder];
			[self _attemptLogin];
		}
	} else {
		[[self parentViewController] dismissModalViewControllerAnimated:YES];
	}
}

- (BOOL)_allTextFieldsReady {
	return [[_userTextField text] length] > 0 && [[_passwordTextField text] length] > 0;
}

- (void)_attemptLogin {
	if (![self _allTextFieldsReady])
		return;
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:12];
	for (NSInteger i = 0; i < 12; i++) {
		[array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"SpinnerGlyph%i.png", i]]];
	}
	CGFloat sideSize = [[array objectAtIndex:0] size].width;
	UIImageView *theView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sideSize, sideSize)];
	[theView setAnimationImages:array];
	[theView setAnimationDuration:0.8];
	[theView startAnimating];
	_hudView = [[NPHUDView alloc] initWithContentView:theView text:@"Logging in..."];
	[theView release];
	[_hudView show];
	[[CLAPIController sharedController] setUser:[_userTextField text]];
	[[CLAPIController sharedController] setPassword:[_passwordTextField text]];
	[self performSelector:@selector(_sendRequestToAPIController) withObject:nil afterDelay:0.1];
}

- (void)_sendRequestToAPIController {
	[[CLAPIController sharedController] getUploadsWithDelegate:self downloadIcons:NO];
}

- (void)_fadeOutHUDViewAndDismiss:(NSNumber *)boolFlag {
	[_hudView dismiss];
	[_hudView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
	[_hudView autorelease];
	if ([boolFlag boolValue])
		[self performSelector:@selector(_dismissSelf) withObject:nil afterDelay:0.3];
	else
		[_userTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.3];
}

- (void)_dismissSelf {
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark API Controller Delegate Methods

- (void)uploadsRequest:(NSString *)requestIdentifier succeededWithResponseArray:(NSArray *)uploadsArray attemptedIconDownload:(BOOL)didAttempt allIconDownloadsSucceeded:(BOOL)iconSucceeded {
	[CLPreferences setHasCheckedCredentials:YES];
	[CLPreferences setUser:[_userTextField text]];
	[CLPreferences setPassword:[_passwordTextField text]];
	[_hudView setImage:[UIImage imageNamed:@"HUDSuccessGlyph.png"]];
	[_hudView setText:@"Login Success"];
	[self performSelector:@selector(_fadeOutHUDViewAndDismiss:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0];
}

- (void)uploadsRequest:(NSString *)requestIdentifier failedWithError:(NSError *)anError {
	[CLPreferences setUser:[[CLAPIController sharedController] user]];
	[CLPreferences resetUserAndPassword];
	[[CLAPIController sharedController] setUser:nil];
	[[CLAPIController sharedController] setPassword:nil];
	[CLPreferences setHasCheckedCredentials:NO];
	
	[_hudView setImage:[UIImage imageNamed:@"HUDFailedGlyph.png"]];
	NSString *errorString = [anError localizedFailureReason];
	if (errorString == nil || [errorString length] == 0)
		errorString = @"Login Failed";
	[_hudView setText:errorString];
	[self performSelector:@selector(_fadeOutHUDViewAndDismiss:) withObject:[NSNumber numberWithBool:NO] afterDelay:1.0];
}

#pragma mark Text Field Methods

- (void)_receivedTextDidChangeNotification:(NSNotification *)theNotification {
	[_saveButton setEnabled:[self _allTextFieldsReady]];
	if ([CLPreferences hasCheckedCredentials])
		[CLPreferences setHasCheckedCredentials:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _userTextField) {
		[_passwordTextField becomeFirstResponder];
	} else if (textField == _passwordTextField) {
		if ([self _allTextFieldsReady]) {
			[_passwordTextField resignFirstResponder];
			[self _attemptLogin];
			return YES;
		}
	}
	return NO;
}

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
			[cell addSubview:_userTextField];
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
	
	if ([_userTextField isFirstResponder])
		[_userTextField resignFirstResponder];
	else if ([_passwordTextField isFirstResponder])
		[_passwordTextField resignFirstResponder];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_userTextField];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_passwordTextField];
	[_userTextField release];
	[_passwordTextField release];
	[navBar release];
	[_loginTableView release];
	[_saveButton release];
    [super dealloc];
}


@end
