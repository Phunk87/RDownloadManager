//
//  RDownloadTask.m
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import "RDownloadTask.h"

#define kRDownloadTaskDefaultCacheSize 128
#define kRDownloadTaskDefaultDirectory @"Downloads"

@interface RDownloadTask()

@property (nonatomic, strong) NSMutableData *receivedData;

- (NSString *)defaultDirectory;
- (NSString *)defaultPath;
- (void)writeCacheToFile;
- (void)prepareDownload;
- (void)startDownload;
- (void)pauseDownload;
- (void)cancelDownload;

@end

@implementation RDownloadTask

#pragma mark - Data control

- (NSString *)defaultDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:kRDownloadTaskDefaultDirectory];
}

- (NSString *)defaultPath
{
    // Get last component and remove parameters
    NSString *urlString = self.url.absoluteString;
    NSUInteger dividerLoc = [urlString rangeOfString:@"?"].location;
    NSString *fileName = [urlString.lastPathComponent substringToIndex:(dividerLoc==NSNotFound?urlString.length:dividerLoc)];
    return [self.defaultDirectory stringByAppendingString:fileName];
}

- (void)writeCacheToFile
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.savePath];
    if (!fileHandle) {
        [self.cacheData writeToFile:self.savePath atomically:NO];
    } else {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:_cacheData];
        [fileHandle closeFile];
    }
    self.cacheData.length = 0;
}

#pragma mark - Task management

- (void)prepareDownload
{
    if (!_savePath) {
        self.savePath = self.defaultPath;
    }
    if (!_cacheSize) {
        self.cacheSize = kRDownloadTaskDefaultCacheSize;
    }
}

- (void)startDownload
{
    [self prepareDownload];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:self.url
                                                                 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                             timeoutInterval:10] autorelease];
    request.HTTPMethod = @"GET";
    if (_userAgent) {
        [request addValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    }
    if (_cookie) {
        [request addValue:_cookie forHTTPHeaderField:@"Cookie"];
    }
    if (_downloadedBytes) {
        [request addValue:[NSString stringWithFormat:@"bytes=%lld", _downloadedBytes] forHTTPHeaderField:@"Range"];
    }
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];
    
    self.status = RDownloadTaskStatusPending;
}

- (void)pauseDownload
{
    [self.connection cancel];
    [self writeCacheToFile];
    self.status = RDownloadTaskStatusPaused;
}

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Concurrent operation override

- (void)start
{
    [self startDownload];
}

- (void)cancel
{
    [self pauseDownload];
}

- (BOOL)isReady
{
    return (_status == RDownloadTaskStatusPending);
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return (_status == RDownloadTaskStatusDownloading);
}

- (BOOL)isFinished
{
    return (_status == RDownloadTaskStatusDownloaded ||
            _status == RDownloadTaskStatusFailed);
}

#pragma mark - URL connection download delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode == 200) {
        if (!_cacheData) {
            self.cacheData = [NSMutableData data];
        }
        self.status = RDownloadTaskStatusDownloading;
    } else {
        self.status = RDownloadTaskStatusFailed;
        if ([self.delegate respondsToSelector:@selector(downloadTask:didFailWithError:)]) {
            [self.delegate downloadTask:self didFailWithError:NULL];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.cacheData appendData:data];
    self.downloadedBytes += data.length;
    if (_downloadedBytes >= _cacheSize) {
        [self writeCacheToFile];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self writeCacheToFile];
    self.status = RDownloadTaskStatusDownloaded;
    if ([self.delegate respondsToSelector:@selector(downloadTaskDidFinishDownload:)]) {
        [self.delegate downloadTaskDidFinishDownload:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.status = RDownloadTaskStatusFailed;
    if ([self.delegate respondsToSelector:@selector(downloadTask:didFailWithError:)]) {
        [self.delegate downloadTask:self didFailWithError:error];
    }
}

@end
