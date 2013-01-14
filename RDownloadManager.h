//
//  RDownloadManager.h
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDownloadTask.h"

@interface RDownloadManager : NSObject

@property (nonatomic, strong) NSMutableArray *taskList;
@property (nonatomic, assign) NSUInteger maxConcurrentDownloadTaskCount;

+ (RDownloadManager *)sharedManager;
- (void)addTask:(RDownloadTask *)task startImmediately:(BOOL)startImmediately;
- (void)queueTask:(RDownloadTask *)task;
- (void)stopTask:(RDownloadTask *)task;
- (void)removeTask:(RDownloadTask *)task;
- (void)removeAllTasks;

- (BOOL)hasTaskWithUID:(NSString *)uid;
- (BOOL)hasDownloadedTaskWithUID:(NSString *)uid;

@end
