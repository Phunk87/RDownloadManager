//
//  RDownloadTask.h
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDownloadTask;
@protocol RDownloadTaskDelegate <NSObject>

@optional
- (void)downloadTaskDidStart:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidPause:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidFinishDownload:(RDownloadTask *)downloadTask;
- (void)downloadTask:(RDownloadTask *)downloadTask didFailWithError:(NSError *)error;

@end

@interface RDownloadTask : NSOperation <NSCoding, NSURLConnectionDataDelegate>

typedef enum {
    RDownloadTaskStatusDefault = 0,
    RDownloadTaskStatusPaused,
    RDownloadTaskStatusPending,
    RDownloadTaskStatusDownloading,
    RDownloadTaskStatusDownloaded,
    RDownloadTaskStatusFailed
} RDownloadTaskStatus;

// Delegate
@property (assign) id<RDownloadTaskDelegate> delegate;

// Connection
@property (strong) NSURLConnection *connection;

// Uid
@property (strong) NSString *uid;

// Request
@property (strong) NSURL *url;
@property (strong) NSString *userAgent;
@property (strong) NSString *cookie;

// Save
@property (strong) NSMutableData *cacheData;
@property (strong) NSString *savePath;
@property (assign) int64_t downloadedBytes;
@property (assign) int64_t totalBytes;

// Options
@property (assign) int64_t cacheSize; // Bytes

// Status
@property (assign) RDownloadTaskStatus status;
@property (readonly) float progress;

- (id)initWithURL:(NSURL *)url saveToPath:(NSString *)savePath;

@end
