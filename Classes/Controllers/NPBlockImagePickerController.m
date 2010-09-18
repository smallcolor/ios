//
//  NPBlockImagePickerController.m
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NPBlockImagePickerController.h"


@implementation NPBlockImagePickerController
@synthesize finishBlock, cancelBlock;

- (id)init {
	return [self initWithFinishBlock:nil cancelBlock:nil];
}

- (id)initWithFinishBlock:(void (^)(NSDictionary *info))theFinishBlock cancelBlock:(void (^)(void))theCancelBlock {
	if (self = [super init]) {
		self.delegate = self;
		self.finishBlock = theFinishBlock;
		self.cancelBlock = theCancelBlock;
	}
	return self;
}

- (void)setDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)newDelegate {
	[super setDelegate:self];
}

- (id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate {
	return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if (self == picker && self.finishBlock != nil) {
		self.finishBlock(info);
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if (self == picker && self.cancelBlock != nil) {
		self.cancelBlock();
	}
}

- (void)dealloc {
	self.finishBlock = nil;
	self.cancelBlock = nil;
	[super dealloc];
}

@end
