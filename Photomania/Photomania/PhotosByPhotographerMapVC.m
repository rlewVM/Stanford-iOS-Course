//
//  PhotosByPhotographerMapVC.m
//  Photomania
//
//  Created by Rachel Lew on 3/10/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PhotosByPhotographerMapVC.h"
#import "Photo+MKAnnotation.h"
#import "ImageViewController.h"
#import "ImageViewChange.h"
#import "AddPhotoViewController.h"

@interface PhotosByPhotographerMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarButtonItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *photosByPhotographer;
@property (nonatomic, strong) ImageViewController *imageViewController;
@property (nonatomic, strong) NSArray *notificationObservers;

@end

@implementation PhotosByPhotographerMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.notificationObservers =
        @[[[NSNotificationCenter defaultCenter] addObserverForName:ImageViewChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            Photo *photo = note.userInfo[ImageViewChangeSelectedPhoto];
            if (![self.mapView.selectedAnnotations containsObject:photo]) {
                [self.mapView selectAnnotation:photo animated:YES];
            }
        }],
          [[NSNotificationCenter defaultCenter] addObserverForName:AddImageNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
              Photo *photo = note.userInfo[ImageViewChangeSelectedPhoto];
              if (photo && ![self.mapView.annotations containsObject:photo]) {
                  [self.mapView addAnnotation:photo];
                  [self.mapView selectAnnotation:photo animated:YES];
              }
          }]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    for( id<NSObject> notificationObserver in self.notificationObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
    }
    self.notificationObservers = nil;
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations];
}

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    
    self.title = self.photographer.name;
    self.photosByPhotographer = nil;
    [self updateMapViewAnnotations];
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

- (NSArray *)photosByPhotographer
{
    if (!_photosByPhotographer) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"subtitle" ascending:YES selector:@selector(localizedStandardCompare:)]];
        _photosByPhotographer = [self.photographer.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _photosByPhotographer;
}

- (void)updateMapViewAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photosByPhotographer];
    [self.mapView showAnnotations:self.photosByPhotographer animated:YES];
    if (self.imageViewController) {
        Photo *autoselected = [self.photosByPhotographer firstObject];
        if (autoselected) {
            [self.mapView selectAnnotation:autoselected animated:YES];
            [self prepareViewController:self.imageViewController forSegue:nil fromAnnotation:autoselected];
        }
    }
}

#define ANNOTATION_VIEW_IDENTIFIER @"photoPin"
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:ANNOTATION_VIEW_IDENTIFIER];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ANNOTATION_VIEW_IDENTIFIER];
        annotationView.canShowCallout = YES;
        
        if (!self.imageViewController) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
            annotationView.leftCalloutAccessoryView = image;
            
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@">" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [button sizeToFit];
            annotationView.rightCalloutAccessoryView = button;
        }
    }
    annotationView.annotation = annotation;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    // Differentiate between iPad and iPhone implementation
    if (self.imageViewController) {
        if ([view.annotation isKindOfClass:[Photo class]]) {
            Photo *selectedPhoto = (Photo *)view.annotation;
            NSURL *photoURL = [NSURL URLWithString:selectedPhoto.imageURL];
            if (![self.imageViewController.imageURL isEqual:photoURL]) {
                self.imageViewController.imageURL = photoURL;
                self.imageViewController.title = selectedPhoto.title;
                [self postPhotoChangeNotification:selectedPhoto];
            }
        }
    } else {
        [self updateLeftCalloutAccessory:view];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // Segue from code example
    [self performSegueWithIdentifier:@"Show Photo" sender:view];
}

- (void)updateLeftCalloutAccessory:(MKAnnotationView *)annotationView
{
    UIImageView *image = nil;
    
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        image = (UIImageView *)annotationView.leftCalloutAccessoryView;
    }
    if (image) {
        Photo *photo = nil;
        if ([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo *)annotationView.annotation;
        }
        if (photo) {
            [self downloadImageThumb:photo forImageView:image];
        }
    }
}

- (void)downloadImageThumb:(Photo *)photo forImageView:(UIImageView *)imageView
{
    NSURL *thumbUrl = [NSURL URLWithString: photo.thumbnailURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:thumbUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:thumbUrl]) {
                    UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = downloadedImage;
                    });
                }
            }
        }];
    [task resume];
}

- (ImageViewController *)imageViewController
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isKindOfClass:[UINavigationController class]]) {
        detailVC = [((UINavigationController *)detailVC).viewControllers firstObject];
    }
    return ([detailVC isKindOfClass:[ImageViewController class]] ? detailVC : nil);
}

- (void)postPhotoChangeNotification:(Photo *)photo
{
    NSDictionary *userInfo = @{ ImageViewChangeSelectedPhoto : photo };
    [[NSNotificationCenter defaultCenter] postNotificationName:ImageViewChangeNotification object:self userInfo:userInfo];
}

#pragma mark - Navigation
- (void)prepareViewController:(id)vc forSegue:(NSString *)segueID fromAnnotation:(id<MKAnnotation>)annotation
{
    if ([vc isKindOfClass:[ImageViewController class]] && (![segueID length] || [segueID isEqualToString:@"Show Photo"])) {
        ImageViewController *imageVC = (ImageViewController *)vc;
        if ([annotation isKindOfClass:[Photo class]]) {
            Photo *photo = annotation;
            imageVC.imageURL = [NSURL URLWithString:photo.imageURL];
            imageVC.title = photo.title;
            [self postPhotoChangeNotification:photo];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AddPhotoViewController class]]) {
        AddPhotoViewController *addPhotoVC = (AddPhotoViewController *)segue.destinationViewController;
        if ([self.photographer.isUser boolValue]) {
            addPhotoVC.photographer = self.photographer;
        }
    }
    else if ([sender isKindOfClass:[MKAnnotationView class]]) {
        [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromAnnotation:((MKAnnotationView *)sender).annotation];
    }
}

- (IBAction)doneAddingPhoto:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass: [AddPhotoViewController class]]) {
        AddPhotoViewController *addPhotoVC = (AddPhotoViewController *)segue.sourceViewController;
        Photo *addedPhoto = addPhotoVC.addedPhoto;
        if (addedPhoto) {
            [self.mapView addAnnotation:addedPhoto];
            [self.mapView showAnnotations:@[addedPhoto] animated:YES];
            self.photosByPhotographer = nil;    // recalculate
            
            NSDictionary *userInfo = @{ ImageViewChangeSelectedPhoto : addedPhoto };
            [[NSNotificationCenter defaultCenter] postNotificationName:AddImageNotification object:nil userInfo:userInfo];
        } else {
            NSLog(@"Unable to add photo. Found nil photo");
        }
    }
}

@end
