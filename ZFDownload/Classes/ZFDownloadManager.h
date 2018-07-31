//
//  ZFDownloadManager.h
//  ZFDownload_Example
//
//  Created by 任子丰 on 2018/7/23.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFDownloadItem.h"

@interface ZFDownloadManager : NSObject

// 获取单例
+ (instancetype)shareManager;

/**
 设置下载任务的个数，最多支持5个下载任务同时进行。
 */
- (void)setMaxTaskCount:(NSInteger)count;

/**
 开始/创建一个后台下载任务。开发者自己定义/扩展item中的数据和内容
 扩展item中的属性时，推荐自定义item，并且继承ZFDownloadItem
 示例：到demo -> YCDownloadInfo
 
 @param item 下载信息的item
 */
- (void)startDownloadWithItem:(ZFDownloadItem *)item;

/**
 开始/创建一个后台下载任务。开发者自己定义/扩展item中的数据和内容
 扩展item中的属性时，推荐自定义item，并且继承ZFDownloadItem
 示例：到demo -> ZFDownloadInfo
 
 @param item 下载信息的item
 @param priority 下载任务的task，默认：NSURLSessionTaskPriorityDefault 可选参数：NSURLSessionTaskPriorityLow  NSURLSessionTaskPriorityHigh NSURLSessionTaskPriorityDefault 范围：0.0-1.1
 */
- (void)startDownloadWithItem:(ZFDownloadItem *)item priority:(float)priority;

/**
 暂停下载任务
 
 @param item 创建的下载任务item
 */
- (void)pauseDownloadWithItem:(ZFDownloadItem *)item;

/**
 继续开始下载任务
 
 @param item 创建的下载任务item
 */
- (void)resumeDownloadWithItem:(ZFDownloadItem *)item;

/**
 删除下载任务，同时会删除当前任务下载的缓存数据
 
 @param item 创建的下载任务item
 */
- (void)stopDownloadWithItem:(ZFDownloadItem *)item;

/**
 暂停所有的下载
 */
- (void)pauseAllDownloadTask;

/**
 开始所有的下载
 */
- (void)resumeAllDownloadTask;


/**
 清空所有的下载文件缓存，YCDownloadManager所管理的所有文件，不包括YCDownloadSession单独下载的文件
 */
- (void)removeAllCache;

/**
 获取所有的未完成的下载item
 */
- (NSArray *)unFinishList;

/**
 获取所有已完成的下载item
 */
- (NSArray *)finishList;


/**
 获取所有下载数据所占用的磁盘空间,包含下载完成与未完成的，单位为 MB
 */
- (NSString *)videoCacheSize;



@end
