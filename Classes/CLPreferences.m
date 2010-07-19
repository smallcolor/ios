//
//  CLPreferences.m
//  CloudApp
//
//  Created by Nick Paulson on 4/3/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "CLPreferences.h"
#import "SFHFKeychainUtils.h"

NSString *CLHasCheckedCredentialsKey = @"CLHasCheckedCredentials";
NSString *CLUserKey = @"CLUser";
NSString *CLUploadURLKey = @"CLUploadURL";
NSString *CLServiceName = @"CloudAppiPhone";

@implementation CLPreferences

+ (void)initialize {
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
	[tempDict setObject:[NSNumber numberWithBool:NO] forKey:CLHasCheckedCredentialsKey];
	[tempDict setObject:@"http://my.cl.ly/items" forKey:CLUploadURLKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:tempDict];
}

+ (BOOL)hasCheckedCredentials {
	return [[NSUserDefaults standardUserDefaults] boolForKey:CLHasCheckedCredentialsKey];
}

+ (void)setHasCheckedCredentials:(BOOL)flag {
	[[NSUserDefaults standardUserDefaults] setBool:flag forKey:CLHasCheckedCredentialsKey];
}

+ (NSString *)user {
	return [[NSUserDefaults standardUserDefaults] stringForKey:CLUserKey];
}

+ (void)setUser:(NSString *)newUser {
	[[NSUserDefaults standardUserDefaults] setObject:newUser forKey:CLUserKey];
}

+ (NSURL *)uploadURL {
	return [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:CLUploadURLKey]];
}

+ (NSString *)password {
	if ([self user] == nil || [[self user] length] == 0)
		return nil;

	NSError *error = nil;
	NSString *password = [SFHFKeychainUtils getPasswordForUsername:[self user] andServiceName:CLServiceName error:&error];
	if (error != nil || password == nil || [password length] == 0)
		return nil;
	return password;
}

+ (void)setPassword:(NSString *)newPass {
	NSError *error = nil;
	[SFHFKeychainUtils storeUsername:[self user] andPassword:newPass forServiceName:CLServiceName updateExisting:NO error:&error];
}

+ (void)resetUserAndPassword {
	NSError *error = nil;
	[SFHFKeychainUtils deleteItemForUsername:[self user] andServiceName:CLServiceName error:&error];
}

@end
