//
//  CLAPIController.h
//  Cloud
//
//  Created by np101137 on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLAPIUpload, CLUploadItem;

//userInfo contains @"identifier" --> NSString connection identifier;
//@"connection" --> CLAPIConnection
extern NSString * const CLAPICreateStartedNotification;

//@"identifier" --> NSString connection identifier;
//userInfo contains @"percent" --> NSNumber with float percentage;
extern NSString * const CLAPICreateProgressedNotification;

//userInfo contains @"identifier" --> NSString connection identifier;
//@"errorDescription" --> NSString localized error description;
//@"errorCode" --> NSNumber with integer error code;
extern NSString * const CLAPICreateFailedNotification;

//userInfo contains @"identifier" --> NSString connection identifier;
extern NSString * const CLAPICreateCanceledNotification;

//userInfo contains @"identifier" --> NSString connection identifier;
//@"item" --> CLUploadItem.
extern NSString * const CLAPICreateSucceededNotification;

//userInfo contains @"identifier" --> NSString connection identifier;
//@"items" --> NSArray of CLUploadItems.
//@"attemptedIconDownload" --> NSNumber BOOL
//@"allIconDownloadsSucceeded" --> NSNumber BOOL
extern NSString * const CLAPIUploadsRequestSucceededNotification;

//userInfo contains @"identifier" --> NSString connection identifier;
//@"errorDescription" --> NSString localized error description;
//@"errorCode" --> NSNumber with integer error code;
extern NSString * const CLAPIUploadsRequestFailedNotification;

//This is used as the bounary for all API requests.
extern NSString * const CLAPIRequestBoundary;

@interface NSObject (CLAPIRequest)
- (void)deleteRequestSucceeded:(NSString *)requestIdentifier;
- (void)deleteRequest:(NSString *)requestIdentifier failedWithError:(NSError *)anError;
- (void)uploadsRequest:(NSString *)requestIdentifier succeededWithResponseArray:(NSArray *)uploadsArray attemptedIconDownload:(BOOL)didAttempt allIconDownloadsSucceeded:(BOOL)iconSucceeded;
- (void)uploadsRequest:(NSString *)requestIdentifier failedWithError:(NSError *)anError;
- (void)createRequest:(NSString *)requestIdentifier succeededWithResponseItem:(CLUploadItem *)theItem;
- (void)createRequest:(NSString *)requestIdentifier failedWithError:(NSError *)anError;
@end

@interface CLAPIController : NSObject {
	NSMutableArray *_uploadArray;
	BOOL checkedCredentials;
	NSString *user;
	NSString *password;
	NSURL *uploadURL;
}

@property (assign, getter=hasCheckedCredentials) BOOL checkedCredentials;
@property (retain) NSString *user;
@property (retain) NSString *password;
@property (retain) NSURL *uploadURL;

+ (CLAPIController *)sharedController;
- (NSString *)getUploadsWithDelegate:(id)delegate downloadIcons:(BOOL)downIcons;
- (NSString *)getUploadsWithPage:(NSInteger)pageNum pageSize:(NSInteger)pageSize downloadIcons:(BOOL)downIcons delegate:(id)delegate;
- (NSString *)uploadFileData:(NSData *)theData withFileName:(NSString *)fileName delegate:(id)delegate;
- (NSString *)deleteUploadWithHRef:(NSURL *)theHRef delegate:(id)delegate;
- (NSString *)createRedirectWithURL:(NSURL *)aURL name:(NSString *)theName delegate:(id)delegate;
- (NSString *)doRequestWithUpload:(CLAPIUpload *)theUpload delegate:(id)delegate;
- (BOOL)hasRequest;
- (BOOL)hasCredentials;
- (BOOL)isReady;
- (void)cancelAllConnections;
- (void)cancelConnectionWithIdentifier:(NSString *)theIdentifier;

- (NSString *)user;
- (NSString *)password;
- (NSURL *)uploadURL;

@end