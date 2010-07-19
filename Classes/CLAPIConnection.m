//
//  CLAPIConnection.m
//  Cloud
//
//  Created by np101137 on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLAPIConnection.h"


@implementation CLAPIConnection
@synthesize statusCode, APIDelegate, requestType, identifier, downloadIcons, upload;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(CLAPIRequestType)reqType {
	return [self initWithRequest:request delegate:delegate requestType:reqType startImmediately:YES];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(CLAPIRequestType)reqType startImmediately:(BOOL)startImmediately {
	if (self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately]) {
		data = [[NSMutableData alloc] init];
		[self setRequestType:reqType];
		[self setStatusCode:-1];
		_internalDelegate = delegate;
	}
	return self;
}

- (void)cancel {
	[super cancel];
	if (_internalDelegate != nil && [_internalDelegate respondsToSelector:@selector(connectionWasCanceled:)])
		[_internalDelegate connectionWasCanceled:self];
}

- (NSMutableData *)data {
	return [[data retain] autorelease];
}

- (void)dealloc {
	[data release];
	[super dealloc];
}

@end