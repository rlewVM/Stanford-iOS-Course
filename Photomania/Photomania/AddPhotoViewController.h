//
//  AddPhotoViewController.h
//  Photomania
//
//  Created by Rachel Lew on 3/11/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photographer.h"
#import "Photo.h"

@interface AddPhotoViewController : UIViewController

@property (nonatomic, strong) Photographer *photographer;
@property (nonatomic, strong, readonly) Photo *addedPhoto;

@end
