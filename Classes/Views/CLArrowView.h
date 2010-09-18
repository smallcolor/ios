//
//  CLArrowView.h
//  CloudApp
//
//  Created by Nick Paulson on 8/6/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CALayer;
@interface CLArrowView : UIView {
	CALayer *_glowRootLayer;
	CALayer *_glowImageLayer;
	CALayer *_arrowLayer;
	
	BOOL _isAnimating;
	BOOL _wasAnimatingWhenBackgrounded;
	
	void (^block)(void);
}

@property (nonatomic, copy, readwrite) void (^block)(void);

- (void)startAnimating;
- (void)stopAnimating;

@end
