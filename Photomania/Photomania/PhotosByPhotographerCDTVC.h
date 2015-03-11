//
//  PhotosByPhotographerCDTVC.h
//  Photomania
//
//  Created by Rachel Lew on 3/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Photographer.h"
#import "PhotosCDTVC.h"

@interface PhotosByPhotographerCDTVC : PhotosCDTVC

@property (nonatomic, strong) Photographer *photographer;

@end
