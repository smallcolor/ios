//
//  CLCredentialHandler.h
//  CloudApp
//
//  Created by Nick Paulson on 8/8/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CLCredentialChangedNotification;

@interface CLCredentialHandler : NSObject {

}

+ (NSString *)email;
+ (void)setEmail:(NSString *)email;
+ (NSString *)password;
+ (void)setPassword:(NSString *)password;
+ (BOOL)isComplete;
+ (void)clearCredentials;

@end
