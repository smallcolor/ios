//
//  CLAPIFileUpload.h
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CLAPIUpload.h"


@interface CLAPIFileUpload : CLAPIUpload {
	NSData *fileData;
	NSString *fileName;
}

@property (copy) NSData *fileData;
@property (copy) NSString *fileName;

+ (CLAPIFileUpload *)fileUploadWithData:(NSData *)theData fileName:(NSString *)theName;
- (id)initWithFileData:(NSData *)theData fileName:(NSString *)theName;

@end
