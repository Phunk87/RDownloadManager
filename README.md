# RDownloadManager

RDownloadManager is a lightweight multi-task downloader based on Foundation.framework.
RDownloadManager 是一个轻量的多任务下载框架, 基于 Foundation.framework.

## Usage 使用方法

### Create a task 创建一个任务
```
RDownloadTask *task = [[[RDownloadTask alloc] initWithURL:[NSURL URLWithString:@"http://somewebsite.com/somefile"] saveToPath:nil] autorelease];
task.delegate = self; // Use delegate
task.uid = @"123456"; // Set some uid
task.userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17"; // Use a user agent
task.cookie = @"some cookie"; // Use cookie
task.savePath = @"~/Downloads"; // Save it to "~/Downloads"
task.cacheSize = 16 * 1024 * 1024; // Set cache size to 16MB
```

### Control a task 对任务进行操作
```
RDownloadManager *sharedDownloadManager = [RDownloadManager shared];
[sharedDownloadManager addTask:task startImmediately:NO];
[sharedDownloadManager queueTask:task];
[sharedDownloadManager stopTask:task];
[sharedDownloadManager removeTask:task];
```

## License 许可

This code is distributed under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl.html).
代码使用 [GNU General Public License](http://www.gnu.org/licenses/gpl.html) 许可发布.

## Donate

You can support me in various ways: Cash donation, purchasing items on Amazon Wishlists, or just improve my code and send a pull request.
您可以通过多种方式支持我: 捐赠, 为我购买亚马逊心愿单上的物品, 或尽您所能改善我的代码并提交 pull request.

Via:
[Alipay | 支付宝](https://me.alipay.com/alexrezit)
[Amazon Wishlist | 亚马逊心愿单](http://www.amazon.cn/wishlist/P8YMPIX8QFTN/)

## RDownloadManager Class Reference


### Overview
RDownloadManager is the manager that controls all download task operations. 


### Tasks

#### Getting the Shared RDownloadManager Instance

```+ shared```

#### Perform an Operation to a RDownloadTask Instance

```- addTask:startImmediately:```

```- queueTask:```

```- stopTask:```

```- removeTask:```


### Properties

#### taskList

An array containing all the tasks.

```@property (nonatomic, strong) NSMutableArray *taskList```

##### Decalred In

```RDownloadManager.h```

#### maxConcurrentDownloadTaskCount

The max number of concurrent download tasks.

```@property (nonatomic, assign) NSUInteger maxConcurrentDownloadTaskCount```

##### Decalred In

```RDownloadManager.h```


### Class Methods

#### shared

Returns the shared RDownloadManager object.
```+ (RDownloadManager *)shared```

##### Return Value
The shared RDownloadManager object.

##### Declared In
```RDownloadManager.h```

### Instance Methods

#### addTask:startImmediately:

Add a task to list and queue it, if specified.

```- (void)addTask:(RDownloadTask *)task startImmediately:(BOOL)startImmediately```

##### Parameters

_task_
> The task to add.

_startImmediately_
> ```YES``` if the task should be start immediately, otherwise ```NO```. If you pass ```NO```, the task will be added to list but not to the queue. You can start it later by calling ```queueTask:```.

##### Decalred In
```RDownloadManager.h```

#### queueTask:

Add a task to operation queue.

```- (void)queueTask:(RDownloadTask *)task```

##### Parameters
_task_  
> The task to queue.

##### Decalred In
```RDownloadManager.h```

#### stopTask:

Stop a task.

```- (void)stopTask:(RDownloadTask *)task```

##### Parameters
_task_  
> The task to stop.

##### Special Considerations
This method only pause a task by cancel the operation. If you want to remove it, call ```removeTask:``` instead.

##### Decalred In
```RDownloadManager.h```

#### removeTask:

Remove a task, and delete the local file. If the task is executing, it will stop first, and then be removed.

```- (void)removeTask:(RDownloadTask *)task```

##### Parameters
_task_  
> The task to remove.

##### Decalred In
```RDownloadManager.h```

## RDownloadTask Class Reference


### Overview
RDownloadTask is a download task.

### Tasks

#### Initializing a RDownloadTask Object
```- (id)initWithURL:(NSURL *)url saveToPath:(NSString *)savePath```

### Properties

> Not finished.
