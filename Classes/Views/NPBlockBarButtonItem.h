//
//  NPBlockBarButtonItem.h
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NPBlockBarButtonItem : UIBarButtonItem {
	void (^block)(id sender);
}

@property (nonatomic, copy, readwrite) void (^block)(id sender);

@end
