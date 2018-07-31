//
//  ZFViewController.m
//  ZFDownload
//
//  Created by 任子丰 on 07/18/2018.
//  Copyright (c) 2018 任子丰. All rights reserved.
//

#import "ZFViewController.h"
#import "ZFDataBaseManager.h"

@interface ZFViewController ()

@end

@implementation ZFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ZFDownloadVideoCaches.sqlite"];
//    ZFDataBaseManager *manager = [[ZFDataBaseManager alloc] initWithPath:filePath];
    
    ZFDataBaseManager *manager = [ZFDataBaseManager shareManager];
    
    ZFDownloadItem *item = [ZFDownloadItem new];
    item.vid = @"123";
    item.fileName  = @"thie";
    item.url = @"http://www.hsd.mp4";
    item.state = ZFDownloadStateWaiting;
    [manager insertItem:item];
    ZFDownloadItem *item1  = [manager getWaitingItem];
    
}
 

@end
