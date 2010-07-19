//
//  CLPreferences.h
//  CloudApp
//
//  Created by Nick Paulson on 4/3/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CLPreferences : NSObject {

}

+ (BOOL)hasCheckedCredentials;
+ (void)setHasCheckedCredentials:(BOOL)flag;
+ (NSString *)user;
+ (void)setUser:(NSString *)newUser;
+ (NSURL *)uploadURL;
+ (NSString *)password;
+ (void)setPassword:(NSString *)newPass;
+ (void)resetUserAndPassword;

@end
