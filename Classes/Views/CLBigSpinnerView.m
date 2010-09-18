//
//  CLBigSpinnerView.m
//  Cloud
//
//  Created by np101137 on 11/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CLBigSpinnerView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat CLSpinnerTimerInterval = 0.10;
static CGFloat CLSpinnerDegreeIncrement = 30;

@interface CLBigSpinnerView (Private)
- (void)_timerDidEnd:(NSTimer *)aTimer;
- (void)_notificationReceived:(NSNotification *)theNotification;
@end

@implementation CLBigSpinnerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_imageView.contentMode = UIViewContentModeCenter;
		_imageView.image = [UIImage imageNamed:@"BigSpinner.png"];
		[self addSubview:_imageView];
		self.autoresizesSubviews = NO;
		_rotatingDegrees = 0;
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *notification) {
			_wasAnimatingWhenBackgrounded = _isAnimating;
			[self stopAnimating];
		}];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *notification) {
			if (_wasAnimatingWhenBackgrounded)
				[self startAnimating];
		}];
		
    }
    return self;
}

- (void)startAnimating {
	if (_isAnimating == YES)
		return;
	_isAnimating = YES;
	_timer = [[NSTimer scheduledTimerWithTimeInterval:CLSpinnerTimerInterval target:self selector:@selector(_timerDidEnd:) userInfo:nil repeats:YES] retain];
}

- (void)stopAnimating {
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
	_rotatingDegrees += CLSpinnerDegreeIncrement;
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
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
	[super dealloc];
}

@end
