//
//  tvcSelect.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/5.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcSelect.h"

@implementation tvcSelect

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setArrData:(NSArray *)arrData
{
    self.imv.image           = [UIImage imageNamed:arrData[0]];
    self.lblTitle.text       = arrData[1];
    self.lbldescription.text = arrData[2];
}


+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcSelect"; // 标识符
    tvcSelect *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcSelect" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
