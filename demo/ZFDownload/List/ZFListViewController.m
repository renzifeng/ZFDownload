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
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation ZFListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = @[@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.2.4.dmg",
                        @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                        @"http://baobab.wdjcdn.com/14525705791193.mp4",
                        @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                        @"http://vhot.dnion.videocdn.qq.com/l00237gbcoc.mp4?vkey=1DA6D16B4A77947B875B2B55C3CE57AD2DDC0ECC01DBE185E39DA9424BA832DB659F017C7AD2FA639CE4D66244741BF6513BE33D0B3E751D46D93B8F64DCEE3C6BBBF7008D57749937C297A30EB07F6F74506140F72A2EEE8E877B33C2F4BEA433A9BABBC25D175FAA3374E0A42547A0"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    __block NSString *urlStr = self.dataSource[indexPath.row];
    cell.titleLabel.text = urlStr;
    cell.downloadCallBack = ^{
        // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
        NSString *name = [[urlStr componentsSeparatedByString:@"/"] lastObject];
        [[ZFDownloadManager sharedDownloadManager] downFileUrl:urlStr filename:name fileimage:nil];
        // 设置最多同时下载个数（默认是3）
        [ZFDownloadManager sharedDownloadManager].maxCount = 2;
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
