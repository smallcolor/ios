//
//  CLArrowView.m
//  CloudApp
//
//  Created by Nick Paulson on 8/6/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "CLArrowView.h"
#import <QuartzCore/QuartzCore.h>
#include <dispatch/dispatch.h>

@interface CLArrowView ()
- (void)_setupLayers;
- (void)_setupNotifications;
- (CABasicAnimation *)_fadeAnimation;
@end

@implementation CLArrowView
@synthesize block;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _setupLayers];
		[self _setupNotifications];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self _setupLayers];
		[self _setupNotifications];
	}
	return self;
}

- (void)_setupNotifications {
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *notification) {
		_wasAnimatingWhenBackgrounded = _isAnimating;
		[self stopAnimating];
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *notification) {
		if (_wasAnimatingWhenBackgrounded) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4e8), dispatch_get_main_queue(), ^{
				[self startAnimating];
			});
		}
	}];
}

- (void)_setupLayers {
	CGFloat theWidth = 153.0;
	CGFloat theHeight = 206.0;
	CGRect defaultFrame = CGRectMake((self.bounds.size.width - theWidth) / 2, (self.bounds.size.height - theHeight) / 2, theWidth, theHeight);
	
	_arrowLayer = [CALayer layer];
	_arrowLayer.frame = defaultFrame;
	_arrowLayer.contentsScale = [[UIScreen mainScreen] scale];
//	_arrowLayer.contentsGravity = kCAGravityCenter;
	_arrowLayer.contents = (id)[[UIImage imageNamed:@"ArrowViewArrow.png"] CGImage];
	_arrowLayer.opaque = NO;
	_arrowLayer.backgroundColor = [[UIColor clearColor] CGColor];
	
	[self.layer addSublayer:_arrowLayer];
	
	_glowRootLayer = [CALayer layer];
	_glowRootLayer.frame = defaultFrame;
	_glowRootLayer.contentsScale = [[UIScreen mainScreen] scale];
	_glowRootLayer.opaque = NO;
	_glowRootLayer.backgroundColor = [[UIColor clearColor] CGColor];
	
	CALayer *maskLayer = [CALayer layer];
	maskLayer.frame = CGRectMake(0, 0, theWidth, theHeight);
	maskLayer.contentsScale = [[UIScreen mainScreen] scale];
	maskLayer.contents = (id)[[UIImage imageNamed:@"ArrowViewMask.png"] CGImage];
	maskLayer.opaque = NO;
	maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
	
	_glowRootLayer.mask = maskLayer;
	
	_glowImageLayer = [CALayer layer];
	_glowImageLayer.frame = CGRectMake(0, 0, theWidth, 88.0);
	_glowImageLayer.contentsScale = [[UIScreen mainScreen] scale];
	_glowImageLayer.contents = (id)[[UIImage imageNamed:@"ArrowViewUntouchedGlow.png"] CGImage];
	_glowImageLayer.contentsGravity = kCAGravityCenter;
	_glowImageLayer.opaque = NO;
	_glowImageLayer.backgroundColor = [[UIColor clearColor] CGColor];
	_glowImageLayer.position = CGPointMake(0.0, 215.0);
	_glowImageLayer.anchorPoint = CGPointMake(0, 0);
	[_glowRootLayer addSublayer:_glowImageLayer];
	
	[self.layer addSublayer:_glowRootLayer];
}

- (void)startAnimating {
	if (_isAnimating == NO) {
		_isAnimating = YES;
		CABasicAnimation *glowAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
		glowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		glowAnimation.duration = 1.65;
		glowAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 215.0)];
		glowAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0, -65.0)];
		glowAnimation.repeatCount = CGFLOAT_MAX;
		_glowImageLayer.contents = (id)[[UIImage imageNamed:@"ArrowViewUntouchedGlow.png"] CGImage];
		_glowImageLayer.opacity = 1.0;
		[_glowImageLayer addAnimation:glowAnimation forKey:@"glowAnimation"];
	}
	
}

- (void)stopAnimating {
	if (_isAnimating == YES) {
		[_glowImageLayer removeAnimationForKey:@"glowAnimation"];
		_isAnimating = NO;
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self stopAnimating];
	_glowImageLayer.contents = (id)[[UIImage imageNamed:@"ArrowViewTouchedGlow.png"] CGImage];
	
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	touchPoint.y -= (self.bounds.size.height - 206.0) / 2 + 30;
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	_glowImageLayer.position = CGPointMake(0.0, touchPoint.y);
	[CATransaction commit];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	touchPoint.y -= (self.bounds.size.height - 206.0) / 2 + 30;
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	_glowImageLayer.position = CGPointMake(0.0, MAX(touchPoint.y, 0));
	[CATransaction commit];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	touchPoint.y -= (self.bounds.size.height - 206.0) / 2 + 31; //1 for the top stroke
	BOOL shouldTrigger = touchPoint.y <= 0;
	if (shouldTrigger && self.block != nil)
		self.block();
	_glowImageLayer.opacity = 0.0;
	CABasicAnimation *fadeAnimation = [self _fadeAnimation];
	if (!shouldTrigger)
		fadeAnimation.delegate = self;
	[_glowImageLayer addAnimation:fadeAnimation forKey:@"opacity"];
}

- (CABasicAnimation *)_fadeAnimation {
	CABasicAnimation *fadeAnimation = [CABasicAnimation animation];
	fadeAnimation.duration = 0.15;
	fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
	return fadeAnimation;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	_glowImageLayer.position = CGPointMake(0.0, 215.0);
	[self startAnimating];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)dealloc {
	self.block = nil;
    [super dealloc];
}


@end
