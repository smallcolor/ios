//
//  CLIlluminatedArrowView.m
//  CloudApp
//
//  Created by Nick Paulson on 3/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "CLIlluminatedArrowView.h"
#import <QuartzCore/QuartzCore.h>

NSString *_untouchedGlowAnimationID = @"untouchedGlowAnimationID";
const CGFloat _touchOffset = 30.0;

static CGRect NPSizeCenteredInRect (CGRect encompassingRect, CGSize theSize) {
	CGRect retRect = CGRectZero;
	retRect.size = theSize;
	retRect.origin.x = (encompassingRect.size.width - theSize.width) / 2 + encompassingRect.origin.x;
	retRect.origin.y = (encompassingRect.size.height - theSize.height) / 2 + encompassingRect.origin.y;
	return retRect;
}

@interface CLIlluminatedArrowView ()
- (void)_doGlowAnimation;
- (CGRect)_arrowImageFrame;
@end

@implementation CLIlluminatedArrowView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame delegate:nil];
}

- (id)initWithFrame:(CGRect)frame delegate:(id)aDel {
    if ((self = [super initWithFrame:frame])) {
		
		self.delegate = aDel;
		
		_touchedGlow = [[UIImage imageNamed:@"ArrowViewTouchedGlow.png"] retain];
		_untouchedGlow = [[UIImage imageNamed:@"ArrowViewUntouchedGlow.png"] retain];
		
		UIImage *arrowImage = [UIImage imageNamed:@"ArrowViewArrow.png"];
        _arrowImageView = [[UIImageView alloc] initWithFrame:NPSizeCenteredInRect(self.bounds, arrowImage.size)];
		_arrowImageView.contentMode = UIViewContentModeCenter;
		_arrowImageView.image = arrowImage;
		[self addSubview:_arrowImageView];
		
		_tempView = [[UIView alloc] initWithFrame:self.bounds];
		CALayer *maskLayer = [CALayer layer];
		UIImage *maskImage = [UIImage imageNamed:@"ArrowViewMask.png"];
		maskLayer.contents = (id)[maskImage CGImage];
		maskLayer.name = @"arrowMask";
		maskLayer.contentsGravity = kCAGravityCenter;
		maskLayer.frame = self.bounds;
		_tempView.layer.mask = maskLayer;
		[self addSubview:_tempView];
		
		CGRect glowRect = CGRectMake(0, 0, _tempView.bounds.size.width, MAX(_touchedGlow.size.height, _untouchedGlow.size.height));
		_glowImageView = [[UIImageView alloc] initWithFrame:glowRect];
		_glowImageView.image = _untouchedGlow;
		_glowImageView.contentMode = UIViewContentModeTop;
		[_tempView addSubview:_glowImageView];
		[self _doGlowAnimation];
		
    }
    return self;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID isEqualToString:_untouchedGlowAnimationID] && !_isTouchDown && [finished boolValue]) {
		[self _doGlowAnimation];
	}
}

- (void)restartAnimation {
	[self _doGlowAnimation];
}

- (void)_doGlowAnimation {
	CGRect newRect = _glowImageView.frame;
	CGRect arrowRect = [self _arrowImageFrame];
	newRect.origin.y = arrowRect.origin.y + arrowRect.size.height;
	_glowImageView.frame = newRect;
	newRect.origin.y = arrowRect.origin.y - _glowImageView.bounds.size.height;
	[UIView beginAnimations:_untouchedGlowAnimationID context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	_glowImageView.frame = newRect;
	[UIView commitAnimations];
}

- (CGRect)_arrowImageFrame {
	return NPSizeCenteredInRect([self bounds], _arrowImageView.image.size);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchLoc = [[touches anyObject] locationInView:self];
	_isTouchDown = YES;
	[_glowImageView.layer removeAllAnimations];
	_glowImageView.image = _touchedGlow;
	
	
	CGRect oldRect = _glowImageView.frame;
	oldRect.origin.y = touchLoc.y - _touchOffset;
	_glowImageView.frame = oldRect;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchLoc = [[touches anyObject] locationInView:self];
	CGRect oldRect = _glowImageView.frame;
	oldRect.origin.y = MAX(touchLoc.y, [self _arrowImageFrame].origin.y) - _touchOffset;
	_glowImageView.frame = oldRect;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_isTouchDown = NO;
	_glowImageView.image = _untouchedGlow;
	CGPoint touchLoc = [[touches anyObject] locationInView:self];
	if (touchLoc.y - _touchOffset <= [self _arrowImageFrame].origin.y) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(arrowViewDidComplete:)])
			[self.delegate arrowViewDidComplete:self];
	}
	[self _doGlowAnimation];
}

- (void)dealloc {
	[_untouchedGlow release];
	[_touchedGlow release];
	[_arrowImageView release];
	[_glowImageView release];
	[_tempView release];
    [super dealloc];
}


@end
