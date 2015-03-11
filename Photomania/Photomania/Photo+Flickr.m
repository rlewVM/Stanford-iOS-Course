//
//  Photo+Flickr.m
//  Photomania
//
//  Created by Rachel Lew on 3/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (Flickr)

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
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.latitude = @([[photoDictionary valueForKeyPath:FLICKR_LATITUDE] doubleValue]);
        photo.longitude = @([[photoDictionary valueForKeyPath:FLICKR_LONGITUDE] doubleValue]);
        photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photograhperWithName:photographerName inManagedObjectContext:context];
    }
    
    return photo;
}

// NOTE: this is really inefficient --> should minimize calls to db (check for ids in db already) and do bulk fetch from flickr
+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSMutableDictionary *owners = [NSMutableDictionary new];
    NSLog(@"photos from flickr: %@", photos);
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
        NSLog(@"photo: %@", photo);
        NSString *photographerName = [photo valueForKeyPath:FLICKR_PHOTO_OWNER];
        NSUInteger count = [[owners valueForKey:photographerName] integerValue];
        if (count) {
            [owners setValue:@(count + 1) forKey:photographerName];
        } else {
            [owners setValue:@1 forKey:photographerName];
        }
    }
    
    for (NSString *key in owners) {
        NSLog(@"photographer: %@ - %d photos", key, (int)[[owners valueForKey:key] integerValue]);
    }
}

@end
