//
//  CLAPIRedirectUpload.h
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CLAPIUpload.h"


@interface CLAPIRedirectUpload : CLAPIUpload {
	NSURL *URL;
	NSString *name;
}

@property (copy) NSURL *URL;
@property (copy) NSString *name;

+ (CLAPIRedirectUpload *)redirectUploadWithURL:(NSURL *)theURL name:(NSString *)theName;
- (id)initWithURL:(NSURL *)theURL name:(NSString *)theName;

@end
