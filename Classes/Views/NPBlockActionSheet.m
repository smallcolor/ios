//
//  NPBlockActionSheet.m
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NPBlockActionSheet.h"


@implementation NPBlockActionSheet
@synthesize didDismissBlock;

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (self == actionSheet && self.didDismissBlock != nil)
		self.didDismissBlock(buttonIndex);
}

- (void)setDelegate:(id<UIActionSheetDelegate>)newDelegate {
	[super setDelegate:self];
}

- (id<UIActionSheetDelegate>)delegate {
	return self;
}

- (void)dealloc {
	self.didDismissBlock = nil;
	[super dealloc];
}

@end
