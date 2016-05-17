//
//  ZFDownloadViewController.m
//  ZFDownload
//
//  Created by 任子丰 on 16/5/16.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import "ZFDownloadViewController.h"
#import "ZFDownloadManager.h"
#import "ZFDownloadingCell.h"
#import "ZFDownloadedCell.h"

@interface ZFDownloadViewController ()<ZFDownloadDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (atomic, strong) NSMutableArray *downloadObjectArr;
@end

@implementation ZFDownloadViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    // 更新数据源
    [self initData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 70.0f;
    // NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES));
}

- (void)initData
{
    NSMutableArray *downladed = [ZFDownloadManager sharedInstance].downloadedArray;
    NSMutableArray *downloading = [ZFDownloadManager sharedInstance].downloadingArray;
    _downloadObjectArr = @[].mutableCopy;
    [_downloadObjectArr addObject:downladed];
    [_downloadObjectArr addObject:downloading];
    
    [self.tableView reloadData];
}

#pragma mark - ZFDownloadDelegate

- (void)downloadResponse:(ZFSessionModel *)sessionModel
{
    if (self.downloadObjectArr) {
        // 取到对应的cell上的model
        NSArray *downloadings = self.downloadObjectArr[1];
        if ([downloadings containsObject:sessionModel]) {
            
            NSInteger index = [downloadings indexOfObject:sessionModel];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
            __block ZFDownloadingCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            __weak typeof(self) weakSelf = self;
            sessionModel.progressBlock = ^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.progressLabel.text   = [NSString stringWithFormat:@"%@/%@ (%.2f%%)",writtenSize,totalSize,progress*100];
                    cell.speedLabel.text      = speed;
                    cell.progress.progress    = progress;
                    cell.downloadBtn.selected = YES;
                });
            };
            
            sessionModel.stateBlock = ^(DownloadState state){
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新数据源
                    if (state == DownloadStateCompleted) {
                        [weakSelf initData];
                        cell.downloadBtn.selected = NO;
                    }
                    // 暂停
                    if (state == DownloadStateSuspended) {
                        cell.speedLabel.text = @"已暂停";
                        cell.downloadBtn.selected = NO;
                    }
                });
            };
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = self.downloadObjectArr[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block ZFSessionModel *downloadObject = self.downloadObjectArr[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        ZFDownloadedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadedCell"];
        cell.sessionModel = downloadObject;
        return cell;
    }else if (indexPath.section == 1) {
        ZFDownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadingCell"];
        cell.sessionModel = downloadObject;
        [ZFDownloadManager sharedInstance].delegate = self;
        cell.downloadBlock = ^(UIButton *sender) {
            [[ZFDownloadManager sharedInstance] download:downloadObject.url progress:^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {} state:^(DownloadState state) {}];
        };
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *downloadArray = _downloadObjectArr[indexPath.section];
    ZFSessionModel * downloadObject = downloadArray[indexPath.row];
    // 根据url删除该条数据
    [[ZFDownloadManager sharedInstance] deleteFile:downloadObject.url];
    [downloadArray removeObject:downloadObject];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"下载完成",@"下载中"][section];
}



@end

