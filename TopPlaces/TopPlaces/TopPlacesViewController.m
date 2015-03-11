//
//  TopPlacesPhotoViewController.m
//  TopPlaces
//
//  Created by Rachel Lew on 3/3/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "TopPlacesViewController.h"
#import "FlickrFetcher.h"
#import "LocationPhotosTVC.h"

@interface TopPlacesViewController ()

@property (nonatomic, strong) NSArray *countries;
@property (nonatomic, strong) NSDictionary *citiesByCountry;

@end

@implementation TopPlacesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(fetchPlaces) forControlEvents:UIControlEventValueChanged];
    [self fetchPlaces];
}

#pragma mark - Setters and Getters
- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self initializeCountryListAndMappingWithPlaces:places];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.citiesByCountry valueForKey:self.countries[section]] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrPhotoCell" forIndexPath:indexPath];
    
    NSDictionary *photoInfo = [self.citiesByCountry valueForKey:self.countries[indexPath.section]][indexPath.row];
    cell.textLabel.text = [photoInfo valueForKeyPath:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photoInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.countries[section];
}

- (IBAction)fetchPlaces
{
    [self.refreshControl beginRefreshing];
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        if (jsonResults) {
            NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
            NSLog(@"Response: %@", propertyListResults);
            
            NSArray *places = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self initializeCountryListAndMappingWithPlaces:places];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }
    });
}

#pragma mark - Helper Methods
- (void)initializeCountryListAndMappingWithPlaces:(NSArray *)places
{
    NSMutableArray *countries = [NSMutableArray new];
    NSMutableDictionary *citiesByCountry = [NSMutableDictionary new];
    for (NSDictionary *place in places) {
        NSString *countryName = [FlickrFetcher extractCountryNameFromPlaceInformation:place];
        // Add a country to the list if it is not present
        if (![countries containsObject:countryName]) {
            [countries addObject:countryName];
            [citiesByCountry setValue:[NSMutableArray new] forKey:countryName];
        }
        // Add a city to the map of cities by country
        [[citiesByCountry valueForKey:countryName] addObject:place];
    }
    
    NSComparisonResult (^comparePlacesByName)(NSDictionary *obj1, NSDictionary *obj2) = ^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        if (obj1 && !obj2) {
            return NSOrderedAscending;
        } else if (!obj1 && obj2) {
            return NSOrderedDescending;
        } else if (!obj1 && !obj2) {
            return NSOrderedSame;
        }
        
        return [[FlickrFetcher extractNameOfPlace:[obj1 valueForKeyPath:FLICKR_PLACE_ID] fromPlaceInformation:obj1] compare:[FlickrFetcher extractNameOfPlace:[obj2 valueForKeyPath:FLICKR_PLACE_ID] fromPlaceInformation:obj2] options:0];
    };
    
    // Sort countries alphabetically
    [countries sortUsingSelector:@selector(compare:)];
    
    // Sort cities alphabetically
    for (NSString *country in countries) {
        [citiesByCountry[country] sortUsingComparator:comparePlacesByName];
    }
    
    self.countries = countries;
    self.citiesByCountry = citiesByCountry;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]] && [segue.destinationViewController isKindOfClass:[LocationPhotosTVC class]]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        LocationPhotosTVC *locationPhotosVC = (LocationPhotosTVC *)segue.destinationViewController;
        locationPhotosVC.title = cell.textLabel.text;
        
        locationPhotosVC.locationId = cell.textLabel.text;
    }
}

@end
