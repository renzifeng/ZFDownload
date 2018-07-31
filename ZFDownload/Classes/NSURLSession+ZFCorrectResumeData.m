//
//  NSURLSession+ZFCorrectResumeData.m
//  ZFDownload
//
//  Created by 林界 on 2018/7/31.
//

#import "NSURLSession+ZFCorrectResumeData.h"

static NSString* const kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
static NSString* const kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";

@implementation NSURLSession (ZFCorrectResumeData)

-  (NSURLSessionDownloadTask *)zf_downloadTaskWithCorrectResumeData:(NSData *)resumeData {
    NSData *data = [self getCorrectResumeDataWithData:resumeData];
    data = data?:resumeData;
    NSURLSessionDownloadTask *downTask = [self downloadTaskWithResumeData:data];
    NSMutableDictionary *resumeDictionary = [self getResumeDictionaryWithData:data];
    if (resumeDictionary) {
        if (!downTask.originalRequest) {
            NSData *originalData = resumeDictionary[kResumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalData];
            if (originalRequest) {
                [downTask setValue:originalRequest forKey:@"originalRequest"];
            }
        }
        if (!downTask.currentRequest) {
            NSData *currentRequestData = resumeDictionary[kResumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentRequestData];
            if (currentRequest) {
                [downTask setValue:currentRequest forKey:@"currentRequest"];
            }
        }
    }
    return downTask;
}


- (NSData *)getCorrectResumeDataWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    NSMutableDictionary *resumeDictionary = [self getResumeDictionaryWithData:data];
    if (!resumeDictionary) {
        return nil;
    }
    resumeDictionary[kResumeCurrentRequest] = [self getCorrectRequestDataWithData:resumeDictionary[kResumeCurrentRequest]];
    resumeDictionary[kResumeOriginalRequest] = [self getCorrectRequestDataWithData:resumeDictionary[kResumeOriginalRequest]];
    return [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
}


- (NSMutableDictionary *)getResumeDictionaryWithData:(NSData *)data {
    return [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
}

- (NSData *)getCorrectRequestDataWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data]) return data;
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    if (!archive) return nil;
    
    NSInteger i = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld", i]]) {
        i++;
    }
    NSInteger j = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]]) {
        NSMutableArray *array = archive[@"$objects"];
        NSMutableDictionary *dic = array[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld", i + j]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]];
            [array replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = array;
        }
        j++;
    }
    
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"]) {
        NSMutableArray *array = archive[@"$objects"];
        NSMutableDictionary *dic = array[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld", i + j]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [array replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = array;
        }
    }
    
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"]) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    return [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
}


@end
