//
//  NPHUDView.m
//  CloudApp
//
//  Created by Nick Paulson on 3/4/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "NPHUDView.h"

const CGFloat NPHUDViewBorderMargin = 30.0;
const CGFloat NPHUDViewTextSeparator = 25.0;
const CGFloat NPHUDViewSideSize = 160.0;
#define NPHUDViewTextColor [UIColor whiteColor]
#define NPHUDViewFont [UIFont fontWithName:@"Helvetica-Bold" size:18]

static CGRect NPSizeCenteredInRect (CGRect encompassingRect, CGSize theSize) {
	CGRect retRect = CGRectZero;
	retRect.size = theSize;
	retRect.origin.x = (encompassingRect.size.width - theSize.width) / 2 + encompassingRect.origin.x;
	retRect.origin.y = (encompassingRect.size.height - theSize.height) / 2 + encompassingRect.origin.y;
	return retRect;
}

static void NPContextAddRoundedRect (CGContextRef theContext, CGRect theRect, CGFloat cornerRadius) {
	CGContextBeginPath(theContext);
	CGContextMoveToPoint(theContext, theRect.origin.x, theRect.origin.y + cornerRadius);
	CGContextAddArcToPoint(theContext, theRect.origin.x, theRect.origin.y, theRect.origin.x + cornerRadius, theRect.origin.y, cornerRadius);
	CGContextAddLineToPoint(theContext, theRect.origin.x + theRect.size.width - cornerRadius, theRect.origin.y);
	CGContextAddArcToPoint(theContext, theRect.origin.x + theRect.size.width, theRect.origin.y, theRect.origin.x + theRect.size.width, theRect.origin.y + cornerRadius, cornerRadius);
	CGContextAddLineToPoint(theContext, theRect.origin.x + theRect.size.width, theRect.origin.y + theRect.size.height - cornerRadius);
	CGContextAddArcToPoint(theContext, theRect.origin.x + theRect.size.width, theRect.origin.y + theRect.size.height, theRect.origin.x + theRect.size.width - cornerRadius, theRect.origin.y + theRect.size.height, cornerRadius);
	CGContextAddLineToPoint(theContext, theRect.origin.x + cornerRadius, theRect.origin.y + theRect.size.height);
	CGContextAddArcToPoint(theContext, theRect.origin.x, theRect.origin.y + theRect.size.height, theRect.origin.x, theRect.origin.y + theRect.size.height - cornerRadius, cornerRadius);
	CGContextAddLineToPoint(theContext, theRect.origin.x, theRect.origin.y + cornerRadius);
	CGContextClosePath(theContext);
}

@interface NPHUDView ()
- (void)_cleanupWindow;
@end

@implementation NPHUDView
@synthesize borderRadius, contentView, text, HUDColor, overlaysEntireScreen, delegate;

#pragma mark Initializers

- (id)initWithFrame:(CGRect)frame {
	return [self initWithContentView:nil text:nil];
}

- (id)initWithContentView:(UIView *)aView text:(NSString *)someText {
    if ((self = [super initWithFrame:CGRectZero])) {
		[self setBorderRadius:10.0];
		[self setContentView:aView];
		if ([aView superview] != self)
			[self addSubview:aView];
		[self setText:someText];
		[self setHUDColor:[[UIColor blackColor] colorWithAlphaComponent:0.50]];
		[self setOverlaysEntireScreen:YES];
		[self setOpaque:NO];
		
		self.autoresizesSubviews = NO;
		
	}
    return self;
}

- (id)initWithImage:(UIImage *)anImage text:(NSString *)someText {
	UIImageView *tempView = [[UIImageView alloc] initWithImage:anImage];
	[tempView setFrame:CGRectMake(0, 0, [anImage size].width, [anImage size].height)];
	self = [self initWithContentView:tempView text:someText];
	[tempView release];
	return self;
}

- (void)setImage:(UIImage *)anImage {
	UIImageView *tempView = [[UIImageView alloc] initWithImage:anImage];
	[tempView setFrame:CGRectMake(0, 0, [anImage size].width, [anImage size].height)];
	[self setContentView:tempView];
	[tempView release];
}

- (void)setContentView:(UIView *)newView {
	if ([contentView isEqual:newView])
		return;
	
	if (_blockingWindow != nil) {
		CGRect theFrame = ([self overlaysEntireScreen] ? [[UIScreen mainScreen] bounds] : [[UIScreen mainScreen] applicationFrame]);
		CGRect centerRect = NPSizeCenteredInRect(theFrame, CGSizeMake(NPHUDViewSideSize, NPHUDViewSideSize));
		CGRect tempFrameRect = [[self contentView] frame];
		tempFrameRect.origin.x = centerRect.origin.x + NPHUDViewBorderMargin + (centerRect.size.width - NPHUDViewBorderMargin * 2 - tempFrameRect.size.width) / 2;
		tempFrameRect.origin.y = centerRect.origin.y + NPHUDViewBorderMargin;
		[newView setFrame:CGRectInset(tempFrameRect, -50, -50)];
		
		[newView setAlpha:1.0];
		[[contentView superview] addSubview:newView];
		[contentView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.20];
		[contentView setAlpha:0.0];
		[newView setFrame:tempFrameRect];
		[UIView commitAnimations];
		
	}
	
	[newView retain];
	[contentView release];
	contentView = newView;
	
}

- (void)show {
	if (_blockingWindow != nil)
		return;
	CGRect theFrame = ([self overlaysEntireScreen] ? [[UIScreen mainScreen] bounds] : [[UIScreen mainScreen] applicationFrame]);
	_blockingWindow = [[UIWindow alloc] initWithFrame:theFrame];
	[_blockingWindow setWindowLevel:UIWindowLevelStatusBar];
	[_blockingWindow setBackgroundColor:[UIColor clearColor]];
	[_blockingWindow setAlpha:0.0];
	[self setFrame:CGRectInset(theFrame, -50, -50)];
	[_blockingWindow addSubview:self];
	
	CGRect centerRect = NPSizeCenteredInRect(theFrame, CGSizeMake(NPHUDViewSideSize, NPHUDViewSideSize));
	CGRect tempFrameRect = [[self contentView] frame];
	tempFrameRect.origin.x = centerRect.origin.x + NPHUDViewBorderMargin + (centerRect.size.width - NPHUDViewBorderMargin * 2 - tempFrameRect.size.width) / 2;
	tempFrameRect.origin.y = centerRect.origin.y + NPHUDViewBorderMargin;
	[[self contentView] setFrame:CGRectInset(tempFrameRect, -50, -50)];
	[_blockingWindow addSubview:contentView];
	
	[_blockingWindow makeKeyAndVisible];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.20];
	[_blockingWindow setAlpha:1.0];
	[self setFrame:theFrame];
	[[self contentView] setFrame:tempFrameRect];
	[UIView commitAnimations];
}

- (void)dismiss {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.20];
	[_blockingWindow setAlpha:0.0];
	[self setAlpha:0.0];
	[[self contentView] setAlpha:0.0];
	[UIView commitAnimations];
	[self performSelector:@selector(_cleanupWindow) withObject:nil afterDelay:0.2];
}

- (void)_cleanupWindow {
	[_blockingWindow resignKeyWindow];
	[_blockingWindow release];
	_blockingWindow = nil;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(theContext);
	
	CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 0.25);
	CGContextFillRect(theContext, [self overlaysEntireScreen] ? [[UIScreen mainScreen] bounds] : [[UIScreen mainScreen] applicationFrame]);
	
	CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 0.5);
	CGRect hudRect = NPSizeCenteredInRect([self overlaysEntireScreen] ? [[UIScreen mainScreen] bounds] : [[UIScreen mainScreen] applicationFrame], CGSizeMake(NPHUDViewSideSize, NPHUDViewSideSize));
	NPContextAddRoundedRect(theContext, hudRect, [self borderRadius]);
	CGContextFillPath(theContext);
	
	if ([self text] != nil && [[self text] length] > 0) {
		CGSize textSize = [[self text] sizeWithFont:NPHUDViewFont];
		
		[[UIColor whiteColor] set];
		CGSize shadowOffset = CGSizeMake(0, -1);
		CGFloat theColors[] = {0.0, 0.0, 0.0, 0.75};
		CGContextSetShadow(theContext, shadowOffset, 1);
		CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();
		CGColorRef shadowColor = CGColorCreate(theColorSpace, theColors);
		CGContextSetShadowWithColor(theContext, shadowOffset, 1, shadowColor);
		[[self text] drawInRect:CGRectMake(hudRect.origin.x, hudRect.origin.y + hudRect.size.height - NPHUDViewBorderMargin - textSize.height + 3, NPHUDViewSideSize, textSize.height) withFont:NPHUDViewFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
		CGColorRelease(shadowColor);
		CGColorSpaceRelease(theColorSpace);
	}
	CGContextRestoreGState(theContext);
}

- (void)setText:(NSString *)newText {
	if ([text isEqualToString:newText])
		return;
	[newText retain];
	[text release];
	text = newText;
	[self setNeedsDisplay];
}

- (void)dealloc {
	[_blockingWindow release];
	[self setContentView:nil];
	[self setText:nil];
	[self setHUDColor:nil];
    [super dealloc];
}


@end
