//
//  TopPlacesPhotoViewController.h
//  TopPlaces
//
//  Created by Rachel Lew on 3/3/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface TopPlacesViewController : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
