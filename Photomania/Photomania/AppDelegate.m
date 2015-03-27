
//
//  AppDelegate.m
//  Photomania
//
//  Created by Rachel Lew on 3/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>

@property (copy, nonatomic) void (^flickrDownloadBackroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetcherTimer;
@property (strong, nonatomic) UIManagedDocument *photoDB;

#define FLICKR_FETCH @"Flicker Just Uploaded Fetch"
#define FOREGROUND_FLICKR_FETCH_INTERVAL 20*60;
#define BACKGROUND_FLICKR_FETCH_INTERVAL 10;

@end

@implementation AppDelegate

// Posting to the "radio station" to notify the view controller of changes to the context
- (void)setPhotoDB:(UIManagedDocument *)photoDB
{
    _photoDB = photoDB;
    
    [self.flickrForegroundFetcherTimer invalidate];
    self.flickrForegroundFetcherTimer = nil;
    
    if (self.photoDB.managedObjectContext) {
        self.flickrForegroundFetcherTimer = [NSTimer scheduledTimerWithTimeInterval:(20*60)
                                                                             target:self
                                                                           selector:@selector(startFlickrFetch:)
                                                                           userInfo:nil
                                                                            repeats:YES];
    }

    [NSTimer scheduledTimerWithTimeInterval:20*60 target:self selector:@selector(startFlickrFetch) userInfo:nil repeats:YES];
    
    NSDictionary *userInfo = self.photoDB.managedObjectContext ? @{ PhotoDatabaseAvailabilityContext : self.photoDB.managedObjectContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)startFlickrFetch:(NSTimer *)timer
{
    [self startFlickrFetch];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.photoDB.managedObjectContext) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.allowsCellularAccess = NO;
        config.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_INTERVAL;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
            if (error) {
                completionHandler(UIBackgroundFetchResultNoData);
            } else
            {
                [self loadFlickrPhotosFromLocalURL:localFile intoContext:self.photoDB.managedObjectContext andThenExecuteBlock:^{
                    completionHandler(UIBackgroundFetchResultNewData);
                }];
            }
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSFileManager *defaultMgr = [NSFileManager defaultManager];
    NSError *error = nil;
    NSURL *filePath = [defaultMgr URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    NSURL *fileUrl = [filePath URLByAppendingPathComponent:@"photomaniaData"];

    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:fileUrl];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES                            };
    document.persistentStoreOptions = options;
    document.modelConfiguration = @"Photomania";
    
    if ([defaultMgr fileExistsAtPath:[document.fileURL path]]) {
        [self openDocument:document];
    } else {
        // create file
        [document saveToURL:fileUrl forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [self openDocument:document];
            } else {
                NSLog(@"Failed to create new document");
            }
        }];
    }
    return YES;
}

- (void)openDocument:(UIManagedDocument *)document
{
    [document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            // trigger photo fetching with managed context
            self.photoDB = document;
            [self startFlickrFetch];
        } else {
            NSLog(@"Failed to open document %@", document.fileURL);
        }
    }];
}

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void(^)())whenDone
{
    if (context) {
        NSArray *photos = [self flickrPhotosAtURL:localFile];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            if (whenDone) whenDone();
        }];
    } else {
        if (whenDone) whenDone();
    }
}

- (void)startFlickrFetch
{
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

- (NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH];
            urlSessionConfig.allowsCellularAccess = NO;
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
        });
    }
    return _flickrDownloadSession;
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    NSDictionary *flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData options:0 error:NULL];
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localFile
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadFlickrPhotosFromLocalURL:localFile intoContext:self.photoDB.managedObjectContext andThenExecuteBlock:^{
            [self flickrDownloadTasksMightBeComplete];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
}

- (void)flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.flickrDownloadBackroundURLSessionCompletionHandler;
                // manually release it because you have a copy of it
                self.flickrDownloadBackroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}


@end
