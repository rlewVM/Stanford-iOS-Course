//
//  LocationPhotosTVC.m
//  TopPlaces
//
//  Created by Rachel Lew on 3/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "LocationPhotosTVC.h"
#import "ImageViewController.h"
#import "FlickrFetcher.h"

@implementation LocationPhotosTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(fetchPhotosForPlace) forControlEvents:UIControlEventValueChanged];
    [self fetchPhotosForPlace];
}

- (void)setLocationId:(id)locationId
{
    _locationId = locationId;
    [self fetchPhotosForPlace];
}

#define MAX_PHOTO_RESULTS 100
- (IBAction)fetchPhotosForPlace
{
    [self.refreshControl beginRefreshing];
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:self.locationId maxResults:MAX_PHOTO_RESULTS];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        if (jsonResults) {
            NSDictionary *photoListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
            NSLog(@"Response: %@", photoListResults);
            
            NSArray *photos = [photoListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                self.photos = photos;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }
    });
}

@end
