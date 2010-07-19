//
//  UINavigationBar+NPBackgroundImage.m
//  CloudApp
//
//  Created by Nick Paulson on 2/27/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "UINavigationBar+NPBackgroundImage.h"

NSInteger NPBackgroundUIImageViewTag = 361;

@implementation UINavigationBar (NPBackgroundImage)

- (void)setBackgroundImage:(UIImage *)anImage {
	[self setBackgroundImage:anImage animated:NO];
}

- (void)setBackgroundImage:(UIImage *)anImage animated:(BOOL)flag {
	UIImageView *theImageView = (UIImageView *)[self viewWithTag:NPBackgroundUIImageViewTag];
	UIImage *oldImage = nil;
	if (theImageView == nil) {
		theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height)];
		[theImageView setTag:NPBackgroundUIImageViewTag];
		[self insertSubview:theImageView atIndex:0];
	}
	oldImage = [theImageView image];
	[theImageView setImage:anImage];
	/*if (flag) {
		if (self.barStyle == UIBarStyleDefault) {
			UIImageView *tempView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height)];
			[tempView setImage:oldImage];
			[self insertSubview:tempView atIndex:0];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:1.0];
			[tempView setAlpha:0.0];
			[UIView commitAnimations];
			[tempView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
			[tempView release];
		} else {
			[theImageView setAlpha:0.0];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:1.0];
			[theImageView setAlpha:1.0];
			[UIView commitAnimations];
		}
	}*/
}

@end
