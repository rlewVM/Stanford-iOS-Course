//
//  AddPhotoViewController.m
//  Photomania
//
//  Created by Rachel Lew on 3/11/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "AddPhotoViewController.h"
#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Photomania.h"

@interface AddPhotoViewController () <UITextFieldDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *subtitleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger locationErrorCode;
@property (strong, nonatomic, readwrite) Photo *addedPhoto;

@end

@implementation AddPhotoViewController

+ (BOOL)canAddPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            // Restricted is the only fatal error because the user can't control this (Denied can be changed)
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.image = [UIImage imageNamed:@"croppedMakeup.jpg"];
}

#pragma mark - Alerts

#define ALERT_CANT_ADD_PHOTO NSLocalizedStringFromTable(@"ALERT_CANT_ADD_PHOTO",  @"AddPhotoViewController", @"Message given to user if the user tries to add a photo but there is an unrecoverable problem")

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Unable to Add Photo" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles: @"Ok", nil] show];
}

- (void)fatalError:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Fatal Error" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancelButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![AddPhotoViewController canAddPhoto]) {
        // NOTE: this will always fatally error on a simulator because it doesn't have a camera
        [self fatalError:ALERT_CANT_ADD_PHOTO];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Not super necessary because it's modal and it will be released from the heap on closing the modal vc
    [self.locationManager stopUpdatingLocation];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    // Regenerate imageURL on changing image
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (NSURL *)uniqueDocumentsURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSLog(@"directory: %@", [documentDirectories firstObject]);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:uniqueFileName];
}

- (NSURL *)imageURL
{
   if (!_imageURL && self.image) {
       NSURL *url = [self uniqueDocumentsURL];
       NSLog(@"file: %@", url);
       if (url) {
           NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
           if ([imageData writeToURL:url atomically:YES]) {
               _imageURL = url;
           }
       }
    }
    return _imageURL;
}

- (NSURL *)thumbnailURL
{
    NSURL *url = [self.imageURL URLByAppendingPathComponent:@"thumbnail"];
    if (![_thumbnailURL isEqual:url]) {
        _thumbnailURL = nil;
        if (url) {
            UIImage *thumbnail = [self.image imageByScalingToSize:CGSizeMake(75, 75)];
            NSData *thumbData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if ([thumbData writeToURL:url atomically:YES]) {
                _thumbnailURL = url;
            }
        }
    }
    return _thumbnailURL;
}

#pragma mark - Location
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationErrorCode = error.code;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancelButton
{
    self.image = nil;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)takePhotoButton
{
}

#pragma mark - Navigation
#define UNWIND_SEGUE_IDENTIFIER @"Unwind from adding photo"
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        if (!self.image) {
            [self alert:@"No image to add!"];
            return NO;
        } else if (!self.titleTextField.text.length) {
            [self alert:@"Title required for image!"];
            return NO;
        } else if (!self.location) {
            switch (self.locationErrorCode) {
                case kCLErrorLocationUnknown :
                    [self alert:@"Unable to find current location (yet)."];
                    break;
                case kCLErrorDenied :
                    [self alert:@"Location services disabled under Privacy in Settings application."];
                    break;
                case kCLErrorNetwork :
                    [self alert:@"Unable to find current location. Please verify your network connection."];
                    break;
                default:
                    [self alert:@"Unable to find current location"];
            }
            return NO;
        } else {
            return YES;
        }
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UNWIND_SEGUE_IDENTIFIER]) {
        NSManagedObjectContext *context = self.photographer.managedObjectContext;
        if (context) {
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.title = self.titleTextField.text;
            photo.subtitle = self.subtitleTextField.text;
            photo.whoTook = self.photographer;
            photo.latitude = @(self.location.coordinate.latitude);
            photo.longitude = @(self.location.coordinate.longitude);
            photo.imageURL = [self.imageURL absoluteString];
            photo.thumbnailURL = [self.thumbnailURL absoluteString];
            self.addedPhoto = photo;
            
            // Ensuring that these files don't get deleted
            self.imageURL = nil;
            self.thumbnailURL = nil;
        }
    }
}

@end
