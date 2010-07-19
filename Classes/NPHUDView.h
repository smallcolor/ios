//
//  NPHUDView.h
//  CloudApp
//
//  Created by Nick Paulson on 3/4/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NPHUDView;
@protocol NPHUDViewDelegate <NSObject>
@optional
- (void)HUDViewWillShow:(NPHUDView *)theView;
- (void)HUDViewDidShow:(NPHUDView *)theView;
- (void)HUDViewWillDismiss:(NPHUDView *)theView;
- (void)HUDViewDidDismiss:(NPHUDView *)theView;
@end


@interface NPHUDView : UIView {
	CGFloat borderRadius;
	UIView *contentView;
	NSString *text;
	UIColor *HUDColor;
	BOOL overlaysEntireScreen;
	id <NPHUDViewDelegate> delegate;
	UIWindow *_blockingWindow;
}

@property (assign, readwrite) CGFloat borderRadius;
@property (retain, readwrite) UIView *contentView;
@property (retain, readwrite) NSString *text;
@property (retain, readwrite) UIColor *HUDColor;
@property (assign, readwrite) BOOL overlaysEntireScreen;
@property (assign, readwrite) id <NPHUDViewDelegate> delegate;

- (id)initWithContentView:(UIView *)aView text:(NSString *)theText;
- (id)initWithImage:(UIImage *)anImage text:(NSString *)someText;
- (void)show;
- (void)setImage:(UIImage *)anImage;
- (void)dismiss;

@end
