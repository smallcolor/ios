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
	BOOL _wasAnimatingWhenBackgrounded;
	CGFloat _rotatingDegrees;
	NSTimer *_timer;
}

- (void)startAnimating;
- (void)stopAnimating;

@end
