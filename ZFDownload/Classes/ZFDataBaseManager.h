//
//  ZFDataBaseManager.h
//  ZFDownload_Example
//
//  Created by 任子丰 on 2018/7/23.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFDownloadItem.h"

typedef NS_ENUM(NSInteger, ZFDBGetDateOption) {
    ZFDBGetDateOptionAllCacheData = 0,      // 所有缓存数据
    ZFDBGetDateOptionAllDownloadingData,    // 所有正在下载的数据
    ZFDBGetDateOptionAllDownloadedData,     // 所有下载完成的数据
    ZFDBGetDateOptionAllUnDownloadedData,   // 所有未下载完成的数据
    ZFDBGetDateOptionAllWaitingData,        // 所有等待下载的数据
    ZFDBGetDateOptionModelWithUrl,          // 通过url获取单条数据
    ZFDBGetDateOptionWaitingModel,          // 第一条等待的数据
    ZFDBGetDateOptionLastDownloadingModel,  // 最后一条正在下载的数据
};


@interface ZFDataBaseManager : NSObject

+ (instancetype)shareManager;
/**
 create a database by filepath

 @param filePath the address of the database
 @return return the database
 */
- (instancetype)initWithFilePath:(NSString *)filePath;

/// 插入数据
- (void)insertItem:(ZFDownloadItem *)model;

/// 根据url获取数据
- (ZFDownloadItem *)getIteamWithUrl:(NSString *)url;

/// 获取第一条等待的数据
- (ZFDownloadItem *)getWaitingItem;

/// 获取最后一条正在下载的数据
- (ZFDownloadItem *)getLastDownloadingItem;

/// 获取所有数据
- (NSArray<ZFDownloadItem *> *)getAllCacheData;

/// 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<ZFDownloadItem *> *)getAllDownloadingData;

/// 获取所有下载完成的数据
- (NSArray<ZFDownloadItem *> *)getAllDownloadedData;

/// 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
- (NSArray<ZFDownloadItem *> *)getAllUnDownloadedData;

/// 获取所有等待下载的数据
- (NSArray<ZFDownloadItem *> *)getAllWaitingData;

/// 更新数据
- (void)updateWithItem:(ZFDownloadItem *)item option:(ZFDownloadState)option;

/// 删除数据
- (void)deleteItemWithUrl:(NSString *)url;

@end
