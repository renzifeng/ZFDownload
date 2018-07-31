//
//  ZFDataBaseManager.h
//  ZFDownload_Example
//
//  Created by 任子丰 on 2018/7/23.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFDownloadItem.h"

typedef NS_OPTIONS(NSInteger, ZFDBUpdateOption) {
    ZFDBUpdateOptionState         = 1 << 0,  // 更新状态
    ZFDBUpdateOptionLastStateTime = 1 << 1,  // 更新状态最后改变的时间
    ZFDBUpdateOptionResumeData    = 1 << 2,  // 更新下载的数据
    ZFDBUpdateOptionProgressData  = 1 << 3,  // 更新进度数据（包含tmpFileSize、totalFileSize、progress、intervalFileSize、lastSpeedTime）
    ZFDBUpdateOptionAllParam      = 1 << 4   // 更新全部数据
};

typedef NS_ENUM(NSInteger, ZFDBGetDataOption) {
    ZFDBGetDataOptionAllCacheData = 0,      // 所有缓存数据
    ZFDBGetDataOptionAllDownloadingData,    // 所有正在下载的数据
    ZFDBGetDataOptionAllDownloadedData,     // 所有下载完成的数据
    ZFDBGetDataOptionAllUnDownloadedData,   // 所有未下载完成的数据
    ZFDBGetDataOptionAllWaitingData,        // 所有等待下载的数据
    ZFDBGetDataOptionModelWithUrl,          // 通过url获取单条数据
    ZFDBGetDataOptionWaitingModel,          // 第一条等待的数据
    ZFDBGetDataOptionLastDownloadingModel,  // 最后一条正在下载的数据
};


@interface ZFDataBaseManager : NSObject


+ (instancetype)shareManager;
/**
 create a database by filepath

 @param filePath the address of the database
 @return return the database
 */


/**
 根据路径返回实例化对象

 @param filePath 创建的数据库路径
 @return 根据路径返回的数据库实例对象
 */
- (instancetype)initWithPath:(NSString *)filePath;

/**
 插入数据

 @param model 插入的指定model数据
 */
- (void)insertItem:(ZFDownloadItem *)model;

/**
 根据url获取数据库中的数据

 @param url 指定的url
 @return 返回符合条件的数据
 */
- (ZFDownloadItem *)getItemWithUrl:(NSString *)url;

/**
 获取第一条等待的数据

 @return 返回的等待数据
 */
- (ZFDownloadItem *)getWaitingItem;

/**
 获取最后一条正在下载的数据

 @return 返回的复合的数据
 */
- (ZFDownloadItem *)getLastDownloadingItem;

/**
 获取所有数据

 @return 返回的所有数据
 */
- (NSArray<ZFDownloadItem *> *)getAllCacheData;

/**
 根据最近状态更新时间倒序返回正在下载的数据

 @return 返回指定条件的数据
 */
- (NSArray<ZFDownloadItem *> *)getAllDownloadingData;

/**
 获取所有下载完成的数据

 @return 返回的所有下载完成的数据
 */
- (NSArray<ZFDownloadItem *> *)getAllDownloadedData;

/**
 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）

 @return 返回的指定状态的数据
 */
- (NSArray<ZFDownloadItem *> *)getAllUnDownloadedData;

/**
 获取所有等待下载的数据

 @return 返回的等待数据
 */
- (NSArray<ZFDownloadItem *> *)getAllWaitingData;

/**
 更新指定的item

 @param item 指定的item
 @param option 更新的状态
 */
- (void)updateWithItem:(ZFDownloadItem *)item option:(ZFDBUpdateOption)option;

/**
 删除所有的数据库文件
 */
- (void)deleteAllData;

/**
 删除指定url的数据

 @param url 指定item的url地址
 */
- (void)deleteItemWithUrl:(NSString *)url;

@end
