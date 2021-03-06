//
//  Photographer+Create.m
//  Photomania
//
//  Created by Rachel Lew on 3/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer *)getMyUserInManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    fetchReq.predicate = [NSPredicate predicateWithFormat:@"isUser = YES"];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:fetchReq error:&error];
    
    if (!matches || error) {
        // handle error
    } else if ([matches count] > 0) {
        photographer = [matches firstObject];
    } else {
        photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
        photographer.name = @"My Photos";
        photographer.isUser = @YES;
    }
    
    return photographer;
}

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
            photographer.isUser = @NO;
        }
    }
    
    return photographer;
}

@end
