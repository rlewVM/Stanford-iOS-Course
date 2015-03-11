//
//  PhotosByPhotographerImageVC.m
//  Photomania
//
//  Created by Rachel Lew on 3/10/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PhotosByPhotographerImageVC.h"
#import "PhotosByPhotographerMapVC.h"

@interface PhotosByPhotographerImageVC ()

@property (nonatomic, strong) PhotosByPhotographerMapVC *photosByPhotographerMapVC;

@end

@implementation PhotosByPhotographerImageVC

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    self.photosByPhotographerMapVC.photographer = self.photographer;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Embed segue
    if ([segue.destinationViewController isKindOfClass:[PhotosByPhotographerMapVC class]]) {
        PhotosByPhotographerMapVC *mapVC = (PhotosByPhotographerMapVC *)segue.destinationViewController;
        mapVC.photographer = self.photographer;
        self.photosByPhotographerMapVC = mapVC;
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end
