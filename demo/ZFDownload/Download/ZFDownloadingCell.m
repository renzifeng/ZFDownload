//
//  ZFDownloadingCell.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFDownloadingCell.h"

@interface ZFDownloadingCell ()

@end

@implementation ZFDownloadingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.downloadBtn.clipsToBounds = true;
    [self.downloadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"🕘" forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"↓" forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  暂停、下载
 *
 *  @param sender UIButton
 */
- (IBAction)clickDownload:(UIButton *)sender {
    if (self.downloadBlock) {
        self.downloadBlock(sender);
    }
}

/**
 *  model setter
 *
 *  @param sessionModel sessionModel 
 */
- (void)setSessionModel:(ZFSessionModel *)sessionModel
{
    _sessionModel = sessionModel;
    self.fileNameLabel.text = sessionModel.fileName;
    NSUInteger receivedSize = ZFDownloadLength(sessionModel.url);
    NSString *writtenSize = [NSString stringWithFormat:@"%.2f %@",
                                                     [sessionModel calculateFileSizeInUnit:(unsigned long long)receivedSize],
                                                     [sessionModel calculateUnit:(unsigned long long)receivedSize]];
    CGFloat progress = 1.0 * receivedSize / sessionModel.totalLength;
    self.progressLabel.text = [NSString stringWithFormat:@"%@/%@ (%.2f%%)",writtenSize,sessionModel.totalSize,progress*100];
    self.progress.progress = progress;
    self.speedLabel.text = @"已暂停";
}


@end
