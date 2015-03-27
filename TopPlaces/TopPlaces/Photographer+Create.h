//
//  Photographer+Create.h
//  TopPlaces
//
//  Created by Rachel Lew on 3/16/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)photograhperWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
