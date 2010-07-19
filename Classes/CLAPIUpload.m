//
//  CLAPIUpload.m
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLAPIUpload.h"

@implementation CLAPIUpload

- (NSURLRequest *)URLRequestForURL:(NSURL *)theURL {
	return nil;
}

- (BOOL)isValid {
	return YES;
}

- (NSUInteger)dataLength {
	return 0;
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] init];
}

@end
