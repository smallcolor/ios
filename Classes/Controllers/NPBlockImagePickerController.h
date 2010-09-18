//
//  NPBlockImagePickerController.h
//  CloudApp
//
//  Created by Nick Paulson on 8/5/10.
//  Copyright 2010 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NPBlockImagePickerController : UIImagePickerController<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	void (^finishBlock)(NSDictionary *info);
	void (^cancelBlock)(void);
}

@property (nonatomic, copy, readwrite) void (^finishBlock)(NSDictionary *info);
@property (nonatomic, copy, readwrite) void (^cancelBlock)(void);

- (id)initWithFinishBlock:(void (^)(NSDictionary *info))theFinishBlock cancelBlock:(void (^)(void))theCancelBlock;

@end
