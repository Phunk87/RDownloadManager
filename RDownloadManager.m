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

#pragma mark - Task status

- (BOOL)hasTaskWithUID:(NSString *)uid
{
    for (RDownloadTask *task in self.taskList) {
        if ([task.uid isEqualToString:uid]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasDownloadedTaskWithUID:(NSString *)uid
{
    for (RDownloadTask *task in self.taskList) {
        if ([task.uid isEqualToString:uid]) {
            if (task.status == RDownloadTaskStatusDownloaded) {
                return YES;
            }
            return NO;
        }
    }
    return NO;
}

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
            [self queueTask:task];
        }
    }
}

- (void)saveTaskList
{
    NSString *pathForSaveFile = self.pathForSaveFile;
    NSMutableData *taskListData = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:taskListData] autorelease];
    NSArray *taskList = [_taskList copy];
    [archiver encodeObject:taskList forKey:kRDownloadManagerKeyTaskList];
    [taskList release];
    [archiver finishEncoding];
    [taskListData writeToFile:pathForSaveFile atomically:NO];
}

#pragma mark - Task control

- (void)addTask:(RDownloadTask *)task startImmediately:(BOOL)startImmediately
{
    [_taskList addObject:task];
    [self saveTaskList];
    if (startImmediately) {
        [self queueTask:task];
    }
}

- (void)queueTask:(RDownloadTask *)task
{
    task.status = RDownloadTaskStatusWaiting;
    RDownloadOperation *operation = [[[RDownloadOperation alloc] initWithDownloadTask:task] autorelease];
    [operation setCompletionBlock:^{
        [self saveTaskList];
    }];
    [_downloadQueue addOperation:operation];
}

- (void)stopTask:(RDownloadTask *)task
{
    if (task.status == RDownloadTaskStatusDownloading) {
        [task.operation cancel];
    }
}

- (void)removeTask:(RDownloadTask *)task
{
    [[NSFileManager defaultManager] removeItemAtPath:task.savePath error:NULL];
    [self stopTask:task];
    if (task.status == RDownloadTaskStatusDownloading) {
    }
    [_taskList removeObject:task];
    [self saveTaskList];
}

- (void)removeAllTasks
{
    [self.downloadQueue cancelAllOperations];
    for (RDownloadTask *task in self.taskList) {
        [[NSFileManager defaultManager] removeItemAtPath:task.savePath error:NULL];
    }
    [self.taskList removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:self.pathForSaveFile error:NULL];
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
