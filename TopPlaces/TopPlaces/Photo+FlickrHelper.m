//
//  Photo+FlickrHelper.m
//  TopPlaces
//
//  Created by Rachel Lew on 3/16/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photo+FlickrHelper.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (FlickrHelper)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fetchReq.predicate = [NSPredicate predicateWithFormat:@"unique_id = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:fetchReq error:&error];
    
    if (!matches || error || [matches count] > 1) {
        // handle error
    } else if ([matches count]) {
        photo = [matches firstObject];
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique_id = unique;
        photo.place_id = [photoDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
        photo.title = [photoDictionary valueForKey:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        NSString *photographerName = [photoDictionary valueForKey:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photograhperWithName:photographerName inManagedObjectContext:context];
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fetchReq.propertiesToFetch = @[@"unique_id"];
    fetchReq.resultType = NSDictionaryResultType;
    NSError *error;
    NSArray *matches = [context executeFetchRequest:fetchReq error:&error];
    
    if (!matches || error) {
        // handle error
        return;
    }
    
    for (NSDictionary *photoDictionary in photos) {
        NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
        NSDictionary *dictionary = @{ @"unique_id" : unique };
        if (![matches containsObject:dictionary]) {
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.unique_id = unique;
            photo.place_id = [photoDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
            photo.title = [photoDictionary valueForKey:FLICKR_PHOTO_TITLE];
            photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
            photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
            photo.thumbURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
            
            NSString *photographerName = [photoDictionary valueForKey:FLICKR_PHOTO_OWNER];
            photo.whoTook = [Photographer photograhperWithName:photographerName inManagedObjectContext:context];
        }
    }
}

@end
