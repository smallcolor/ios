//
//  CLUploadItem.h
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface CLUploadItem : NSObject<NSCopying> {
	UIImage *icon;
	NSURL *iconURL;
	NSURL *HRef;
	NSString *name;
	NSInteger viewCount;
	NSURL *URL;
}

@property (retain) UIImage *icon;
@property (retain) NSURL *iconURL;
@property (retain) NSURL *HRef;
@property (retain) NSString *name;
@property (assign) NSInteger viewCount;
@property (retain) NSURL *URL;

+ (CLUploadItem *)itemWithDictionary:(NSDictionary *)serverDict;
- (id)initWithDictionary:(NSDictionary *)serverDict;
+ (CLUploadItem *)itemWithURL:(NSURL *)theURL name:(NSString *)theName iconURL:(NSURL *)theIconURL HRef:(NSURL *)theHRef viewCount:(NSInteger)theCount;
- (id)initWithURL:(NSURL *)theURL name:(NSString *)theName iconURL:(NSURL *)theIconURL HRef:(NSURL *)theHRef viewCount:(NSInteger)theCount;

@end
