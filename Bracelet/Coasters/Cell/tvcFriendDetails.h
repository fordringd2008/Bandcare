//
//  tvcFriendDetails.h
//  Bracelet
//
//  Created by 丁付德 on 16/3/28.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcFriendDetails : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
+ (instancetype)cellWithTableView:(UITableView *)tableView;



@end
