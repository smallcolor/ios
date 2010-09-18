//
//  NPBlockActionSheet.h
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NPBlockActionSheet : UIActionSheet<UIActionSheetDelegate> {
	void (^didDismissBlock)(NSInteger buttonIndex);
}

@property (nonatomic, copy, readwrite) void (^didDismissBlock)(NSInteger buttonIndex);

@end
