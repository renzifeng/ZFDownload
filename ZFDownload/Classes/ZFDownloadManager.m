//
//  ZFDownloadManager.m
//  ZFDownload_Example
//
//  Created by 任子丰 on 2018/7/23.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFDownloadManager.h"
#import "ZFDataBaseManager.h"
#import "ZFReachabilityManager.h"
#import "NSURLSession+ZFCorrectResumeData.h"

@interface ZFDownloadManager ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

/// NSURLSession
@property (nonatomic, strong) NSURLSession *session;
/// 最大同时下载数量
@property (nonatomic, assign) NSInteger maxConcurrentCount;
/// 当前正在现在的个数
@property (nonatomic, assign) NSInteger currentDownloadingCount;
/// 开启下载任务的字典
@property (nonatomic, strong) NSMutableDictionary *downloadDictionary;

@end

@implementation ZFDownloadManager

+ (instancetype)shareManager {
    static ZFDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.downloadDictionary = [NSMutableDictionary dictionary];
        [[ZFReachabilityManager sharedManager] startMonitoring];
        // 单线程代理队列
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        
        // 后台下载标识
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"ZFDownloadBackgroundSessionIdentifier"];
        // 允许蜂窝网络下载，默认为YES，这里开启，我们添加了一个变量去控制用户切换选择
        configuration.allowsCellularAccess = YES;
        
        // 创建NSURLSession，配置信息、代理、代理线程
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
    }
    return self;
}

/**
 设置下载任务的个数，最多支持5个下载任务同时进行。
 */
- (void)setMaxTaskCount:(NSInteger)count {
    self.maxConcurrentCount = MAX(1, MIN(5, count));
}


/**
 开始/创建一个后台下载任务。开发者自己定义/扩展item中的数据和内容
 扩展item中的属性时，推荐自定义item，并且继承ZFDownloadItem
 示例：到demo -> YCDownloadInfo
 
 @param item 下载信息的item
 */
- (void)startDownloadWithItem:(ZFDownloadItem *)item {
    // 取出数据库中模型数据，如果不存在，添加到数据空中
    ZFDownloadItem *downnloadItem = [[ZFDataBaseManager shareManager] getItemWithUrl:item.url];
    if (!downnloadItem) {
        downnloadItem = item;
        [[ZFDataBaseManager shareManager] insertItem:downnloadItem];
    }
    downnloadItem.state = ZFDownloadStateWaiting;
    [[ZFDataBaseManager shareManager] updateWithItem:downnloadItem option:ZFDBUpdateOptionState | ZFDBUpdateOptionLastStateTime];
    if (self.currentDownloadingCount < self.maxConcurrentCount ) {
        [self startDownloadWithItem:item priority:0];
    }
}

/**
 开始/创建一个后台下载任务。开发者自己定义/扩展item中的数据和内容
 扩展item中的属性时，推荐自定义item，并且继承ZFDownloadItem
 示例：到demo -> ZFDownloadInfo
 
 @param item 下载信息的item
 @param priority 下载任务的task，默认：NSURLSessionTaskPriorityDefault 可选参数：NSURLSessionTaskPriorityLow  NSURLSessionTaskPriorityHigh NSURLSessionTaskPriorityDefault 范围：0.0-1.1
 */
- (void)startDownloadWithItem:(ZFDownloadItem *)item priority:(float)priority {
    item.state = ZFDownloadStateDownloading;
    [[ZFDataBaseManager shareManager] updateWithItem:item option:ZFDBUpdateOptionState];
    self.currentDownloadingCount++;
    
    NSURLSessionDownloadTask *downloadTask;
    if (item.resumeData) {
        CGFloat deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (deviceVersion >= 10.0 && deviceVersion < 10.2) {
            //  个别系统的下载 bug
            downloadTask = [self.session zf_downloadTaskWithCorrectResumeData:item.resumeData];
        }else {
            downloadTask = [self.session downloadTaskWithResumeData:item.resumeData];
        }
    } else {
        downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:item.url]];
    }
    downloadTask.taskDescription = item.url;
    downloadTask.priority = priority;
    [self.downloadDictionary setObject:downloadTask forKey:item.url];
    [downloadTask resume];
}

/**
 暂停下载任务
 
 @param item 创建的下载任务item
 */
- (void)pauseDownloadWithItem:(ZFDownloadItem *)item {
    ZFDownloadItem *pauseItem = [[ZFDataBaseManager shareManager] getItemWithUrl:item.url];
    [self cancelDownloadTaskWithItem:pauseItem delete:NO];
    item.state = ZFDownloadStatePaused;
    [[ZFDataBaseManager shareManager] updateWithItem:item option:ZFDBUpdateOptionState];
}

/**
 继续开始下载任务
 
 @param item 创建的下载任务item
 */
- (void)resumeDownloadWithItem:(ZFDownloadItem *)item {
    [self startDownloadWithItem:item];
}

/**
 删除下载任务，同时会删除当前任务下载的缓存数据
 
 @param item 创建的下载任务item
 */
- (void)stopDownloadWithItem:(ZFDownloadItem *)item {
    [self cancelDownloadTaskWithItem:item delete:YES];
}

/**
 暂停所有的下载
 */
- (void)pauseAllDownloadTask {
    //  获取所有正在下载的数据
    NSArray* downloadArray = [[ZFDataBaseManager shareManager] getAllDownloadingData];
    for (NSInteger i = 0; i < downloadArray.count; i++) {
        ZFDownloadItem *item = downloadArray[i];
        [self cancelDownloadTaskWithItem:item delete:NO];
        item.state = ZFDownloadStateWaiting;
        [[ZFDataBaseManager shareManager] updateWithItem:item option:ZFDBUpdateOptionState];
    }
}

/**
 开始所有的下载
 */
- (void)resumeAllDownloadTask {
    
}


/**
 清空所有的下载文件缓存，YCDownloadManager所管理的所有文件，不包括YCDownloadSession单独下载的文件
 */
- (void)removeAllCache {
    [[ZFDataBaseManager shareManager] deleteAllData];
}

/**
 获取所有的未完成的下载item
 */
- (NSArray *)unFinishList {
    return [[ZFDataBaseManager shareManager] getAllUnDownloadedData];
}

/**
 获取所有已完成的下载item
 */
- (NSArray *)finishList {
    return [[ZFDataBaseManager shareManager] getAllDownloadedData];
}


/**
 取消某一个下载任务

 @param item 取消下载任务的item
 @param delete 删除删除
 */
- (void)cancelDownloadTaskWithItem:(ZFDownloadItem *)item delete:(BOOL)delete {
    if (item.state == ZFDownloadStateDownloading) {
        NSURLSessionDownloadTask *downloadTask = [self.downloadDictionary objectForKey:item.url];
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            item.resumeData = resumeData;
            [[ZFDataBaseManager shareManager] updateWithItem:item option:ZFDBUpdateOptionResumeData];
            if (self.currentDownloadingCount) {
                self.currentDownloadingCount--;
            }
            //  开启下一个下载的任务
            [self startNextDownloadTask];
        }];
        if (delete) {
            [self.downloadDictionary removeObjectForKey:item.url];
            [[ZFDataBaseManager shareManager] deleteItemWithUrl:item.url];
        }
    }
}

- (void)startNextDownloadTask {
    if (self.currentDownloadingCount < self.maxConcurrentCount) {
        ZFDownloadItem *item = [[ZFDataBaseManager shareManager] getWaitingItem];
        if (item) {
            [self startDownloadWithItem:item];
            [self startNextDownloadTask];
        }
    }
}

/**
 获取所有下载数据所占用的磁盘空间,分为已经下载完成的和未下载完成的 Bytes，转化成返回为 MB 的形式
 */
- (NSString *)videoCacheSize {
    NSUInteger cacheSize = 0;
    NSArray *downFinish = [[ZFDataBaseManager shareManager] getAllDownloadedData];
    for (ZFDownloadItem *item in downFinish) {
        cacheSize += item.totalFileSize;
    }
    NSArray *unDownFinish = [[ZFDataBaseManager shareManager] getAllUnDownloadedData];
    for (ZFDownloadItem *item in unDownFinish) {
        cacheSize += item.tmpFileSize;
    }
    NSString *cacheSizeString = @"0KB";
    if (cacheSize) {
        NSByteCountFormatter *byteCountFormatter = [[NSByteCountFormatter alloc] init];
        byteCountFormatter.allowedUnits = NSByteCountFormatterUseMB;
        byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
        cacheSizeString = [byteCountFormatter stringFromByteCount:cacheSize];
    }
    return cacheSizeString;
}

#pragma mark - NSURLSessionDownloadDelegate

// 接收到服务器返回数据，会被调用多次
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  
    
    
    
    
    
    
}

// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  
    
    
    
    
    
    
}

#pragma mark - NSURLSessionTaskDelegate

// 请求完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  
}

#pragma mark - NSURLSessionDelegate

// 应用处于后台，所有下载任务完成及NSURLSession协议调用之后调用
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
   
}

/// 重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
}


@end
