//
//  NSMutableURLRequest+NPPostBody.m
//  Cloud
//
//  Created by np101137 on 7/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSMutableURLRequest+NPPostBody.h"

@implementation NSMutableURLRequest (NPPostBody)

- (void)addToPOSTBodyString:(NSString *)aString forKey:(NSString *)aKey boundary:(NSString *)aBoundary {
	NSMutableData *postBody = [NSMutableData dataWithData:[self HTTPBody]];
	
	if ([postBody length] == 0)
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", aBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", aKey] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[aString dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", aBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[self setHTTPBody:postBody];
}

- (void)addToPOSTBodyFileData:(NSData *)someData withFileName:(NSString *)aName mimeType:(NSString *)aMimeType forKey:(NSString *)aKey boundary:(NSString *)aBoundary {
	if (aName == nil ||[aName length] == 0)
		aName = @"UnknownFileName";
	
	if (aMimeType == nil || [aMimeType length] == 0)
		aMimeType = @"application/octet-stream";
				  
	NSMutableData *postBody = [NSMutableData dataWithData:[self HTTPBody]];
	if ([postBody length] == 0)
		[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", aBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", aKey, aName] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", aMimeType] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:someData];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", aBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[self setHTTPBody:postBody];
}

@end
