//
//  RDownloadManager.m
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import "RDownloadManager.h"

#define kRDownloadManagerSaveFileName @"RDownloadManager.plist"
#define kRDownloadManagerKeyTaskList @"TASK_LIST"

@interface RDownloadManager()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

- (NSString *)pathForSaveFile;
- (void)readTaskList;
- (void)saveTaskList;

@end

@implementation RDownloadManager

#pragma mark - Data storage

- (NSString *)pathForSaveFile
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentPaths[0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:kRDownloadManagerSaveFileName];
    return filePath;
}

- (void)readTaskList
{
    [self.downloadQueue cancelAllOperations];
    [self.taskList removeAllObjects];
    NSString *pathForSaveFile = self.pathForSaveFile;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathForSaveFile]) {
        NSData *taskListData = [[[NSData alloc] initWithContentsOfFile:pathForSaveFile] autorelease];
        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:taskListData] autorelease];
        NSArray *taskList = [unarchiver decodeObjectForKey:kRDownloadManagerKeyTaskList];
        [unarchiver finishDecoding];
        [self.taskList addObjectsFromArray:taskList];
    }
    for (RDownloadTask *task in _taskList) {
        if (task.status != RDownloadTaskStatusDownloaded) {
            [_downloadQueue addOperation:task];
        }
    }
}

- (void)saveTaskList
{
    NSString *pathForSaveFile = self.pathForSaveFile;
    NSMutableData *taskListData = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:taskListData] autorelease];
    [archiver encodeObject:_taskList forKey:kRDownloadManagerKeyTaskList];
    [archiver finishEncoding];
    [taskListData writeToFile:pathForSaveFile atomically:NO];
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
    [[NSFileManager defaultManager] removeItemAtPath:task.savePath error:NULL];
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
        [sharedRDownloadManager readTaskList];
    }
    return sharedRDownloadManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.taskList = [[[NSMutableArray alloc] init] autorelease];
        self.downloadQueue = [[[NSOperationQueue alloc] init] autorelease];
        _downloadQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

@end
