//
//  NSURLSession+ZFCorrectResumeData.h
//  ZFDownload
//
//  Created by 林界 on 2018/7/31.
//  修复iOS 10.0 10.1 系统暂停下载后继续下载错误问题

#import <Foundation/Foundation.h>

@interface NSURLSession (ZFCorrectResumeData)

-  (NSURLSessionDownloadTask *)zf_downloadTaskWithCorrectResumeData:(NSData *)resumeData;

@end
