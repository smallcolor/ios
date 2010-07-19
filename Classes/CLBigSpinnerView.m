//
//  CLBigSpinnerView.m
//  Cloud
//
//  Created by np101137 on 11/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLBigSpinnerView.h"
#import <QuartzCore/QuartzCore.h>

#define kTimerInterval 0.10
#define kDegreeIncrement 30

@interface CLBigSpinnerView (Private)
- (void)_timerDidEnd:(NSTimer *)aTimer;
@end

@implementation CLBigSpinnerView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)anImage {
    self = [super initWithFrame:frame];
    if (self) {
		_imageView = [[UIImageView alloc] initWithFrame:frame];
		[_imageView	setImage:anImage];
		[self addSubview:_imageView];
		_rotatingDegrees = 0;
    }
    return self;
}

- (void)startAnimation {
	if (_isAnimating == YES)
		return;
	_isAnimating = YES;
	_timer = [[NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(_timerDidEnd:) userInfo:nil repeats:YES] retain];
}

- (void)stopAnimation {
	if (_isAnimating == NO)
		return;
	if (_timer) {
		if ([_timer isValid])
			[_timer invalidate];
		[_timer release];
		_timer = nil;
	}
	_isAnimating = NO;
	_rotatingDegrees = 0;
}

- (void)_timerDidEnd:(NSTimer *)aTimer {
	_rotatingDegrees += kDegreeIncrement;
	if (_rotatingDegrees >= 360)
		_rotatingDegrees -= 360;
	CGAffineTransform rotate = CGAffineTransformMakeRotation((_rotatingDegrees * M_PI) / 180);
	[_imageView setTransform:rotate];
}

- (void)dealloc {
	if (_timer != nil) {
		if ([_timer isValid])
			[_timer invalidate];
		[_timer release];
		_timer = nil;
	}
	[_imageView release];
	[super dealloc];
}

@end
