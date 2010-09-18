//
//  CLUploadViewController.m
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "CLUploadViewController.h"
#import "CLSettingsViewController.h"
#import "NPImageToolbar.h"
#import "NPImageNavigationBar.h"
#import "NPBlockBarButtonItem.h"
#import "NPBlockImagePickerController.h"
#import "NPBlockActionSheet.h"
#import "UIImage+NPResizing.h"
#import "NPHUDController.h"
#include <dispatch/dispatch.h>
#import "CLArrowView.h"
#import "CLAPIEngine.h"
#import "CLCredentialHandler.h"

@interface CLUploadViewController ()
- (void)_handleSelectedImage:(UIImage *)theImage;
- (NSString *)_fileNameForCurrentDate;
- (void)_reset;
@end

@implementation CLUploadViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_resizeImageQueue = dispatch_queue_create("com.linebreak.CloudApp.resizeImage", NULL);
		_addUploadQueue = dispatch_queue_create("com.linebreak.CloudApp.addUpload", NULL);
		[[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeKeyNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
			if (![[notification object] isEqual:self.view.window]) {
				[self.view.window makeKeyWindow];
			}
		}];
		
		engine = [[CLAPIEngine alloc] initWithDelegate:self];
		[engine setEmail:[CLCredentialHandler email]];
		[engine setPassword:[CLCredentialHandler password]];
		[[NSNotificationCenter defaultCenter] addObserverForName:CLCredentialChangedNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
			[engine setEmail:[CLCredentialHandler email]];
			[engine setPassword:[CLCredentialHandler password]];
		}];
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.frame = [[UIScreen mainScreen] applicationFrame];
	navBar.image = [UIImage imageNamed:@"BlueNavBarBG.png"];
	toolBar.image = [UIImage imageNamed:@"ToolbarGradient.png"];
	addUploadItem.block = ^(id sender) {
		NPBlockActionSheet *actionSheet = nil;
		NSString *pasteImageString = @"Paste Image";
		NSString *takePictureString = @"Take Picture";
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			actionSheet = [[[NPBlockActionSheet alloc] initWithTitle:@"" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:takePictureString, @"Select Existing Photo", pasteImageString, nil] autorelease];
		else
			actionSheet = [[[NPBlockActionSheet alloc] initWithTitle:@"" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select Existing Photo", pasteImageString, nil] autorelease];
		actionSheet.didDismissBlock = ^(NSInteger buttonIndex) {
			NSString *theTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
			if ([theTitle isEqualToString:pasteImageString]) {
				UIImage *theImage = [[UIPasteboard generalPasteboard] image];
				if (theImage == nil) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No image to paste." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
					[alertView show];
					[alertView autorelease];
				} else {
					[self _handleSelectedImage:theImage];
				}
			} else if (![theTitle isEqualToString:@"Cancel"]) {
				NPBlockImagePickerController *picker = [[[NPBlockImagePickerController alloc] initWithFinishBlock:^(NSDictionary *info) {
					[self _handleSelectedImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
					[self dismissModalViewControllerAnimated:YES];
				} cancelBlock:^ {
					[self dismissModalViewControllerAnimated:YES];
				}] autorelease];
				picker.allowsEditing = NO;
				picker.sourceType = [theTitle isEqualToString:takePictureString] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
				[self presentModalViewController:picker animated:YES];
			}
		};
		[actionSheet showFromToolbar:toolBar];
	};
	
	settingsItem.block = ^(id sender) {
		CLSettingsViewController *setVC = [[CLSettingsViewController alloc] initWithNibName:@"CLSettingsViewController" bundle:nil];
		[self presentModalViewController:setVC animated:YES];
		[setVC autorelease];
	};
	
	arrowView.block = ^{
		[UIView animateWithDuration:0.25 animations:^{
			arrowView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[arrowView stopAnimating];
			hudController = [[NPHUDController alloc] initWithBigSpinner];
			hudController.text = @"Uploading...";
			[hudController showWindow];
			dispatch_async(_addUploadQueue, ^{
				_isUploading = YES;
				_uploadIdentifier = [[engine doUpload:[CLFileUpload fileUploadWithName:[self _fileNameForCurrentDate] data:UIImagePNGRepresentation(_toUploadImage)]] retain];
			});
		}];
	};
}

- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	UIImageView *tempView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)] autorelease];
	tempView.image = [UIImage imageNamed:@"ErrorGlyph.png"];
	[hudController setCustomView:tempView animated:YES];
	hudController.text = [error localizedDescription];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2e9), dispatch_get_main_queue(), ^{
		[hudController close];
		[hudController release];
		hudController = nil;
		arrowView.alpha = 0.0;
		[arrowView startAnimating];
		[UIView animateWithDuration:0.35 animations:^{
			arrowView.alpha = 1.0;
		}];
	});
	[_uploadIdentifier release];
	_uploadIdentifier = nil;
}

- (void)uploadSucceeded:(CLUpload *)theUpload resultingItem:(CLWebItem *)theItem forRequest:(NSString *)connectionIdentifier {
	[UIPasteboard generalPasteboard].URL = theItem.URL;
	UIImageView *tempView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)] autorelease];
	tempView.image = [UIImage imageNamed:@"SuccessGlyph.png"];
	[hudController setCustomView:tempView animated:YES];
	hudController.text = @"Link copied!";
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2e9), dispatch_get_main_queue(), ^{
		[hudController close];
		[hudController release];
		hudController = nil;
		[self _reset];
	});
	[_uploadIdentifier release];
	_uploadIdentifier = nil;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canResignFirstResponder {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
	if (![CLCredentialHandler isComplete]) {
		CLSettingsViewController *setVC = [[[CLSettingsViewController alloc] initWithNibName:@"CLSettingsViewController" bundle:nil] autorelease];
		[self presentModalViewController:setVC animated:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[self resignFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (_isUploading) {
		[engine cancelConnection:_uploadIdentifier];
		[_uploadIdentifier release];
		_uploadIdentifier = nil;
		[hudController close];
		[hudController release];
		hudController = nil;
	}
	[self _reset];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

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

#pragma mark -
#pragma mark Private Methods

- (void)_reset {
	_isUploading = NO;
	[_toUploadImage release];
	_toUploadImage = nil;
	[UIView animateWithDuration:0.30 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
		topImageView.alpha = 0.0;
		checkeredImageView.alpha = 0.0;
		arrowView.alpha = 0.0;
	} completion:^(BOOL finished) {
		topImageView.image = nil;
		topImageView.alpha = 1.0;
		[arrowView stopAnimating];
	}];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2e8), dispatch_get_main_queue(), ^{
		navBar.barStyle = UIBarStyleBlackTranslucent;
		navBar.image = [UIImage imageNamed:@"BlueNavBarBG.png"];
	});
}

- (void)_handleSelectedImage:(UIImage *)theImage {
	if (theImage != _toUploadImage) {
		[theImage retain];
		[_toUploadImage release];
		_toUploadImage = theImage;
		[spinnerView setHidden:NO];
		[spinnerView startAnimating];
		topImageView.image = nil;
		arrowView.alpha = 0.0;
		[arrowView stopAnimating];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
		dispatch_async(_resizeImageQueue, ^{
			dispatch_sync(dispatch_get_main_queue(), ^{
				if (checkeredImageView.alpha != 1.0) {
					checkeredImageView.alpha = 0.0;
					[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
						checkeredImageView.alpha = 1.0;
					} completion:nil];
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1e8), dispatch_get_main_queue(), ^{
						navBar.barStyle = UIBarStyleBlackTranslucent;
						navBar.image = [UIImage imageNamed:@"NavBarTransparent.png"];
					});
				}
			});
			UIImage *toSetImage = [_toUploadImage imageByScalingAspectToFitToSize:CGSizeMake(topImageView.bounds.size.width * [[UIScreen mainScreen] scale], topImageView.bounds.size.height * [[UIScreen mainScreen] scale])];
			dispatch_sync(dispatch_get_main_queue(), ^{
				topImageView.alpha = 0.0;
				topImageView.image = toSetImage;
				[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
					topImageView.alpha = 1.0;
				} completion:^(BOOL finished) {
					[arrowView startAnimating];
					[UIView animateWithDuration:0.35 animations:^{
						arrowView.alpha = 1.0;
					}];
				}];
				[spinnerView stopAnimating];
				[spinnerView setHidden:YES];
			});
		});
		
	}
}

- (NSString *)_fileNameForCurrentDate {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter setDateFormat:nil];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSString *timeString = [dateFormatter stringFromDate:[NSDate date]];
	[dateFormatter release];
	NSString *retString = [NSString stringWithFormat:@"CloudApp iOS %@ at %@.png", dateString, timeString];
	retString = [retString stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
	retString = [retString stringByReplacingOccurrencesOfString:@":" withString:@"."];
	return retString;
}

- (void)dealloc {
	[_toUploadImage release];
	dispatch_release(_resizeImageQueue);
	dispatch_release(_addUploadQueue);
	[spinnerView release];
	[topImageView release];
	[checkeredImageView release];
	[settingsItem release];
	[addUploadItem release];
	[navBar release];
	[toolBar release];
    [super dealloc];
}


@end
