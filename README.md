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
task.cacheSize = 16 * 1024 * 1024; // Set cache size to 16MB (512KB as default)
```

### Control a task 对任务进行操作
```
RDownloadManager *sharedDownloadManager = [RDownloadManager shared];
sharedDownloadManager.maxConcurrentDownloadTaskCount = 5;
[sharedDownloadManager addTask:task startImmediately:NO];
[sharedDownloadManager queueTask:task];
[sharedDownloadManager stopTask:task];
[sharedDownloadManager removeTask:task];
```

### Delegate
```
- (void)downloadTask:(RDownloadTask *)downloadTask didChangeStatus:(RDownloadTaskStatus)status;
- (void)downloadTaskDidStart:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidReceiveData:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidPause:(RDownloadTask *)downloadTask;
- (void)downloadTaskDidFinishDownload:(RDownloadTask *)downloadTask;
- (void)downloadTask:(RDownloadTask *)downloadTask didFailWithError:(NSError *)error;
```

## License 许可

This code is distributed under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl.html).  
代码使用 [GNU General Public License](http://www.gnu.org/licenses/gpl.html) 许可发布.

## Donate 捐赠

You can support me in various ways: Cash donation, purchasing items on Amazon Wishlists, or just improve my code and send a pull request.  
您可以通过多种方式支持我: 捐赠, 为我购买亚马逊心愿单上的物品, 或尽您所能改善我的代码并提交 pull request.

Via:
* [Alipay | 支付宝](https://me.alipay.com/alexrezit)
* [Amazon Wishlist | 亚马逊心愿单](http://www.amazon.cn/wishlist/P8YMPIX8QFTN/)

## RDownloadManager Class Reference

No documentation. Use the source, Luke!

