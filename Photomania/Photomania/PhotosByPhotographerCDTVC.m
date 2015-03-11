//
//  PhotosByPhotographerCDTVC.m
//  Photomania
//
//  Created by Rachel Lew on 3/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PhotosByPhotographerCDTVC.h"
#import "Photo.h"

@implementation PhotosByPhotographerCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    
    [self setupFetchedResultsController];
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

@end
