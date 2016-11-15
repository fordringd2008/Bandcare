//
//  tvcFriendDetails.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/28.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcFriendDetails.h"

@implementation tvcFriendDetails

-(void)layoutSubviews{
    [super layoutSubviews];
    if (IPhone4) {
        self.lbl1.font = self.lbl2.font = [UIFont systemFontOfSize:10];
        self.lbl3.font = self.lbl4.font = [UIFont systemFontOfSize:11];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//-(void)setImv:(UIImageView *)imv{
//    _imv = imv;
//    
//    Border(imv, DRed);
//    Border(self.contentView, DBlack);
//    [self.imv.layer setMasksToBounds:YES];
//}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcFriendDetails"; // 标识符
    tvcFriendDetails *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcFriendDetails" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
