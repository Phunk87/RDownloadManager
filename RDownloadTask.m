//
//  RDownloadTask.m
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import "RDownloadTask.h"

#define kRDownloadTaskDefaultCacheSize (4 * 1024 * 1024)
#define kRDownloadTaskDefaultDirectory @"RDownloads"
#define kRDownloadTaskDownloadingPathExtension @"downloading"

#define kRDownloadTaskKeyUID @"UID"
#define kRDownloadTaskKeyURL @"URL"
#define kRDownloadTaskKeyUserAgent @"USER_AGENT"
#define kRDownloadTaskKeyCookie @"COOKIE"
#define kRDownloadTaskKeySavePath @"SAVE_PATH"
#define kRDownloadTaskKeyDownloadedBytes @"DOWNLOADED_BYTES"
#define kRDownloadTaskKeyTotalBytes @"TOTAL_BYTES"
#define kRDownloadTaskKeyStatus @"STATUS"

@interface RDownloadTask()

@property (nonatomic, strong) NSMutableData *receivedData;

- (NSString *)defaultDirectory;
- (NSString *)defaultPath;
- (void)writeCacheToFile;
- (void)prepareDownload;
- (void)startDownload;
- (void)pauseDownload;

@end

@implementation RDownloadTask

#pragma mark - Status

- (float)progress
{
    if (_totalBytes) {
        return _downloadedBytes * 1.0f / _totalBytes;
    }
    return 0;
}

#pragma mark - Data control

- (NSString *)defaultDirectory
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentPaths[0];
    return [documentDirectory stringByAppendingPathComponent:kRDownloadTaskDefaultDirectory];
}

- (NSString *)defaultPath
{
    // Get last component and remove parameters
    NSString *urlString = self.url.absoluteString;
    NSUInteger dividerLoc = [urlString rangeOfString:@"?"].location;
    NSString *fileName = [[urlString substringToIndex:(dividerLoc==NSNotFound?urlString.length:dividerLoc)] lastPathComponent];
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
    if (!_cacheSize) {
        self.cacheSize = kRDownloadTaskDefaultCacheSize;
    }
    if (!_downloadedBytes) {
        if (!_savePath) {
            self.savePath = self.defaultPath;
        }
        NSString *downloadingPath = [_savePath stringByAppendingPathExtension:@"downloading"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_savePath] ||
            [fileManager fileExistsAtPath:downloadingPath]) {
            for (NSInteger i = 1; i; i++) {
                // Add a number before file extension
                NSString *newPath = [[NSString stringWithFormat:@"%@.%d", [_savePath stringByDeletingPathExtension], i] stringByAppendingPathExtension:_savePath.pathExtension];
                downloadingPath = [newPath stringByAppendingPathExtension:@"downloading"];
                if (![fileManager fileExistsAtPath:newPath] &&
                    ![fileManager fileExistsAtPath:downloadingPath]) {
                    break;
                }
            }
        }
        self.savePath = downloadingPath;
    }
    [[NSFileManager defaultManager] createFileAtPath:_savePath contents:nil attributes:nil];
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
    
    self.status = RDownloadTaskStatusDownloading;
    if ([self.delegate respondsToSelector:@selector(downloadTaskDidStart:)]) {
        [self.delegate downloadTaskDidStart:self];
    }
    
    while (!self.isFinished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)pauseDownload
{
    [self.connection cancel];
    [self writeCacheToFile];
    self.status = RDownloadTaskStatusPaused;
    if ([self.delegate respondsToSelector:@selector(downloadTaskDidPause:)]) {
        [self.delegate downloadTaskDidPause:self];
    }
}

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithURL:(NSURL *)url saveToPath:(NSString *)savePath
{
    self = [self init];
    if (self) {
        self.url = url;
        self.savePath = savePath;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_uid forKey:kRDownloadTaskKeyUID];
    [aCoder encodeObject:_url forKey:kRDownloadTaskKeyURL];
    [aCoder encodeObject:_userAgent forKey:kRDownloadTaskKeyUserAgent];
    [aCoder encodeObject:_cookie forKey:kRDownloadTaskKeyCookie];
    [aCoder encodeObject:_savePath forKey:kRDownloadTaskKeySavePath];
    [aCoder encodeInteger:_status forKey:kRDownloadTaskKeyStatus];
    if (_status == RDownloadTaskStatusPaused ||
        _status == RDownloadTaskStatusDownloading) {
        [aCoder encodeInt64:_downloadedBytes forKey:kRDownloadTaskKeyDownloadedBytes];
        [aCoder encodeInt64:_totalBytes forKey:kRDownloadTaskKeyTotalBytes];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        self.uid = [aDecoder decodeObjectForKey:kRDownloadTaskKeyUID];
        self.url = [aDecoder decodeObjectForKey:kRDownloadTaskKeyURL];
        self.userAgent = [aDecoder decodeObjectForKey:kRDownloadTaskKeyUserAgent];
        self.cookie = [aDecoder decodeObjectForKey:kRDownloadTaskKeyCookie];
        self.savePath = [aDecoder decodeObjectForKey:kRDownloadTaskKeySavePath];
        self.status = [aDecoder decodeIntegerForKey:kRDownloadTaskKeyStatus];
        if (_status == RDownloadTaskStatusPaused ||
            _status == RDownloadTaskStatusDownloading) {
            self.downloadedBytes = [aDecoder decodeInt64ForKey:kRDownloadTaskKeyDownloadedBytes];
            self.totalBytes = [aDecoder decodeInt64ForKey:kRDownloadTaskKeyTotalBytes];
        }
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
    return (_status == RDownloadTaskStatusPaused ||
            _status == RDownloadTaskStatusDownloaded ||
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
        if (!_totalBytes) {
            _totalBytes = [[[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Content-Length"] intValue];
        }
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
    self.status = RDownloadTaskStatusDownloading;
    self.downloadedBytes += data.length;
    if (_downloadedBytes >= _cacheSize) {
        [self writeCacheToFile];
    }
    if ([self.delegate respondsToSelector:@selector(downloadTaskDidReceiveData:)]) {
        [self.delegate downloadTaskDidReceiveData:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self writeCacheToFile];
    NSString *newPath = [_savePath stringByDeletingPathExtension];
    [[NSFileManager defaultManager] moveItemAtPath:_savePath toPath:newPath error:NULL];
    self.savePath = newPath;
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
