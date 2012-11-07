//
//  RDownloadManager.h
//  VMovier
//
//  Created by Alex Rezit on 06/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDownloadTask;

@interface RDownloadManager : NSObject

@property (nonatomic, assign) NSUInteger maxConcurrentDownloadTaskCount;

+ (RDownloadManager *)shared;
- (void)addTask:(RDownloadTask *)task startImmediately:(BOOL)startImmediately;
- (void)pendTask:(RDownloadTask *)task;
- (void)stopTask:(RDownloadTask *)task;
- (void)removeTask:(RDownloadTask *)task;

@end
