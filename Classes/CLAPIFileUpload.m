//
//  CLAPIFileUpload.m
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLAPIFileUpload.h"
#import "NSMutableURLRequest+NPPostBody.h"
#import "NSString+NPMimeType.h"
#import "CLAPIController.h"

#define kMegabytes 50
#define kKilobytes kMegabytes * 1024
#define kBytes kKilobytes * 1024

@implementation CLAPIFileUpload
@synthesize fileData, fileName;

+ (CLAPIFileUpload *)fileUploadWithData:(NSData *)theData fileName:(NSString *)theName {
	return [[[[self class] alloc] initWithFileData:theData fileName:theName] autorelease];
}

- (id)initWithFileData:(NSData *)theData fileName:(NSString *)theName {
	if (self = [super init]) {
		[self setFileData:theData];
		[self setFileName:theName];
	}
	return self;
}

- (NSURLRequest *)URLRequestForURL:(NSURL *)theURL {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[theURL absoluteString] stringByAppendingString:@"/new"]]];
	[request setHTTPMethod:@"GET"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
//	[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", CLAPIRequestBoundary] forHTTPHeaderField:@"Content-Type"];
//	[request addToPOSTBodyFileData:[self fileData] withFileName:[self fileName] mimeType:[[self fileName] mimeType] forKey:@"upload[attachment]" boundary:CLAPIRequestBoundary];
	return request;
}

- (BOOL)isValid {
	if ([self fileData] != nil && [[self fileData] length] <= kBytes)
		return YES;
	return NO;
}

- (NSString *)description {
	return [self fileName];
}

- (void)dealloc {
	[fileName release];
	[fileData release];
	[super dealloc];
}

#pragma mark Accessors

- (NSString *)fileName {
	if (fileName == nil)
		return @"";
	return [[fileName copy] autorelease];
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithFileData:[self fileData] fileName:[self fileName]];
}

@end
