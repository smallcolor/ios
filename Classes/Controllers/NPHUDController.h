//
//  NPHUDController.h
//  CloudApp
//
//  Created by Nick Paulson on 8/6/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NPHUDController : UIResponder {
	UIView *customView;
	NSString *text;
	
	IBOutlet UILabel *textLabel;
	IBOutlet UIView *hudView;
	IBOutlet UIView *backgroundColorView;
	IBOutlet UIWindow *hudWindow;
	
	BOOL _windowIsShowing;
}

@property (nonatomic, retain, readwrite) UIView *customView;
@property (nonatomic, copy, readwrite) NSString *text;

- (id)initWithBigSpinner;
- (id)initWithImage:(UIImage *)theImage;
- (id)initWithCustomView:(UIView *)theView;

- (void)setCustomView:(UIView *)newView animated:(BOOL)animated;
- (void)showWindow;
- (void)close;

@end
