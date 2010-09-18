//
//  UIImage+NPResizing.h
//  CloudApp
//
//  Created by Nick Paulson on 3/12/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (NPResizing)

- (UIImage *)imageByScalingAspectToFitToSize:(CGSize)theSize;

@end
