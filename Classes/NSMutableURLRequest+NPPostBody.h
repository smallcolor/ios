//
//  NSMutableURLRequest+NPPostBody.h
//  Cloud
//
//  Created by np101137 on 7/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (NPPostBody)

- (void)addToPOSTBodyString:(NSString *)aString forKey:(NSString *)aKey boundary:(NSString *)aBoundary;
- (void)addToPOSTBodyFileData:(NSData *)someData withFileName:(NSString *)aName mimeType:(NSString *)aMimeType forKey:(NSString *)aKey boundary:(NSString *)aBoundary;

@end
