//
//  ZFListCell.m
//  ZFDownload
//
//  Created by 任子丰 on 16/5/16.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import "ZFListCell.h"

@implementation ZFListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)downloadAction:(UIButton *)sender {
    if (self.downloadCallBack) { self.downloadCallBack(); }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
