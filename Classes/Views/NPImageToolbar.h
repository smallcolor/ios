//
//  NPImageToolbar.h
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NPImageToolbar : UIToolbar {
	UIImage *image;
}

@property (nonatomic, retain, readwrite) UIImage *image;

@end
