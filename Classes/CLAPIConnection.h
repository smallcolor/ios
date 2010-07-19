//
//  CLAPIConnection.h
//  Cloud
//
//  Created by np101137 on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLAPIUpload;

typedef enum _CLAPIRequestType {
	CLAPIRequestTypeItems = 0,
	CLAPIRequestTypeCreate = 1,
	CLAPIRequestTypeDelete = 2,
	CLAPIRequestTypeS3Info = 3
} CLAPIRequestType;

typedef enum _CLAPIResponseType {
	CLAPIResponseTypeSingleItem = 0,
	CLAPIResponseTypeMultipleItems = 1,
	CLAPIResponseTypeUploadInfo = 2,
	CLAPIResponseTypeNone = 3
} CLAPIResponseType;

@interface CLAPIConnection : NSURLConnection {
	NSMutableData *data;
	NSInteger statusCode;
	CLAPIRequestType requestType;
	id APIDelegate;
	NSString *identifier;
	BOOL downloadIcons;
	CLAPIUpload *upload;
	id _internalDelegate;
}

@property (assign) NSInteger statusCode;
@property (assign) CLAPIRequestType requestType;
@property (assign) id APIDelegate;
@property (copy) NSString *identifier;
@property (assign) BOOL downloadIcons;
@property (copy) CLAPIUpload *upload;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(CLAPIRequestType)reqType;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate requestType:(CLAPIRequestType)reqType startImmediately:(BOOL)startImmediately;
- (NSMutableData *)data;

@end

@interface NSObject (CLAPIConnectionDelegateAdditions)
- (void)connectionWasCanceled:(CLAPIConnection *)connection;
@end
