//
//  UIImage+Photomania.h
//  Photomania
//
//  Created by Rachel Lew on 3/12/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Photomania)

- (UIImage *)imageByScalingToSize:(CGSize)size;

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
