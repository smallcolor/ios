//
//  CLUploadViewController.m
//  CloudApp
//
//  Created by Nick Paulson on 3/9/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "CLUploadViewController.h"
#import "UINavigationBar+NPBackgroundImage.h"
#import "CLSettingsViewController.h"
#import "CLIlluminatedArrowView.h"
#import "UIImage+NPResizing.h"
#import "CLAPIController.h"
#import "CLBigSpinnerView.h"
#import "NPHUDView.h"
#import "CLPreferences.h"

NSString *CLUploadViewControllerTakePictureTitle = @"Take Picture";
NSString *CLUploadViewControllerSelectExistingTitle = @"Select Existing Photo";
NSString *CLUploadViewControllerPasteImageTitle = @"Paste Image";

@interface CLUploadViewController ()
- (void)_processImage:(UIImage *)theImage;
- (void)_setSelectedImage:(UIImage *)newImage;
- (UIImage *)_selectedImage;
- (void)_finishedProcessingImage;
- (void)_prepareUIAndStartImage:(UIImage *)theImage;
- (void)_removeArrowView;
- (void)_startUpload;
- (void)_sendDataToAPIController;
- (void)_fadeOutHUDViewAndRemove;
- (void)_resetToBeginning;
- (void)_fadeInGlyphView;
- (void)_addArrowViewIfNeededAndRestart;
- (void)_becameKeyNotification:(NSNotification *)theNote;
- (void)_makeNavBarBlue;
- (void)_cancelUploadWithID:(NSString *)connID;
@end

@implementation CLUploadViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _checkedBackgroundImage = [[UIImage imageNamed:@"CheckeredBackground.png"] retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_becameKeyNotification:) name:UIWindowDidBecomeKeyNotification object:nil];
	
	}
    return self;
}

- (void)_becameKeyNotification:(NSNotification *)theNote {
	if (_initialWindow == nil)
		_initialWindow = [theNote object];
	else if (![[theNote object] isEqual:_initialWindow]) {
		[_initialWindow makeKeyWindow];
		[self becomeFirstResponder];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self view] setFrame:[[UIScreen mainScreen] applicationFrame]];
	[navBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground.png"]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([CLPreferences hasCheckedCredentials]) {
		[self becomeFirstResponder];
		if ([self _selectedImage] != nil && [_arrowView superview] != nil)
			[self _addArrowViewIfNeededAndRestart];
	} else {
		CLSettingsViewController *viewCont = [[CLSettingsViewController alloc] init];
		[self presentModalViewController:viewCont animated:YES];
		[viewCont release];
	}
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)canResignFirstResponder {
	return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (event.type == UIEventSubtypeMotionShake) {
		if ([realImageView alpha] > 0.0) {
			NSLog(@"Got shake!");
			if (_connectionID != nil) {
				[self performSelector:@selector(_cancelUploadWithID:) withObject:[[_connectionID copy] autorelease] afterDelay:0.1];
				[self performSelector:@selector(_fadeOutHUDViewAndRemove) withObject:nil afterDelay:0.1];
				_connectionID = nil;
			}
			[self performSelector:@selector(_resetToBeginning) withObject:nil afterDelay:0.1];
		}
	}
}

- (void)_cancelUploadWithID:(NSString *)connID {
	[[CLAPIController sharedController] cancelConnectionWithIdentifier:connID];
}

- (void)_resetToBeginning {
	[self _setSelectedImage:nil];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25];
	[_arrowView setAlpha:0.0];
	[realImageView setAlpha:0.0];
	[UIView commitAnimations];
	[self performSelector:@selector(_fadeInGlyphView) withObject:nil afterDelay:0.25];
}

- (void)_fadeInGlyphView {
	placeholderImageView.image = [UIImage imageNamed:@"TexturedBackgroundWithGlyph.png"];
	UIImageView *tempView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	tempView.image = _checkedBackgroundImage;
	[self.view insertSubview:tempView aboveSubview:placeholderImageView];
	[tempView release];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	tempView.alpha = 0.0;
	[UIView commitAnimations];
	[self performSelector:@selector(_makeNavBarBlue) withObject:nil afterDelay:0.25];
	[tempView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)_makeNavBarBlue {
	[navBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground.png"]];
	navBar.barStyle = UIBarStyleDefault;
	navBar.translucent = NO;
}

- (IBAction)addUploadPressed:(id)sender {
	UIActionSheet *theSheet = nil;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		theSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:CLUploadViewControllerTakePictureTitle,  CLUploadViewControllerSelectExistingTitle, CLUploadViewControllerPasteImageTitle, nil];
	else
		theSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:CLUploadViewControllerSelectExistingTitle, CLUploadViewControllerPasteImageTitle, nil];
	[theSheet showFromToolbar:toolBar];
	[theSheet release];
}

- (IBAction)settingsPressed:(id)sender {
	[self resignFirstResponder];
	CLSettingsViewController *viewController = [[CLSettingsViewController alloc] init];
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}

#pragma mark Image Picker Controller Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"%@", info);
	[self _prepareUIAndStartImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Arrow View Delegate Methods

- (void)arrowViewDidComplete:(CLIlluminatedArrowView *)arrowView {
	if (_selectedImage == nil || ![[CLAPIController sharedController] isReady])
		return;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	[_arrowView setAlpha:0.0];
	[UIView commitAnimations];
	[self performSelector:@selector(_removeArrowView) withObject:nil afterDelay:0.3];
	[self _startUpload];
}

- (void)_startUpload {
	if (_selectedImage == nil || ![[CLAPIController sharedController] isReady])
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
	_hudView = [[NPHUDView alloc] initWithContentView:theView text:@"Uploading..."];
	[theView release];
	[_hudView show];
	[self performSelector:@selector(_sendDataToAPIController) withObject:nil afterDelay:0.1];
}

- (void)_sendDataToAPIController {
	NSString *formatString = NSLocalizedStringFromTable(@"%@ %@ at %@", @"ScreenCapture", @"Screenshot File Format");
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter setDateFormat:nil];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSString *timeString = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter release];
	NSString *finalString = [NSString stringWithFormat:formatString, NSLocalizedStringFromTable(@"Mobile Upload", @"ScreenCapture", @"Upload File Name Prefix"), dateString, timeString];
	finalString = [finalString stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
	finalString = [finalString stringByReplacingOccurrencesOfString:@"-" withString:NSLocalizedStringFromTable(@"-", @"ScreenCapture", @"Date Separator String")];
	finalString = [finalString stringByReplacingOccurrencesOfString:@":" withString:NSLocalizedStringFromTable(@".", @"ScreenCapture", @"Time Separator String")];
	finalString = [finalString stringByAppendingFormat:@".%@", @"png"];
	
	
	//Yes, I know this is not threadsafe.
	_connectionID = [[CLAPIController sharedController] uploadFileData:UIImagePNGRepresentation(_selectedImage) withFileName:finalString delegate:self];
}

- (void)createRequest:(NSString *)requestIdentifier succeededWithResponseItem:(CLUploadItem *)theItem {
	_connectionID = nil;
	[[UIPasteboard generalPasteboard] setURL:[theItem URL]];
	[_hudView setImage:[UIImage imageNamed:@"HUDSuccessGlyph.png"]];
	[_hudView setText:@"Link copied"];
	[self performSelector:@selector(_fadeOutHUDViewAndRemove) withObject:nil afterDelay:1.0];
	[self performSelector:@selector(_resetToBeginning) withObject:nil afterDelay:1.25];
	
}

- (void)createRequest:(NSString *)requestIdentifier failedWithError:(NSError *)anError {
	_connectionID = nil;
	[_hudView setImage:[UIImage imageNamed:@"HUDFailedGlyph.png"]];
	NSString *errorString = [anError localizedFailureReason];
	if (errorString == nil || [errorString length] == 0)
		errorString = @"Login Failed";
	[_hudView setText:errorString];
	[self performSelector:@selector(_fadeOutHUDViewAndRemove) withObject:nil afterDelay:1.0];
	[self performSelector:@selector(_addArrowViewIfNeededAndRestart) withObject:nil afterDelay:1.25];
}

- (void)_fadeOutHUDViewAndRemove {
	[_hudView dismiss];
	[_hudView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
	[_hudView autorelease];
}

- (void)_removeArrowView {
	if (_arrowView != nil && [_arrowView superview] != nil) {
		[_arrowView removeFromSuperview];
		[_arrowView release];
		_arrowView = nil;
	}
}

#pragma mark Private Methods

- (void)_processImage:(UIImage *)theImage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UIImage *retImage = [theImage imageByScalingAspectToFitToSize:realImageView.frame.size];
	[realImageView performSelectorOnMainThread:@selector(setImage:) withObject:retImage waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(_setSelectedImage:) withObject:theImage waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(_finishedProcessingImage) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void)_finishedProcessingImage {
	[spinnerView stopAnimating];
	[spinnerView setHidden:YES];
	[_tempDisableInteractionView removeFromSuperview];
	[_tempDisableInteractionView release];
	[self performSelector:@selector(_addArrowViewIfNeededAndRestart) withObject:nil afterDelay:0.25];
}

- (void)_addArrowViewIfNeededAndRestart {
	if (_arrowView == nil) {
		CGRect origRect = [[UIScreen mainScreen] applicationFrame];
		CGFloat toSubtract = toolBar.frame.size.height + navBar.frame.size.height;
		origRect.size.height -= toSubtract;
		origRect.origin.y = navBar.frame.size.height;
		_arrowView = [[CLIlluminatedArrowView alloc] initWithFrame:origRect];
		[_arrowView setDelegate:self];
		[_arrowView setAlpha:0.0];
		[self.view addSubview:_arrowView];
	}
	if ([_arrowView alpha] < 1.0) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.5];
		[_arrowView setAlpha:1.0];
		[UIView commitAnimations];
	}
	[_arrowView restartAnimation];
}

- (void)_setSelectedImage:(UIImage *)newImage {
	if (newImage != _selectedImage) {
		[newImage retain];
		[_selectedImage release];
		_selectedImage = newImage;
	}
}

- (UIImage *)_selectedImage {
	return [[_selectedImage retain] autorelease];
}

#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *clickedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([clickedButtonTitle isEqualToString:CLUploadViewControllerTakePictureTitle]) {
		[imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
		[self presentModalViewController:imagePickerController animated:YES];
	} else if ([clickedButtonTitle isEqualToString:CLUploadViewControllerSelectExistingTitle]) {
		[imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		[self presentModalViewController:imagePickerController animated:YES];
	} else if ([clickedButtonTitle isEqualToString:CLUploadViewControllerPasteImageTitle]) {
		UIPasteboard *genPB = [UIPasteboard generalPasteboard];
		if ([genPB containsPasteboardTypes:UIPasteboardTypeListImage]) {
			[self _prepareUIAndStartImage:[genPB image]];
		} else {
			UIAlertView *alView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No image to paste." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alView show];
			[alView autorelease];
		}
	}
}

- (void)_prepareUIAndStartImage:(UIImage *)theImage {
	if (_arrowView != nil && [_arrowView superview] != nil) {
		[_arrowView removeFromSuperview];
		[_arrowView release];
		_arrowView = nil;
	}
	
	[navBar setBackgroundImage:nil];
	navBar.barStyle = UIBarStyleBlackTranslucent;
	navBar.translucent = YES;
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	
	[spinnerView setHidden:NO];
	[spinnerView startAnimating];
	[realImageView setImage:nil];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[realImageView setAlpha:1.0];
	[UIView commitAnimations];
	
	[placeholderImageView setImage:_checkedBackgroundImage];
	_tempDisableInteractionView = [[UIView alloc] initWithFrame:[self.view bounds]];
	_tempDisableInteractionView.userInteractionEnabled = YES;
	[self.view addSubview:_tempDisableInteractionView];
	[self performSelectorInBackground:@selector(_processImage:) withObject:theImage];
}

- (void)didReceiveMemoryWarning {
	NSLog(@"Received Memory warning!");
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
	[navBar release];
	[placeholderImageView release];
	[realImageView release];
	[imagePickerController release];
	[toolBar release];
	[spinnerView release];
	[_checkedBackgroundImage release];
	[_arrowView release];
	[self _setSelectedImage:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
    [super dealloc];
}


@end
