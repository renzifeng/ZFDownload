//
//  ZFListCell.h
//  ZFDownload
//
//  Created by 任子丰 on 16/5/16.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (nonatomic, copy) void(^downloadCallBack)();
@end
