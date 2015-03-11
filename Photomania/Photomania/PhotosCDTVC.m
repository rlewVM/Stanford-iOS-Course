//
//  PhotosCDTVC.m
//  Photomania
//
//  Created by Rachel Lew on 3/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "Photo.h"
#import "ImageViewController.h"
#import "ImageViewChange.h"

@interface PhotosCDTVC ()

@property (strong, nonatomic) ImageViewController *imageViewController;
@property (nonatomic, strong) id<NSObject> notificationObserver;

@end

@implementation PhotosCDTVC

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.imageViewController) {
        self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:ImageViewChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            Photo *photo = note.userInfo[ImageViewChangeSelectedPhoto];
            NSIndexPath *path = [self.fetchedResultsController indexPathForObject:photo];
            if (path && ![path isEqual:[self.tableView indexPathForSelectedRow]]) {
                [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:REUSE_ID];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    return cell;
}

- (ImageViewController *)imageViewController
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    }
    return ([detailVC isKindOfClass:[ImageViewController class]] ? detailVC : nil);
}

#pragma mark - Navigation
- (void)prepareViewController:(id)vc forSegue:(NSString *)segueID fromIndexPath:(NSIndexPath *)path
{
    if ([vc isKindOfClass:[ImageViewController class]] && (![segueID length] || [segueID isEqualToString:@"Display Photo"])) {
        ImageViewController *imageVC = (ImageViewController *)vc;
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:path];
        imageVC.imageURL = [NSURL URLWithString:photo.imageURL];
        imageVC.title = photo.title;
        [self postPhotoChangeNotification:[self.fetchedResultsController objectAtIndexPath:path]];
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
    if (self.imageViewController) {
        [self prepareViewController:self.imageViewController forSegue:nil fromIndexPath:indexPath];
    }
}

- (void)postPhotoChangeNotification:(Photo *) photo
{
    NSDictionary *userInfo = @{ ImageViewChangeSelectedPhoto : photo };
    [[NSNotificationCenter defaultCenter] postNotificationName:ImageViewChangeNotification object:self userInfo:userInfo];
}

@end
