//
//  CLAPIRedirectUpload.m
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLAPIRedirectUpload.h"
#import "NSMutableURLRequest+NPPostBody.h"
#import "CLAPIController.h"

@implementation CLAPIRedirectUpload
@synthesize URL, name;

+ (CLAPIRedirectUpload *)redirectUploadWithURL:(NSURL *)theURL name:(NSString *)theName {
	return [[[[self class] alloc] initWithURL:theURL name:theName] autorelease];
}

- (id)initWithURL:(NSURL *)theURL name:(NSString *)theName {
	if (self = [super init]) {
		[self setURL:theURL];
		[self setName:theName];
	}
	return self;
}

- (NSURLRequest *)URLRequestForURL:(NSURL *)theURL {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
	[request setHTTPMethod:@"POST"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; boundary=%@", CLAPIRequestBoundary] forHTTPHeaderField:@"Content-Type"];
	[request addToPOSTBodyString:[[self URL] absoluteString] forKey:@"item[redirect_url]" boundary:CLAPIRequestBoundary];
	[request addToPOSTBodyString:[self name] forKey:@"item[name]" boundary:CLAPIRequestBoundary];
	return request;
}

- (BOOL)isValid {
	NSURL *theURL = [self URL];
	if (theURL != nil && [[theURL absoluteString] length] > 0)
		return YES;
	return NO;
}

- (NSString *)description {
	return [self name];
}

- (void)dealloc {
	[URL release];
	[name release];
	[super dealloc];
}

#pragma mark Accessors

- (NSString *)name {
	if (name == nil)
		return @"";
	return [[name copy] autorelease];
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithURL:[self URL] name:[self name]];
}

@end
