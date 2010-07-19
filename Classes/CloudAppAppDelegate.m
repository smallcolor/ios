//
//  CloudAppAppDelegate.m
//  CloudApp
//
//  Created by Nick Paulson on 2/27/10.
//  Copyright Linebreak 2010. All rights reserved.
//

#import "CloudAppAppDelegate.h"
#import "CLUploadViewController.h"

@implementation CloudAppAppDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Override point for customization after application launch
	CLUploadViewController *temp = [[CLUploadViewController alloc] init];
	[window addSubview:[temp view]];
	
	[window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
