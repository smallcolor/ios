//
//  CLAPIController.m
//  Cloud
//
//  Created by np101137 on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLAPIController.h"
#import "CLAPIConnection.h"
#import "NSArray+BSJSONAdditions.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "NSMutableURLRequest+NPPostBody.h"
#import "NSString+NPMimeType.h"
#import "CLAPIUpload.h"
#import "CLAPIFileUpload.h"
#import "CLAPIRedirectUpload.h"
#import "CLUploadItem.h"
#import "CLPreferences.h"

NSString * const CLAPICreateStartedNotification = @"CLAPIUploadStartedNotification";
NSString * const CLAPICreateProgressedNotification = @"CLAPIUploadProgressedNotification";
NSString * const CLAPICreateFailedNotification = @"CLAPIUploadFailedNotification";
NSString * const CLAPICreateCanceledNotification = @"CLAPICreateCanceledNotification";
NSString * const CLAPICreateSucceededNotification = @"CLAPIUploadSucceededNotification";
NSString * const CLAPIUploadsRequestSucceededNotification = @"CLAPIUploadsRequestSucceededNotification";
NSString * const CLAPIUploadsRequestFailedNotification = @"CLAPIUploadsRequestFailedNotification";

NSString * const CLAPIRequestBoundary = @"-----CloudRequestBoundary-----";

@interface CLAPIController ()
- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType delegate:(id)delegate;
- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType upload:(CLAPIUpload *)optionalUpload downloadIcons:(BOOL)downIcons delegate:(id)delegate;
- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType upload:(CLAPIUpload *)optionalUpload uniqueID:(NSString *)uniqueID downloadIcons:(BOOL)downIcons delegate:(id)delegate;
- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType upload:(CLAPIUpload *)optionalUpload uniqueID:(NSString *)uniqueID downloadIcons:(BOOL)downIcons resetCookies:(BOOL)resetCookies delegate:(id)delegate;
- (void)_threadedGetIconsWithInfo:(NSDictionary *)infoDict;
- (void)_informDelegateWithInfo:(NSDictionary *)infoDict;
@end

static CLAPIController *sharedController = nil;

@implementation CLAPIController
@synthesize checkedCredentials, user, password, uploadURL;

- (id)init {
	if (self = [super init]) {
		_uploadArray = [[NSMutableArray alloc] initWithCapacity:0];
		[self setUser:[CLPreferences user]];
		[self setPassword:[CLPreferences password]];
		[self setUploadURL:[CLPreferences uploadURL]];
	}
	return self;
}

#pragma mark API Methods

- (NSString *)getUploadsWithDelegate:(id)delegate downloadIcons:(BOOL)downIcons {
	return [self getUploadsWithPage:1 pageSize:5 downloadIcons:downIcons delegate:delegate];
}

- (NSString *)getUploadsWithPage:(NSInteger)pageNum pageSize:(NSInteger)pageSize downloadIcons:(BOOL)downIcons delegate:(id)delegate {
	NSURL *theURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?page=%i&per_page=%i", [[self uploadURL] absoluteString], pageNum, pageSize]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
	[request setHTTPMethod:@"GET"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	return [self _sendRequest:request withRequestType:CLAPIRequestTypeItems upload:nil downloadIcons:downIcons delegate:delegate];	
}

- (NSString *)uploadFileData:(NSData *)theData withFileName:(NSString *)fileName delegate:(id)delegate {
	if (theData == nil)
		return nil;
	if (fileName == nil)
		fileName = @"";
	return [self doRequestWithUpload:[CLAPIFileUpload fileUploadWithData:theData fileName:fileName] delegate:delegate];
}

- (NSString *)createRedirectWithURL:(NSURL *)aURL name:(NSString *)theName delegate:(id)delegate {
	if (aURL == nil || [[aURL absoluteString] length] == 0)
		return nil;
	return [self doRequestWithUpload:[CLAPIRedirectUpload redirectUploadWithURL:aURL name:theName] delegate:delegate];
}

- (NSString *)doRequestWithUpload:(CLAPIUpload *)theUpload delegate:(id)delegate {
	if (theUpload == nil || ![theUpload isValid])
		return nil;
	NSURLRequest *theRequest = [theUpload URLRequestForURL:[self uploadURL]];
	if (theRequest != nil) {
		return [self _sendRequest:theRequest withRequestType:([theUpload isKindOfClass:[CLAPIFileUpload class]] ? CLAPIRequestTypeS3Info : CLAPIRequestTypeCreate) upload:theUpload downloadIcons:NO delegate:delegate];
	}
	return nil;
}

- (NSString *)deleteUploadWithHRef:(NSURL *)theHRef delegate:(id)delegate {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theHRef];
	[request setHTTPMethod:@"DELETE"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	return [self _sendRequest:request withRequestType:CLAPIRequestTypeDelete delegate:delegate];
}

- (BOOL)hasRequest {
	return [_uploadArray count] > 0;
}

- (BOOL)isReady {
	return ([self hasCheckedCredentials]);
}

- (BOOL)hasCheckedCredentials {
	return [CLPreferences hasCheckedCredentials];
}

- (BOOL)hasCredentials {
	NSString *theUser = [self user];
	NSString *thePassword = [self password];
	NSString *theURL = [[self uploadURL] absoluteString];
	return (theUser != nil && [theUser length] > 0 && thePassword != nil && [thePassword length] > 0 && theURL != nil && [theURL length] > 0);	
}

- (void)cancelAllConnections {
	for (CLAPIConnection *currUpload in _uploadArray) {
		[currUpload cancel];
	}
}

- (void)cancelConnectionWithIdentifier:(NSString *)theIdentifier {
	for (CLAPIConnection *currUpload in _uploadArray) {
		if ([[currUpload identifier] isEqualToString:theIdentifier])
			[currUpload cancel];
	}
}

#pragma mark Accessors

- (NSString *)user {
	return [user lowercaseString];
}

#pragma mark Private Methods

- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType delegate:(id)delegate {
	return [self _sendRequest:request withRequestType:reqType upload:nil downloadIcons:NO delegate:delegate];
}

- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType upload:(CLAPIUpload *)optionalUpload downloadIcons:(BOOL)downIcons delegate:(id)delegate {
	return [self _sendRequest:request withRequestType:reqType upload:optionalUpload uniqueID:[[NSProcessInfo processInfo] globallyUniqueString] downloadIcons:downIcons delegate:delegate];
}

- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType upload:(CLAPIUpload *)optionalUpload uniqueID:(NSString *)uniqueID downloadIcons:(BOOL)downIcons delegate:(id)delegate {
	return [self _sendRequest:request withRequestType:reqType upload:optionalUpload uniqueID:uniqueID downloadIcons:downIcons resetCookies:(reqType == CLAPIRequestTypeItems) delegate:delegate];
}

- (NSString *)_sendRequest:(NSURLRequest *)request withRequestType:(CLAPIRequestType)reqType upload:(CLAPIUpload *)optionalUpload uniqueID:(NSString *)uniqueID downloadIcons:(BOOL)downIcons resetCookies:(BOOL)resetCookies delegate:(id)delegate {
	//Checking for the uploads request is so that we can check login.
	if ([self isReady] || reqType == CLAPIRequestTypeItems) {
		if (resetCookies) {
			NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[self uploadURL]];
			for (NSHTTPCookie *currCookie in cookies)
				[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:currCookie];
		}
		NSMutableURLRequest *fixedRequest = [[request mutableCopy] autorelease];;
		CLAPIConnection *connection = [[CLAPIConnection alloc] initWithRequest:fixedRequest delegate:self requestType:reqType startImmediately:NO];
		[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[connection setIdentifier:uniqueID];
		[connection setAPIDelegate:delegate];
		[connection setDownloadIcons:downIcons];
		[connection setUpload:optionalUpload];
		[_uploadArray addObject:connection];
		if ([connection requestType] == CLAPIRequestTypeS3Info) {
			[[NSNotificationCenter defaultCenter] postNotificationName:CLAPICreateStartedNotification object:[connection identifier] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[connection identifier], @"identifier", connection, @"connection", nil]];
		}
		[connection start];
		[connection release];
		return uniqueID;
	}
	return nil;
}


- (void)_threadedGetIconsWithInfo:(NSDictionary *)infoDict {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *theItems = [infoDict objectForKey:@"items"];
	for (CLUploadItem *anItem in theItems) {
		NSURL *theURL = [anItem iconURL];
		if (theURL != nil) {
			NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20.0];
			NSData *iconData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:NULL error:NULL];
			if (iconData != nil) {
				UIImage *theIcon = [UIImage imageWithData:iconData];
				[anItem setIcon:theIcon];
			}
		}
	}
	[self performSelectorOnMainThread:@selector(_informDelegateWithInfo:) withObject:infoDict waitUntilDone:YES modes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, nil]];
	[pool release];
}

- (void)_informDelegateWithInfo:(NSDictionary *)infoDict {
	CLAPIConnection *theConnection = [infoDict objectForKey:@"connection"];
	id delegate = [theConnection APIDelegate];
	NSArray *theItems = [infoDict objectForKey:@"items"];
	BOOL gotAllIcons = YES;
	for (CLUploadItem *anItem in theItems) {
		UIImage *theIcon = [anItem icon];
		if (theIcon == nil)
			[anItem setIcon:[UIImage imageNamed:@"UnknownFile.png"]];
		gotAllIcons = NO;
	}
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[theConnection identifier], @"identifier", theItems, @"items", [NSNumber numberWithBool:YES], @"attemptedIconDownload", [NSNumber numberWithBool:gotAllIcons], @"allIconDownloadsSucceeded", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:CLAPIUploadsRequestSucceededNotification object:[theConnection identifier] userInfo:userInfo];
	if (delegate != nil && [delegate respondsToSelector:@selector(uploadsRequest:succeededWithResponseArray:attemptedIconDownload:allIconDownloadsSucceeded:)])
		[delegate uploadsRequest:[theConnection identifier] succeededWithResponseArray:theItems attemptedIconDownload:YES allIconDownloadsSucceeded:gotAllIcons];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(CLAPIConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	if ([connection requestType] == CLAPIRequestTypeCreate) {
		CGFloat percent = ((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:percent], @"percent", [connection identifier], @"identifier", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:CLAPICreateProgressedNotification object:[connection identifier] userInfo:userInfo];
	}
}

- (void)connection:(CLAPIConnection *)connection didReceiveData:(NSData *)data {
	[[connection data] appendData:data];
}

- (void)connection:(CLAPIConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[connection setStatusCode:[(NSHTTPURLResponse *)response statusCode]];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge previousFailureCount] == 0) {
		NSURLCredential *credential = [NSURLCredential credentialWithUser:[self user] password:[self password] persistence:NSURLCredentialPersistenceNone];
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	} else {
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
}

- (void)connectionDidFinishLoading:(CLAPIConnection *)connection {
	NSString *dataString = [[NSString alloc] initWithData:[connection data] encoding:NSUTF8StringEncoding];
	id delegate = [connection APIDelegate];
	if ([connection requestType] == CLAPIRequestTypeItems) {
		NSArray *respArray = [NSArray arrayWithJSONString:dataString];
		NSMutableArray *itemsArray = [NSMutableArray arrayWithCapacity:[respArray count]];
		for (NSDictionary *currDict in respArray) {
			[itemsArray addObject:[CLUploadItem itemWithDictionary:currDict]];
		}
		if ([connection downloadIcons])
			[NSThread detachNewThreadSelector:@selector(_threadedGetIconsWithInfo:) toTarget:self withObject:[NSDictionary dictionaryWithObjectsAndKeys:connection, @"connection", itemsArray, @"items", nil]];
		else {
			for (CLUploadItem *anItem in itemsArray)
				[anItem setIcon:[UIImage imageNamed:@"UnknownFile.png"]];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[connection identifier], @"identifier", itemsArray, @"items", [NSNumber numberWithBool:NO], @"attemptedIconDownload", [NSNumber numberWithBool:NO], @"allIconDownloadsSucceeded", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:CLAPIUploadsRequestSucceededNotification object:[connection identifier] userInfo:userInfo];
			if (delegate != nil && [delegate respondsToSelector:@selector(uploadsRequest:succeededWithResponseArray:attemptedIconDownload:allIconDownloadsSucceeded:)])
				[delegate uploadsRequest:[connection identifier] succeededWithResponseArray:itemsArray attemptedIconDownload:NO allIconDownloadsSucceeded:NO];
		}
	}  else if ([connection requestType] == CLAPIRequestTypeDelete) {
		if ([connection statusCode] == 404) {
			[self connection:connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]];
		} else {
			if (delegate != nil && [delegate respondsToSelector:@selector(deleteRequestSucceeded:)])
				[delegate deleteRequestSucceeded:[connection identifier]];
		}
	} else if ([connection requestType] == CLAPIRequestTypeCreate) {
		NSDictionary *respDictionary = [NSDictionary dictionaryWithJSONString:dataString];
		if (respDictionary != nil) {
			CLUploadItem *theItem = [CLUploadItem itemWithDictionary:respDictionary];
			if (delegate && [delegate respondsToSelector:@selector(createRequest:succeededWithResponseItem:)])
				[delegate createRequest:[connection identifier] succeededWithResponseItem:theItem];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[connection identifier], @"identifier", theItem, @"item", nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:CLAPICreateSucceededNotification object:[connection identifier] userInfo:userInfo];
		} else {
			[self connection:connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
		}
	} else if ([connection requestType] == CLAPIRequestTypeS3Info) {
		NSDictionary *respDictionary = [NSDictionary dictionaryWithJSONString:dataString];
		NSURL *theURL = [NSURL URLWithString:[respDictionary objectForKey:@"url"]];
		BOOL didFail = NO;
		if (theURL != nil) {
			NSDictionary *paramsDict = [respDictionary objectForKey:@"params"];
			if (paramsDict != nil) {
				NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL];
				[request setHTTPMethod:@"POST"];
				[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
				[request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", CLAPIRequestBoundary] forHTTPHeaderField:@"Content-Type"];
				for (NSString *currKey in [paramsDict allKeys]) {
					[request addToPOSTBodyString:[paramsDict objectForKey:currKey] forKey:currKey boundary:CLAPIRequestBoundary];
				}
				[request addToPOSTBodyFileData:[(CLAPIFileUpload *)[connection upload] fileData] withFileName:[(CLAPIFileUpload *)[connection upload] fileName] mimeType:[[(CLAPIFileUpload *)[connection upload] fileName] mimeType] forKey:@"file" boundary:CLAPIRequestBoundary];
				[self _sendRequest:request withRequestType:CLAPIRequestTypeCreate upload:nil uniqueID:[connection identifier] downloadIcons:NO delegate:delegate];
			} else
				didFail = YES;
		} else
			didFail = YES;
		
		if (didFail) {
			[self connection:connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:nil]];
		}
	}
	[_uploadArray removeObject:connection];
	[dataString release];
}

- (void)connectionWasCanceled:(CLAPIConnection *)connection {
	if ([connection requestType] == CLAPIRequestTypeCreate)
		[[NSNotificationCenter defaultCenter] postNotificationName:CLAPICreateCanceledNotification object:[connection identifier] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[connection identifier], @"identifier", nil]];
	[_uploadArray removeObject:connection];
}

- (void)connection:(CLAPIConnection *)connection didFailWithError:(NSError *)error {
	id delegate = [connection APIDelegate];
	SEL theSelector = NULL;
	NSString *errorDescription = @"Unknown error";
	switch ([error code]) {
		case NSURLErrorFileDoesNotExist:
			errorDescription = @"Resource does not exist";
			break;
		case NSURLErrorBadServerResponse:
			errorDescription = @"Bad server response";
			break;
		case NSURLErrorUserCancelledAuthentication:
			errorDescription = @"Invalid login credentials";
			break;
		case NSURLErrorNotConnectedToInternet:
			errorDescription = @"Not connected to internet";
			break;
	}
	if ([connection requestType] == CLAPIRequestTypeCreate || [connection requestType] == CLAPIRequestTypeS3Info) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorDescription, @"errorDescription", [NSNumber numberWithInteger:[error code]], @"errorCode", [connection identifier], @"identifier", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:CLAPICreateFailedNotification object:[connection identifier] userInfo:userInfo];
		theSelector = @selector(createRequest:failedWithError:);
	} else if ([connection requestType] == CLAPIRequestTypeDelete) {
		theSelector = @selector(deleteRequest:failedWithError:);
	} else if ([connection requestType] == CLAPIRequestTypeItems) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorDescription, @"errorDescription", [NSNumber numberWithInteger:[error code]], @"errorCode", [connection identifier], @"identifier", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:CLAPIUploadsRequestFailedNotification object:[connection identifier] userInfo:userInfo];
		theSelector = @selector(uploadsRequest:failedWithError:);
	}
	
	if (theSelector != NULL && delegate != nil && [delegate respondsToSelector:theSelector])
		[delegate performSelector:theSelector withObject:[connection identifier] withObject:error];
	[_uploadArray removeObject:connection];
}

#pragma mark Singleton Methods

+ (CLAPIController *)sharedController {
	@synchronized(self) {
		if (sharedController == nil)
			sharedController = [[[self class] alloc] init];
	}
	return sharedController;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedController == nil) {
			sharedController = [super allocWithZone:zone];
			return sharedController;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax; 
}

- (void)release {
	
}

- (id)autorelease {
	return self;
}

@end
