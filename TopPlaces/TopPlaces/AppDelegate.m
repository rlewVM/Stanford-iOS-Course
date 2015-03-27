//
//  AppDelegate.m
//  TopPlaces
//
//  Created by Rachel Lew on 3/3/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+FlickrHelper.h"
#import "Region+CreateAndSort.h"
#import "PhotoDatabaseAvailability.h"
#import <CoreData/CoreData.h>

@interface AppDelegate () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSManagedObjectContext *workingContext;
@property (nonatomic, strong) NSTimer *flickrForegroundFetcherTimer;
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (nonatomic, copy)  void(^flickrDownloadBackroundURLSessionCompletionHandler)();

@end

@implementation AppDelegate

#define FLICKR_FETCHER_INTERVAL (20*60)
#define FLICKR_PHOTO_FETCH @"Flickr Photo Fetch Download Session"
#define FLICKR_PLACE_FETCH @"Flickr Place Fetch Download Session"
#define FLICKR_FETCH_Q "Flickr Fetch"

- (void)setDocument:(UIManagedDocument *)document
{
    _document = document;
    
    // Perform foreground fetch to flickr at specified timer intervals
    [self.flickrForegroundFetcherTimer invalidate];
    self.flickrForegroundFetcherTimer = nil;
    if (self.document.managedObjectContext) {
        self.flickrForegroundFetcherTimer = [NSTimer scheduledTimerWithTimeInterval:FLICKR_FETCHER_INTERVAL
                                                                             target:self
                                                                           selector:@selector(startFlickrFetch)
                                                                           userInfo:nil
                                                                            repeats:YES];
        self.workingContext.parentContext = self.document.managedObjectContext;

    }
    
    // Setup background fetch
    [NSTimer scheduledTimerWithTimeInterval:FLICKR_FETCHER_INTERVAL target:self selector:@selector(startFlickrFetch) userInfo:nil repeats:YES];
    
    NSDictionary *userInfo = self.document.managedObjectContext ? @{ PhotoDatabaseAvailabilityContext : self.document.managedObjectContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (NSManagedObjectContext *)workingContext
{
    if (!_workingContext) {
        _workingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    }
    return _workingContext;
}

- (NSURLSession *)flickrDownloadSession
{
    // Create download session with separate thread
    if (!_flickrDownloadSession) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_PHOTO_FETCH];
            config.allowsCellularAccess = NO;
            // Creating a new download session that will be performed on another queue by virtue of setting the delegateQueue to nil
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        });
    }
    return _flickrDownloadSession;
}

- (void)startFlickrFetch
{
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_PHOTO_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

/**
 *  Initialize the database and kick of foreground fetches when the database is available
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr fileExistsAtPath:[self.document.fileURL path]]) {
        [self openDocumentAndStartFlickrFetch:self.document];
    } else {
        NSError *fileError;
        NSURL *dirPath = [fileMgr URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&fileError];
        NSURL *docFilePath = [dirPath URLByAppendingPathComponent:@"topRegionsData"];
        
        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:docFilePath];
        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                                   NSInferMappingModelAutomaticallyOption : @YES };
        document.persistentStoreOptions = options;
        document.modelConfiguration = @"Model";
        [document saveToURL:docFilePath forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self openDocumentAndStartFlickrFetch:document];
        }];
    }

    return YES;
}

- (void)openDocumentAndStartFlickrFetch:(UIManagedDocument *)document
{
    [document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            self.document = document;
            [self startFlickrFetch];
        } else {
            NSLog(@"Failed to open document and trigger flickr fetch.");
        }
    }];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.document.managedObjectContext) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_PHOTO_FETCH];
        config.allowsCellularAccess = NO;
        config.timeoutIntervalForRequest = 10;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            [self loadFlickrPhotosFromFile:location intoContext:self.workingContext andThenExecute:^{
                completionHandler(UIBackgroundFetchResultNewData);
            }];
        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.flickrDownloadBackroundURLSessionCompletionHandler = completionHandler;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile
{
    // Update database based on download results
    if ([downloadTask.taskDescription isEqualToString:FLICKR_PHOTO_FETCH]) {
        [self loadFlickrPhotosFromFile:localFile intoContext:self.workingContext andThenExecute:^{
            [self fetchPlaceInfoForPhotosFromContext:self.workingContext];
        }];
    } else if ([downloadTask.taskDescription isEqualToString:FLICKR_PLACE_FETCH]) {
        [self loadFlickrPlaceFromFile:localFile intoContext:self.workingContext andThenExecute:^{
            [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
                // Execute completion handler when finished downloading all places
                if (![downloadTasks count]) {
                    if (self.flickrDownloadBackroundURLSessionCompletionHandler) {
                        
                        void (^completionHandler)() = self.flickrDownloadBackroundURLSessionCompletionHandler;
                        self.flickrDownloadBackroundURLSessionCompletionHandler = nil;
                        if (completionHandler) {
                            completionHandler();
                        }
                    }
                }
            }];
        }];
    }
}

- (void)loadFlickrPhotosFromFile:(NSURL *)file intoContext:(NSManagedObjectContext *)context andThenExecute:(void(^)())whenDone
{
    if (context) {
        NSData *flickrData = [NSData dataWithContentsOfURL:file];
        NSError *jsonSerializationError;
        NSDictionary *flickrResults = [NSJSONSerialization JSONObjectWithData:flickrData options:0 error:&jsonSerializationError];
        NSArray *photos = [flickrResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        [context performBlock:^{
            // Load photos and photographers into db and then query for region info
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            if (whenDone) {
                whenDone();
            }
            NSError *error;
            [context save:&error];
            if (error) {
                NSLog(@"Error saving working context in region creation: %@", error);
            }
        }];
    } else {
        if (whenDone) {
            whenDone();
        }
    }
}

- (void)loadFlickrPlaceFromFile:(NSURL *)file intoContext:(NSManagedObjectContext *)context andThenExecute:(void(^)())whenDone
{
    if (context) {
        NSData *flickrData = [NSData dataWithContentsOfURL:file];
        NSError *jsonSerializationError;
        NSDictionary *flickrResults = [NSJSONSerialization JSONObjectWithData:flickrData options:0 error:&jsonSerializationError];
        
        [context performBlock:^{
            // Load places into db and determine top regions
            [Region createRegionFromPlaceInfo:flickrResults inContext:context];
            if (whenDone) {
                whenDone();
            }
            NSError *error;
            [context save:&error];
            if (error) {
                NSLog(@"Error saving working context in region creation: %@", error);
            }
        }];
    } else {
        if (whenDone) {
            whenDone();
        }
    }
}

- (void)fetchPlaceInfoForPhotosFromContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = nil;
    NSError *error;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    if (error || !photos) {
        // TODO: handle error
    } else {
        for (Photo *photo in photos) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:photo.place_id]];
            task.taskDescription = FLICKR_PLACE_FETCH;
            [task resume];
        }
    }
}

@end
