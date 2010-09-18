//
//  UIImage+NPResizing.m
//  CloudApp
//
//  Created by Nick Paulson on 3/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import "UIImage+NPResizing.h"


@implementation UIImage (NPResizing)

- (UIImage *)imageByScalingAspectToFitToSize:(CGSize)theSize {
	if (CGSizeEqualToSize(theSize, self.size))
		return [[self retain] autorelease];
	CGFloat widthScale = theSize.width / self.size.width;
	CGFloat heightScale = theSize.height / self.size.height;
	CGFloat scaleMulitiplier = MIN(widthScale, heightScale);
	CGPoint drawPoint = CGPointZero;
	if (widthScale > heightScale)
		drawPoint.x = (theSize.width - self.size.width * scaleMulitiplier) / 2;
	else if (heightScale > widthScale)
		drawPoint.y = (theSize.height - self.size.height * scaleMulitiplier) / 2;
	UIGraphicsBeginImageContext(theSize);
	[self drawInRect:CGRectMake(drawPoint.x, drawPoint.y, self.size.width * scaleMulitiplier, self.size.height * scaleMulitiplier)];
	UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	return resultImage;
}

@end
