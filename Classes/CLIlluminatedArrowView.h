//
//  CLIlluminatedArrowView.h
//  CloudApp
//
//  Created by Nick Paulson on 3/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLIlluminatedArrowView;

@protocol CLIlluminatedArrowViewDelegate <NSObject>
@optional
- (void)arrowViewDidComplete:(CLIlluminatedArrowView *)arrowView;
@end


@interface CLIlluminatedArrowView : UIView {
	UIImageView *_arrowImageView;
	UIView *_tempView;
	UIImageView *_glowImageView;
	UIImage *_touchedGlow;
	UIImage *_untouchedGlow;
	BOOL _isTouchDown;
	id<CLIlluminatedArrowViewDelegate> delegate;
}

@property (assign, readwrite) id<CLIlluminatedArrowViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDel;
- (void)restartAnimation;

@end
