//
//  FlickrPhotoViewController.m
//  Shutterbug
//
//  Created by Rachel Lew on 3/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface FlickrPhotoViewController ()

@end

@implementation FlickrPhotoViewController

#pragma mark - Setters and Getters
- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrPhotoCell" forIndexPath:indexPath];
    
    NSDictionary *photoInfo = self.photos[indexPath.row];
    cell.textLabel.text = [photoInfo valueForKeyPath:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photoInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVC = self.splitViewController.viewControllers[1];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *) detailVC).viewControllers firstObject];
        [self prepareImageViewController:detailVC toDisplayPhoto:self.photos[indexPath.row]];
    }
}

#pragma mark - Navigation

- (void)prepareImageViewController:(ImageViewController *)imageVC toDisplayPhoto:(NSDictionary *)photo
{
    imageVC.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    imageVC.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath && [segue.identifier isEqualToString:@"DisplayPhoto"] && [segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
            [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.photos[indexPath.row]];
        }
    }
}

@end
