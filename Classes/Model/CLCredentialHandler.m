//
//  CLCredentialHandler.m
//  CloudApp
//
//  Created by Nick Paulson on 8/8/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "CLCredentialHandler.h"
#import "SFHFKeychainUtils.h"

NSString * const CLCredentialChangedNotification = @"CLCredentialChangedNotification";

static NSString * const CLCredentialEmailKey = @"CLEmailCredential";
static NSString * const CLCredentialServiceName = @"CloudApp iOS";

@implementation CLCredentialHandler

+ (NSString *)email {
	return [[NSUserDefaults standardUserDefaults] stringForKey:CLCredentialEmailKey];
}

+ (void)setEmail:(NSString *)email {
	[[NSUserDefaults standardUserDefaults] setObject:email forKey:CLCredentialEmailKey];
}

+ (NSString *)password {
	if ([self email] == nil)
		return nil;
	NSError *error = nil;
	NSString *pass = [SFHFKeychainUtils getPasswordForUsername:[self email] andServiceName:CLCredentialServiceName error:&error];
	if (error != nil)
		return nil;
	return pass;
}

+ (void)setPassword:(NSString *)password {
	if ([self email] == nil || password == nil)
		return;
	[SFHFKeychainUtils storeUsername:[self email] andPassword:password forServiceName:CLCredentialServiceName updateExisting:YES error:nil];
}

+ (void)clearCredentials {
	[SFHFKeychainUtils deleteItemForUsername:[self email] andServiceName:CLCredentialServiceName error:nil];
	[self setEmail:nil];
	[self setPassword:nil];
}

+ (BOOL)isComplete {
	NSString *email = [self email];
	NSString *password = [self password];
	return (email != nil && [email length] > 0 && password != nil && [password length] > 0);
}

@end
