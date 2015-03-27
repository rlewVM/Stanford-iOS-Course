//
//  PhotosByPhotographerCDTVC.m
//  Photomania
//
//  Created by Rachel Lew on 3/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PhotosByPhotographerCDTVC.h"
#import "Photo.h"
#import "AddPhotoViewController.h"
#import "ImageViewChange.h"

@interface PhotosByPhotographerCDTVC ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarButtonItem;


@end

@implementation PhotosByPhotographerCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.photographer.photos count]) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    
    [self setupFetchedResultsController];
    [self updateBarButtonItems];
}

- (void)updateBarButtonItems
{
    if (self.addPhotoBarButtonItem) {
        NSMutableArray *rightBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (!rightBarButtonItems) {
            rightBarButtonItems = [NSMutableArray new];
        }
        NSInteger addPhotoBarButtonIndex = [rightBarButtonItems indexOfObject:self.addPhotoBarButtonItem];
        if (addPhotoBarButtonIndex == NSNotFound) {
            if ([self.photographer.isUser boolValue]) {
                [rightBarButtonItems addObject:self.addPhotoBarButtonItem];
            }
        } else {
            if (![self.photographer.isUser boolValue]) {
                [rightBarButtonItems removeObject:self.addPhotoBarButtonItem];
            }
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
}

- (void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.photographer.managedObjectContext;
    
    if (context)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"subtitle" ascending:YES selector:@selector(localizedStandardCompare:)]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AddPhotoViewController class]]) {
        AddPhotoViewController *addPhotoVC = (AddPhotoViewController *)segue.destinationViewController;
        if ([self.photographer.isUser boolValue]) {
            addPhotoVC.photographer = self.photographer;
        }
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (IBAction)doneAddingPhotoList:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass: [AddPhotoViewController class]]) {
        AddPhotoViewController *addPhotoVC = (AddPhotoViewController *)segue.sourceViewController;
        Photo *addedPhoto = addPhotoVC.addedPhoto;
        [addPhotoVC.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if (addedPhoto) {
                [self.tableView reloadData];
                NSIndexPath *path = [self.fetchedResultsController indexPathForObject:addedPhoto];
                if (path) {
                    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
                }
                
                NSDictionary *userInfo = @{ ImageViewChangeSelectedPhoto : addedPhoto };
                [[NSNotificationCenter defaultCenter] postNotificationName:AddImageNotification object:nil userInfo:userInfo];
            } else {
                NSLog(@"Unable to add photo. Found nil photo");
            }
        }];

    }
}

@end
