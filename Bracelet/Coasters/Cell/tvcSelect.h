//
//  tvcSelect.h
//  Bracelet
//
//  Created by 丁付德 on 16/3/5.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcSelect : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imv;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbldescription;



@property (nonatomic, strong) NSArray *arrData;// 数据源

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
