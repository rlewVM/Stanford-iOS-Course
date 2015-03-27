//
//  Photographer+Create.h
//  Photomania
//
//  Created by Rachel Lew on 3/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)getMyUserInManagedObjectContext:(NSManagedObjectContext *)context;

+ (Photographer *)photograhperWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
