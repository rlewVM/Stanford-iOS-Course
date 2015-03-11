//
//  PhotographersCDTVC.m
//  Photomania
//
//  Created by Rachel Lew on 3/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PhotographersCDTVC.h"
#import "Photographer.h"
#import "PhotoDatabaseAvailability.h"
#import "PhotosByPhotographerCDTVC.h"
#import "PhotosByPhotographerMapVC.h"
#import "PhotosByPhotographerImageVC.h"

@interface PhotographersCDTVC ()

@end

@implementation PhotographersCDTVC

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.context = note.userInfo[PhotoDatabaseAvailabilityContext];
    }];
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    fetchReq.predicate = nil;
    fetchReq.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchReq managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photographer Cell"];
    
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu photos", (unsigned long)[photographer.photos count]];
    
    return cell;
}

#pragma mark - Navigation
- (void)prepareViewController:(id)vc forSegue:(NSString *)segueID fromIndexPath:(NSIndexPath *)path
{
    if ([vc isKindOfClass:[PhotosByPhotographerCDTVC class]] && (![segueID length] || [segueID isEqualToString:@"Show Photos for Photographer"])) {
        PhotosByPhotographerCDTVC *photos = (PhotosByPhotographerCDTVC *)vc;
        photos.photographer = [self.fetchedResultsController objectAtIndexPath:path];
    } else if ([vc isKindOfClass:[PhotosByPhotographerMapVC class]]) {
        PhotosByPhotographerMapVC *mapPhotos = (PhotosByPhotographerMapVC *)vc;
        mapPhotos.photographer = [self.fetchedResultsController objectAtIndexPath:path];
    } else if ([vc isKindOfClass:[PhotosByPhotographerImageVC class]]) {
        PhotosByPhotographerImageVC *imageVC = (PhotosByPhotographerImageVC *)vc;
        imageVC.photographer = [self.fetchedResultsController objectAtIndexPath:path];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        path = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromIndexPath:path];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
        [self prepareViewController:detailVC forSegue:nil fromIndexPath:indexPath];
    }
}

@end
