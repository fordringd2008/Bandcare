//
//  tvcSearch.m
//  Coasters
//
//  Created by 丁付德 on 15/8/25.
//  Copyright (c) 2015年 dfd. All rights reserved.
//
#import "tvcSearch.h"

@implementation tvcSearch

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcSearch"; // 标识符
    tvcSearch *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcSearch" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
