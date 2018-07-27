//
//  ZFDownloadManager.m
//  ZFDownload_Example
//
//  Created by 任子丰 on 2018/7/23.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFDownloadManager.h"
#import "ZFDataBaseManager.h"

@interface ZFDownloadManager ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>
/// NSURLSession
@property (nonatomic, strong) NSURLSession *session;
/// 最大同时下载数量
@property (nonatomic, assign) NSInteger maxConcurrentCount;

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
    self = [super init];
    if (self) {
        // 单线程代理队列
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        
        // 后台下载标识
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"ZFDownloadBackgroundSessionIdentifier"];
        // 允许蜂窝网络下载，默认为YES，这里开启，我们添加了一个变量去控制用户切换选择
        configuration.allowsCellularAccess = YES;
        
        // 创建NSURLSession，配置信息、代理、代理线程
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
        
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
    ZFDownloadItem *downnloadItem = [[ZFDataBaseManager shareManager] getIteamWithUrl:item.url];
    if (!downnloadItem) {
        downnloadItem = item;
        [[ZFDataBaseManager shareManager] insertItem:downnloadItem];
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
    
}

/**
 暂停下载任务
 
 @param item 创建的下载任务item
 */
- (void)pauseDownloadWithItem:(ZFDownloadItem *)item {
    
}

/**
 继续开始下载任务
 
 @param item 创建的下载任务item
 */
- (void)resumeDownloadWithItem:(ZFDownloadItem *)item {
    
}

/**
 删除下载任务，同时会删除当前任务下载的缓存数据
 
 @param item 创建的下载任务item
 */
- (void)stopDownloadWithItem:(ZFDownloadItem *)item {
    
}

/**
 暂停所有的下载
 */
- (void)pauseAllDownloadTask {
    
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
    
}

/**
 获取所有的未完成的下载item
 */
- (NSArray *)downloadList {
    return nil;
}

/**
 获取所有已完成的下载item
 */
- (NSArray *)finishList {
    return nil;
}


/**
 获取所有下载数据所占用的磁盘空间
 */
- (NSUInteger)videoCacheSize {
    return 0;
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
