//
//  Photographer+Create.m
//  TopPlaces
//
//  Created by Rachel Lew on 3/16/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer *)photograhperWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    if ([name length]) {
        NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        fetchReq.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:fetchReq error:&error];
        
        if (!matches || error) {
            // handle error
        } else if ([matches count] > 0) {
            photographer = [matches firstObject];
        } else {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
            photographer.name = name;
        }
    }
    
    return photographer;
}

@end
