//
//  NPImageToolbar.m
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NPImageToolbar.h"

@implementation NPImageToolbar
@synthesize image;

- (void)drawRect:(CGRect)rect {
	[self.image drawInRect:self.bounds blendMode:kCGBlendModeCopy alpha:1.0];
}

- (void)setImage:(UIImage *)newImage {
	if (newImage != image) {
		[newImage retain];
		[image release];
		image = newImage;
		[self setNeedsDisplay];
	}
}

- (void)dealloc {
	self.image = nil;
	[super dealloc];
}

@end
