//
//  NPBlockBarButtonItem.m
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NPBlockBarButtonItem.h"

@interface NPBlockBarButtonItem ()
- (void)_npButtonBlockAction:(id)sender;
@end

@implementation NPBlockBarButtonItem
@synthesize block;

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
	if (self = [super initWithBarButtonSystemItem:systemItem target:self action:@selector(_npButtonBlockAction:)]) {
		
	}
	return self;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
	if (self = [super initWithImage:image style:style target:self action:@selector(_npButtonBlockAction:)]) {
		
	}
	return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
	if (self = [super initWithTitle:title style:style target:self action:@selector(_npButtonBlockAction:)]) {
		
	}
	return self;
}

- (void)setTarget:(id)newTarget {
	[super setTarget:self];
}

- (id)target {
	return self;
}

- (void)setAction:(SEL)newAction {
	[super setAction:@selector(_npButtonBlockAction:)];
}

- (SEL)action {
	return @selector(_npButtonBlockAction:);
}

- (void)_npButtonBlockAction:(id)sender {
	if (self.block != nil)
		self.block(sender);
}

- (void)dealloc {
	self.block = nil;
	[super dealloc];
}

@end
