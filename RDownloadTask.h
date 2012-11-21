//
//  RDownloadTask.h
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RDownloadTaskStatusWaiting = 0,
    RDownloadTaskStatusPaused,
    RDownloadTaskStatusDownloading,
    RDownloadTaskStatusDownloaded,
    RDownloadTaskStatusFailed
} RDownloadTaskStatus;

@class RDownloadTask;
@protocol RDownloadTaskDelegate <NSObject>

@optional
- (void)downloadTask:(RDownloadTask *)downloadTask didChangeStatus:(RDownloadTaskStatus)status;
- (void)downloadTaskDidStart:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidReceiveData:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidPause:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidFinishDownload:(RDownloadTask *)downloadTask;
- (void)downloadTask:(RDownloadTask *)downloadTask didFailWithError:(NSError *)error;

@end

@class RDownloadOperation;

@interface RDownloadTask : NSObject <NSCoding, NSURLConnectionDataDelegate>

// Delegate
@property (nonatomic, retain) id<RDownloadTaskDelegate> delegate;
@property (nonatomic, assign) RDownloadOperation *operation;

// Connection
@property (nonatomic, strong) NSURLConnection *connection;

// Uid
@property (nonatomic, strong) NSString *uid;

// Request
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *cookie;

// Save
@property (nonatomic, strong) NSMutableData *cacheData;
@property (nonatomic, strong) NSString *savePath;
@property (nonatomic, assign) int64_t downloadedBytes;
@property (nonatomic, assign) int64_t totalBytes;

// Options
@property (nonatomic, assign) int64_t cacheSize; // Bytes

// Status
@property (nonatomic, assign) RDownloadTaskStatus status;
@property (nonatomic, readonly) float progress;

- (id)initWithURL:(NSURL *)url saveToPath:(NSString *)savePath;

@end

@interface RDownloadOperation : NSOperation

- (id)initWithDownloadTask:(RDownloadTask *)downloadTask;

@end
