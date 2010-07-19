//
//  CLUploadItem.m
//  APITest
//
//  Created by Nick Paulson on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLUploadItem.h"


@implementation CLUploadItem
@synthesize icon, iconURL, HRef, name, viewCount, URL;

+ (CLUploadItem *)itemWithURL:(NSURL *)theURL name:(NSString *)theName iconURL:(NSURL *)theIconURL HRef:(NSURL *)theHRef viewCount:(NSInteger)theCount {
	return [[[[self class] alloc] initWithURL:theURL name:theName iconURL:theIconURL HRef:theHRef viewCount:theCount] autorelease];
}

+ (CLUploadItem *)itemWithDictionary:(NSDictionary *)serverDict {
	return [[[[self class] alloc] initWithDictionary:serverDict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)serverDict {
	return [[[self class] alloc] initWithURL:[NSURL URLWithString:[serverDict objectForKey:@"url"]] name:[serverDict objectForKey:@"name"] iconURL:[NSURL URLWithString:[serverDict objectForKey:@"icon"]] HRef:[NSURL URLWithString:[serverDict objectForKey:@"href"]] viewCount:[[serverDict objectForKey:@"view_counter"] integerValue]];
}
			 
- (id)initWithURL:(NSURL *)theURL name:(NSString *)theName iconURL:(NSURL *)theIconURL HRef:(NSURL *)theHRef viewCount:(NSInteger)theCount {
	if (self = [super init]) {
		[self setURL:theURL];
		[self setName:theName];
		[self setIconURL:theIconURL];
		[self setHRef:theHRef];
		[self setViewCount:theCount];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ at %@ with %i views and href is %@.", [self name], [self URL], [self viewCount], [self HRef]];
}

- (void)setName:(NSString *)newName {
	if (newName == (NSString *)[NSNull null])
		newName = @"";
	[name autorelease];
	name = [newName copy];
}

- (void)dealloc {
	[icon release];
	[iconURL release];
	[HRef release];
	[name release];
	[URL release];
	[super dealloc];
}

#pragma mark NSCopying Methods

- (id)copyWithZone:(NSZone *)zone {
	CLUploadItem *theItem = [[[self class] allocWithZone:zone] initWithURL:[self URL] name:[self name] iconURL:[self iconURL] HRef:[self HRef] viewCount:[self viewCount]];
	[theItem setIcon:[self icon]];
	return theItem;
}

@end
