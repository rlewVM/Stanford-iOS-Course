//
//  FlickrFetcher.h
//  Shutterbug
//
//  Created by Rachel Lew on 3/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrAPIKey.h"

#define FLICKR_RESULTS_PHOTOS @"photos.photo"
#define FLICKR_RESULTS_PLACES @"places.place"

#define FLICKR_PHOTO_TITLE @"title"
#define FLICKR_PHOTO_DESCRIPTION @"description"
#define FLICKR_PHOTO_ID @"id"
#define FLICKR_PHOTO_OWNER @"ownername"
#define FLICKR_PHOTO_PLACE_NAME @"derived_place"

#define FLICKR_PLACE_NAME @"_content"
#define FLICKR_PLACE_ID @"place_id"

#define FLICKR_LATITUDE @"latitude"
#define FLICKR_LONGITUDE @"longitude"
#define FLICKR_TAGS @"tags"

typedef enum {
    FlickrPhotoFormatSquare = 1,    // thumbnail
    FlickrPhotoFormatLarge = 2,     // nomral size
    FlickrPhotoFormatOriginal = 64  // high resolution
} FlickrPhotoFormat;

@interface FlickrFetcher : NSObject

+ (NSURL *)URLForTopPlaces;

+ (NSURL *)URLForPhotosInPlace:(id)flickrPlaceId maxResults:(NSUInteger)maxResults;

+ (NSURL *)URLForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat) format;

+ (NSURL *)URLForRecentGeoreferencedPhotos;

@end
