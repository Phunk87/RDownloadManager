//
//  RDownloadManager.m
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import "RDownloadManager.h"
#import "RDownloadTask.m"

@interface RDownloadManager()

@property (nonatomic, strong) NSMutableArray *taskList;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation RDownloadManager

#pragma mark - Data storage

- (void)readTaskList
{
    
}

#pragma mark - Task control

- (void)addTask:(RDownloadTask *)task startImmediately:(BOOL)startImmediately
{
    [_taskList addObject:task];
    if (startImmediately) {
        [self pendTask:task];
    }
}

- (void)pendTask:(RDownloadTask *)task
{
    [_downloadQueue addOperation:task];
}

- (void)stopTask:(RDownloadTask *)task
{
    [task cancel];
}

- (void)removeTask:(RDownloadTask *)task
{
    [self stopTask:task];
    [_taskList removeObject:task];
}

#pragma mark - Getters & setters

- (NSUInteger)maxConcurrentDownloadTaskCount
{
    return self.downloadQueue.maxConcurrentOperationCount;
}

- (void)setMaxConcurrentDownloadTaskCount:(NSUInteger)maxConcurrentDownloadTaskCount
{
    self.downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloadTaskCount;
}

#pragma mark - Life cycle

static RDownloadManager *sharedRDownloadManager = nil;

+ (RDownloadManager *)shared
{
    if (!sharedRDownloadManager) {
        sharedRDownloadManager = [[RDownloadManager alloc] init];
    }
    return sharedRDownloadManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.taskList = [[[NSMutableArray alloc] init] autorelease];
        self.downloadQueue = [[[NSOperationQueue alloc] init] autorelease];
    }
    return self;
}

@end
