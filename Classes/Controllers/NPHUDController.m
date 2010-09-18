//
//  NPHUDController.m
//  CloudApp
//
//  Created by Nick Paulson on 8/6/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NPHUDController.h"
#import "CLBigSpinnerView.h"
#include <dispatch/dispatch.h>

@implementation NPHUDController
@synthesize text, customView;

- (id)init {
	return [self initWithCustomView:nil];
}

- (id)initWithCustomView:(UIView *)theView {
	if (self = [super init]) {
		[[NSBundle mainBundle] loadNibNamed:@"NPHUDController" owner:self options:nil];
		self.customView = theView;
	}
	return self;
}

- (id)initWithBigSpinner {
	CLBigSpinnerView *bigSpinner = [[[CLBigSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)] autorelease];
	[bigSpinner startAnimating];
	return [self initWithCustomView:bigSpinner];
}

- (id)initWithImage:(UIImage *)theImage {
	UIImageView *tempView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 63, 63)] autorelease];
	tempView.image = theImage;
	tempView.contentMode = UIViewContentModeCenter;
	return [self initWithCustomView:tempView];
}

- (void)setCustomView:(UIView *)newView {
	[self setCustomView:newView animated:NO];
}

- (void)setCustomView:(UIView *)newView animated:(BOOL)animated {
	if (customView != newView) {
		[newView retain];
		UIView *oldView = [customView autorelease];
		customView = newView;
		if (customView != nil) {
			customView.frame = CGRectMake(49, 31, customView.frame.size.width, customView.frame.size.height);
			if (animated && _windowIsShowing) {
				customView.transform = CGAffineTransformMakeScale(1.5, 1.5);
				[UIView animateWithDuration:0.25 animations:^{
					customView.transform = CGAffineTransformIdentity;
				} completion:nil];
			}
			[hudView addSubview:customView];
			
		}
		if ([oldView superview] != nil)
			[oldView removeFromSuperview];
	}
}

- (void)setText:(NSString *)newText {
	[text autorelease];
	text = [newText copy];
	textLabel.text = text;
}

- (void)showWindow {
	if (!_windowIsShowing) {
		[self retain];
		_windowIsShowing = YES;
		hudWindow.windowLevel = UIWindowLevelStatusBar;
		hudView.frame = CGRectMake(80, 140, 160, 160);
		hudView.alpha = 1.0;
		[hudWindow addSubview:hudView];
		hudView.transform = CGAffineTransformMakeScale(1.3, 1.3);
		backgroundColorView.alpha = 0.0;
		[UIView animateWithDuration:0.15 animations:^{
			hudView.transform = CGAffineTransformMakeScale(0.9, 0.9);
			backgroundColorView.alpha = 1.0;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.125 animations:^{
				hudView.transform = CGAffineTransformIdentity;
			} completion:nil];
		}];
		[hudWindow makeKeyAndVisible];
	}
}

- (void)close {
	_windowIsShowing = NO;
	[UIView animateWithDuration:0.125 animations:^{
		hudView.transform = CGAffineTransformMakeScale(1.1, 1.1);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.15 animations:^{
			hudView.transform = CGAffineTransformMakeScale(0.4, 0.4);
			hudView.alpha = 0.0;
			backgroundColorView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[hudWindow resignKeyWindow];
			[self release];
		}];
	}];
}

- (void)dealloc {
	self.text = nil;
	self.customView = nil;
	[textLabel release];
	[hudView release];
	[hudWindow release];
    [super dealloc];
}


@end
