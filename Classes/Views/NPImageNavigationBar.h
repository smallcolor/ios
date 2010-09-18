//
//  NPImageNavigationBar.h
//  CloudApp
//
//  Created by Nick Paulson on 7/25/10.
//  Copyright (c) 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NPImageNavigationBar : UINavigationBar {
	UIImageView *_imageView;
}

@property (nonatomic, retain, readwrite) UIImage *image;

@end
