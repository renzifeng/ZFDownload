//
//  ZFListViewController.m
//  ZFDownload
//
//  Created by 任子丰 on 16/5/16.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import "ZFListViewController.h"
#import "ZFDownloadManager.h"
#import "ZFListCell.h"

@interface ZFListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic  ) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray       *dataSource;
@end

@implementation ZFListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = @[@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.2.4.dmg",
                        @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                        @"http://baobab.wdjcdn.com/14525705791193.mp4",
                        @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455968234865481297704.mp4"].mutableCopy;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    cell.titleLabel.text = self.dataSource[indexPath.row];
    __block NSIndexPath *blockIndexPath = indexPath;
    __weak typeof(self) weakSelf = self;
    cell.downloadCallBack = ^{
        NSString *urlString = self.dataSource[blockIndexPath.row];
        [[ZFDownloadManager sharedInstance] download:urlString progress:^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.dataSource containsObject:urlString]) {
                    [weakSelf.dataSource removeObjectAtIndex:blockIndexPath.row];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[blockIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.tableView reloadData];
                }
            });
        } state:^(DownloadState state) {}];
    };
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
