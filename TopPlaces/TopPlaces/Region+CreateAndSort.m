//
//  Region+CreateAndSort.m
//  TopPlaces
//
//  Created by Rachel Lew on 3/16/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Region+CreateAndSort.h"
#import "Photo.h"
#import "Photographer.h"
#import "FlickrFetcher.h"

@implementation Region (CreateAndSort)

+ (Region *)createRegionFromPlaceInfo:(NSDictionary *)placeInfo inContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    
    NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInfo];
    NSFetchRequest *regionFetch = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    regionFetch.predicate = [NSPredicate predicateWithFormat:@"name = %@", regionName];
    
    NSError *regionError;
    NSArray *regionMatches = [context executeFetchRequest:regionFetch error:&regionError];
    
    NSSet *photographers = nil;
    if (regionError || !regionMatches) {
        // Handle unable to query region table
        return nil;
    } else if ([regionMatches count]) {
        region = [regionMatches firstObject];
        photographers = region.photographers;
    } else {
        region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
        region.flickr_id = [placeInfo valueForKeyPath:@"place.region.place_id"];
        region.name = regionName;
        photographers = [NSSet new];
    }
    
    region.photographers = [self intersectPhotographersFromPhotosForPlace:[placeInfo valueForKeyPath:@"place.place_id"] withRegionPhotographers:photographers usingContext:context];
    NSNumber *numPhotographers = @([region.photographers count]);
    region.popularityScore = numPhotographers;
    return region;
}

+ (NSSet *)intersectPhotographersFromPhotosForPlace:(NSString *)placeId
                            withRegionPhotographers:(NSSet *)otherPhotographers
                                       usingContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *photosFetch = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    photosFetch.predicate = [NSPredicate predicateWithFormat:@"place_id = %@", placeId];
    
    NSError *photosError;
    NSArray *photoMatches = [context executeFetchRequest:photosFetch error:&photosError];
    
    NSMutableSet *photographers = [[NSMutableSet alloc] initWithSet:otherPhotographers];
    if (!photoMatches || photosError) {
        // Handle unable to query photo table
    } else if ([photoMatches count]) {
        for (Photo *photo in photoMatches) {
            Photographer *photographer = photo.whoTook;
            [photographers addObject:photographer];
        }
    } else {
        // Handle no photos for this region wtf where did you get this place id from then?
    }
    
    return photographers;
}

@end
