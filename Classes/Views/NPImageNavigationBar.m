//
//  NPImageNavigationBar.m
//  CloudApp
//
//  Created by Nick Paulson on 7/25/10.
//  Copyright (c) 2010 Linebreak. All rights reserved.
//

#import "NPImageNavigationBar.h"

@interface NPImageNavigationBar ()
- (void)_setupImageView;
@end

@implementation NPImageNavigationBar
@dynamic image;

- (id)initWithFrame:(CGRect)aFrame {
    if (self = [super initWithFrame:aFrame]) {
        [self _setupImageView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)theCoder {
	if (self = [super initWithCoder:theCoder]) {
		[self _setupImageView];
	}
	return self;
}

- (void)_setupImageView {
	_imageView = [[UIImageView alloc] initWithFrame:self.frame];
	_imageView.contentMode = UIViewContentModeScaleToFill;
	[self insertSubview:_imageView atIndex:0];
}

- (void)setImage:(UIImage *)newImage {
	_imageView.image = newImage;
}

- (void)drawRect:(CGRect)rect {
	return;
}

- (UIImage *)image {
	return _imageView.image;
}

- (void)dealloc {
	[_imageView release];
	[super dealloc];
}

@end
