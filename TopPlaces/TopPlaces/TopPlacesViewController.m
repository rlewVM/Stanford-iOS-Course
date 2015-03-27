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
#import "Region.h"
#import "PhotoDatabaseAvailability.h"
#import <CoreData/CoreData.h>

@interface TopPlacesViewController ()

@end

@implementation TopPlacesViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.context = note.userInfo[PhotoDatabaseAvailabilityContext];
    }];
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Region"];
    request.predicate = nil;
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"popularityScore" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)] ];
    request.fetchLimit = 50;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

#pragma mark - UITableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Region Cell" forIndexPath:indexPath];
    
    Region *regionInfo = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    //Region *regionInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = regionInfo.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photographers at row %lu", regionInfo.popularityScore, indexPath.row];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]] && [segue.destinationViewController isKindOfClass:[LocationPhotosTVC class]]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        //Region *region = [self.fetchedResultsController objectAtIndexPath:path];
        Region *region = [self.fetchedResultsController.fetchedObjects objectAtIndex:path.row];
        LocationPhotosTVC *locationPhotosVC = (LocationPhotosTVC *)segue.destinationViewController;
        locationPhotosVC.title = region.name;
        locationPhotosVC.locationId = region.flickr_id;
    }
}

@end
