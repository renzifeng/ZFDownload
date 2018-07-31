//
//  ZFDataBaseManager.m
//  ZFDownload_Example
//
//  Created by 任子丰 on 2018/7/23.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFDataBaseManager.h"
#import <sqlite3.h>

@implementation ZFDataBaseManager {
    sqlite3 *_database;
}

#pragma mark - init

- (void)dealloc {
    [self closeDatabase];
}

+ (instancetype)shareManager {
    static ZFDataBaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ZFDownloadVideoCaches.sqlite"];
        manager = [[self alloc] initWithPath:filePath];
    });
    
    return manager;
}

- (instancetype)initWithPath:(NSString *)filePath {
    if (self = [super init]) {
        if (sqlite3_initialize() != SQLITE_OK) {
            return nil;
        }
        if (sqlite3_open_v2([filePath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL) == SQLITE_OK) {
            //  create a table
            NSString *_sql = @"create table if not exists zf_videoCaches (id integer PRIMARY KEY AUTOINCREMENT,resumeData blob, vid text, fileName text, url text, progress float, state integer, totalFileSize integer, tmpFileSize integer, speed integer, lastSpeedTime integer, intervalFileSize integer, lastStateTime integer)";
            char *errorMsg;
            if (sqlite3_exec(_database, [_sql UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
                NSLog(@"create success");
                NSLog(@"路径是%@",filePath);
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
    return self;
}

#pragma mark - public methods
- (void)insertItem:(ZFDownloadItem *)model {
    NSString *query=[NSString stringWithFormat:@"insert into zf_videoCaches (resumeData, vid, fileName, url, progress, state, totalFileSize, tmpFileSize, speed, lastSpeedTime, intervalFileSize, lastStateTime) values ('%@','%@','%@','%@','%f','%ld','%ld','%ld','%ld','%ld','%ld','%ld')", model.resumeData, model.vid,  model.fileName, model.url,model.progress,model.state,model.totalFileSize,model.tmpFileSize,model.speed,model.lastSpeedTime,model.intervalFileSize, model.lastStateTime];
    sqlite3_stmt *insertStatement;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &insertStatement, nil);
    if (rc == SQLITE_OK) {
        @try {
            // 用data 调用bytes函数，并且获得长度。这里的长度一定要设置，不然的话数据会不正确
            sqlite3_bind_blob(insertStatement, 1, [model.resumeData bytes], (int)[model.resumeData length] , NULL);
            sqlite3_bind_text(insertStatement, 2, [query UTF8String], -1, SQLITE_TRANSIENT);
        }@catch (NSException *exception) {
            return;
        }
        rc = sqlite3_step(insertStatement);
        if (rc != SQLITE_DONE) {
            NSLog(@"插入缓存失败");
        } else {
            sqlite3_finalize(insertStatement);
            NSLog(@"插入数据成功");
        }
    } else {
        NSLog(@"插入数据错误");
    }
}

- (ZFDownloadItem *)getItemWithUrl:(NSString *)url {
    return [self getModelWithOption:ZFDBGetDataOptionModelWithUrl url:url];
}

- (ZFDownloadItem *)getWaitingItem {
    return [self getModelWithOption:ZFDBGetDataOptionWaitingModel url:nil];
}

- (ZFDownloadItem *)getLastDownloadingItem {
    return [self getModelWithOption:ZFDBGetDataOptionLastDownloadingModel url:nil];
}

- (NSArray<ZFDownloadItem *> *)getAllCacheData {
   return  [self getDateWithOption:ZFDBGetDataOptionAllCacheData];
}

- (NSArray<ZFDownloadItem *> *)getAllDownloadingData {
    return [self getDateWithOption:ZFDBGetDataOptionAllDownloadingData];
}

- (NSArray<ZFDownloadItem *> *)getAllDownloadedData {
    return [self getDateWithOption:ZFDBGetDataOptionAllDownloadedData];
}

- (NSArray<ZFDownloadItem *> *)getAllUnDownloadedData {
    return [self getDateWithOption:ZFDBGetDataOptionAllUnDownloadedData];
}

- (NSArray<ZFDownloadItem *> *)getAllWaitingData {
    return [self getDateWithOption:ZFDBGetDataOptionAllWaitingData];
}

- (void)updateWithItem:(ZFDownloadItem *)item option:(ZFDBUpdateOption)option {
    NSString *query;
    if (option & ZFDBUpdateOptionState) {
//        [self postStateChangeNotificationWithFMDatabase:db model:model];
        query = [NSString stringWithFormat:@"update zf_videoCaches set state = %@ where url = %@", [NSNumber numberWithInteger:item.state],item.url];
    }
    if (option & ZFDBUpdateOptionLastStateTime) {
//         query = [NSString stringWithFormat:@"update zf_videoCaches set lastStateTime = %@ where url = %@", [NSNumber numberWithInteger:[HWToolBox getTimeStampWithDate:[NSDate date]]], model.url];
    }
    if (option & ZFDBUpdateOptionResumeData) {
        query = [NSString stringWithFormat:@"update zf_videoCaches set resumeData = %@ where url = %@", item.resumeData, item.url];
    }
    if (option & ZFDBUpdateOptionProgressData) {
        query = [NSString stringWithFormat:@"update zf_videoCaches set tmpFileSize = %@, totalFileSize = %@, progress = %@, lastSpeedTime = %@, intervalFileSize = %@ where url = %@", [NSNumber numberWithInteger:item.tmpFileSize], [NSNumber numberWithFloat:item.totalFileSize], [NSNumber numberWithFloat:item.progress], [NSNumber numberWithInteger:item.lastSpeedTime], [NSNumber numberWithInteger:item.intervalFileSize], item.url];
    }
    if (option & ZFDBUpdateOptionAllParam) {
//        [self postStateChangeNotificationWithFMDatabase:db model:model];
//        query = [NSString stringWithFormat:@"update zf_videoCaches set resumeData = %@, totalFileSize = %@, tmpFileSize = %@, progress = %@, state = %@, lastSpeedTime = %@, intervalFileSize = %@, lastStateTime = %@ where url = ?", model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithInteger:model.state], [NSNumber numberWithInteger:model.lastSpeedTime], [NSNumber numberWithInteger:model.intervalFileSize], [NSNumber numberWithInteger:[HWToolBox getTimeStampWithDate:[NSDate date]]], model.url];
    }
    //执行sql语句
    int result = sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    if (result == SQLITE_OK) {
        NSLog(@"更新成功");
    }else {
        NSLog(@"更新失败");
    }
}

- (void)deleteItemWithUrl:(NSString *)url {
    NSString *query = [NSString stringWithFormat:@"delete from zf_videoCaches where url = '%@'",url];
    int result = sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    if (result == SQLITE_OK) {
        NSLog(@"%@删除成功",url);
    }else {
        NSLog(@"删除失败");
    }
}

- (void)deleteAllData {
    NSString *query = [NSString stringWithFormat:@"delete from zf_videoCaches"];
    int result = sqlite3_exec(_database, [query UTF8String], nil, nil, nil);
    if (result == SQLITE_OK) {
        NSLog(@"删除成功");
    }else {
        NSLog(@"删除失败");
    }
}

/// 获取单条数据
- (ZFDownloadItem *)getModelWithOption:(ZFDBGetDataOption)option url:(NSString *)url {
    __block ZFDownloadItem *model = [[ZFDownloadItem alloc] init];
    NSString *query;
    switch (option) {
        case ZFDBGetDataOptionModelWithUrl:
            query = [NSString stringWithFormat:@"select * from zf_videoCaches where url = '%@'", url];
            break;
            
        case ZFDBGetDataOptionWaitingModel:
            query = [NSString stringWithFormat:@"select * from zf_videoCaches where state = %@ order by lastStateTime asc limit 0,1", [NSNumber numberWithInteger:ZFDownloadStateWaiting]];
            break;
            
        case ZFDBGetDataOptionLastDownloadingModel:
            query = [NSString stringWithFormat:@"select * from zf_videoCaches where state = %@ order by lastStateTime desc limit 0,1", [NSNumber numberWithInteger:ZFDownloadStateDownloading]];
            break;
            
        default:
            break;
    }
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    if (rc == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            @try{
                model = [self downloadItemStatement:stmt];
            } @catch(NSException *exception) {
                NSLog(@"查询不到");
            }
        }
        sqlite3_finalize(stmt);
    } else {
        NSLog(@"获取失败rc:%d,error:%s",rc,sqlite3_errmsg(_database));
        return nil;
    }
    return model;
}

/// 获取数据库模型集合
- (NSArray<ZFDownloadItem *> *)getDateWithOption:(ZFDBGetDataOption)option {
    __block NSArray<ZFDownloadItem *> *array = nil;
    NSString *query;
    switch (option) {
        case ZFDBGetDataOptionAllCacheData:
            query = [NSString stringWithFormat:@"select * from zf_videoCaches"];
            break;
        case ZFDBGetDataOptionAllDownloadingData:
            query = [NSString stringWithFormat:@"select * from  zf_videoCaches where state = %@ order by lastStateTime desc", [NSNumber numberWithInteger:ZFDownloadStateDownloading]];
            break;
        case ZFDBGetDataOptionAllDownloadedData:
            query = [NSString stringWithFormat:@"select * from zf_videoCaches where state = %@", [NSNumber numberWithInteger:ZFDownloadStateFinish]];
            break;
        case ZFDBGetDataOptionAllUnDownloadedData:
            query = [NSString stringWithFormat:@"select * from  zf_videoCaches where state != %@", [NSNumber numberWithInteger:ZFDownloadStateFinish]];
            break;
        case ZFDBGetDataOptionAllWaitingData:
            query = [NSString stringWithFormat:@"select * from  zf_videoCaches where state = %@", [NSNumber numberWithInteger:ZFDownloadStateWaiting]];
            break;
        default:
            break;
    }
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    if (rc == SQLITE_OK) {
        NSMutableArray *tempArray = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            @try{
                [tempArray addObject:[self downloadItemStatement:stmt]];
            } @catch(NSException *exception) {
                NSLog(@"查询不到");
            }
        }
        sqlite3_finalize(stmt);
        array = tempArray;
    } else {
        NSLog(@"获取失败rc:%d,error:%s",rc,sqlite3_errmsg(_database));
        return nil;
    }
}

//  数据库查询出的数据模型
- (ZFDownloadItem *)downloadItemStatement:(sqlite3_stmt *)stmt {
    ZFDownloadItem *model = [[ZFDownloadItem alloc] init];
    const void *resumeData = sqlite3_column_blob(stmt, 1);
    const unsigned char *vid = sqlite3_column_text(stmt, 2);
    const unsigned char *fileName = sqlite3_column_text(stmt, 3);
    const unsigned char *url = sqlite3_column_text(stmt,4);
    model.progress = sqlite3_column_double(stmt,5);
    model.state = sqlite3_column_int(stmt, 6);
    model.totalFileSize = sqlite3_column_int(stmt, 7);
    model.tmpFileSize = sqlite3_column_int(stmt, 8);
    model.speed = sqlite3_column_int(stmt, 9);
    model.lastSpeedTime = sqlite3_column_int(stmt, 10);
    model.intervalFileSize = sqlite3_column_int(stmt, 11);
    model.lastStateTime = sqlite3_column_int(stmt, 12);
    model.vid = [NSString stringWithUTF8String:(const char *)vid];
    model.fileName = [NSString stringWithUTF8String:(const char *)fileName];
    model.url = [NSString stringWithUTF8String:(const char *)url];
    int resumeDataSize = sqlite3_column_bytes(stmt,1);
    model.resumeData = [[NSData alloc]initWithBytes:resumeData length:resumeDataSize];
    return model;
}

- (void)closeDatabase {
    sqlite3_close(_database);
    sqlite3_shutdown();
}

@end
