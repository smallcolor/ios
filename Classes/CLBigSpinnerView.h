//
//  CLBigSpinnerView.h
//  Cloud
//
//  Created by np101137 on 11/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CLBigSpinnerView : UIView {
	UIImageView *_imageView;
	BOOL _isAnimating;
	CGFloat _rotatingDegrees;
	NSTimer *_timer;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)anImage;
- (void)startAnimation;
- (void)stopAnimation;

@end
