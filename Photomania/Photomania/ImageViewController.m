//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Rachel Lew on 3/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "ImageViewController.h"
#import "URLViewController.h"
#import "ImageViewChange.h"

@interface ImageViewController ()<UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    UISplitViewController *svc = self.splitViewController;
    if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation]) && svc) {
        self.navigationItem.leftBarButtonItem = svc.displayModeButtonItem;
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    if (![self.image isEqual:image]) {
        self.scrollView.zoomScale = 1.0;
        self.imageView.image = image;
        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        
        self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    }
    [self.spinner stopAnimating];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    scrollView.minimumZoomScale = 0.2;
    scrollView.maximumZoomScale = 2.0;
    scrollView.delegate = self;
    
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (UIImageView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setImageURL:(NSURL *)imageURL
{
    if (![_imageURL isEqual:imageURL]) {
        _imageURL = imageURL;
        [self startDownloadingImage];
    }
}

- (void)startDownloadingImage
{
    self.image = nil;
    
    if (self.imageURL) {
        [self.spinner startAnimating];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
              completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                  if (!error) {
                      if ([request.URL isEqual:self.imageURL]) {
                          UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              self.image = image;
                          });
                      }
                  }
              }];
        [task resume];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[URLViewController class]]) {
        URLViewController *urlVC = (URLViewController *)segue.destinationViewController;
        urlVC.url = self.imageURL;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show Image URL"]) {
        return (self.imageURL != nil);
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}
    
@end
