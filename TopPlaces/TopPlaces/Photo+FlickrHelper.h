//
//  Photo+FlickrHelper.h
//  TopPlaces
//
//  Created by Rachel Lew on 3/16/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photo.h"

@interface Photo (FlickrHelper)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
