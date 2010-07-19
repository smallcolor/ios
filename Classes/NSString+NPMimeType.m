//
//  NSString+NPMimeType.m
//  Cloud
//
//  Created by np101137 on 9/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+NPMimeType.h"


@implementation NSString (NPMimeType)

- (NSString *)mimeType {
	NSString* fullPath = [self stringByExpandingTildeInPath];
	NSURL* fileUrl = [NSURL fileURLWithPath:fullPath];
	NSURLRequest* fileUrlRequest = [NSURLRequest requestWithURL:fileUrl];
	
	NSError* error = nil;
	NSURLResponse* response = nil;
	[NSURLConnection sendSynchronousRequest:fileUrlRequest returningResponse:&response error:&error];
	
	NSString* mimeType = [response MIMEType];
	
	if (mimeType == nil || [mimeType length] == 0)
		mimeType = @"application/octet-stream";
    return mimeType;
}

@end
