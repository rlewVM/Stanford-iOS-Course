//
//  Region+CreateAndSort.h
//  TopPlaces
//
//  Created by Rachel Lew on 3/16/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Region.h"

@interface Region (CreateAndSort)

+ (Region *)createRegionFromPlaceInfo:(NSDictionary *)placeInfo inContext:(NSManagedObjectContext *)context;

@end
