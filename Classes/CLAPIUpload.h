//
//  CLAPIUpload.h
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLAPIUpload : NSObject<NSCopying> {

}

//Returns the request used by the API Controller to do the upload.
//Default implementation returns nil, override in subclass.
- (NSURLRequest *)URLRequestForURL:(NSURL *)theURL;

//Returns whether or not all the required fields are valid for the upload.
- (BOOL)isValid;

@end
