//
//  vcThird.h
//  Bracelet
//
//  Created by 丁付德 on 16/3/4.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcThirdDelegate <NSObject>

-(void)pageControlHidden:(BOOL)isHidden;

@end

@interface vcThird : vcBase

@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
@property (weak, nonatomic) IBOutlet UILabel *lbl5;
@property (weak, nonatomic) IBOutlet UILabel *lbl6;
@property (weak, nonatomic) IBOutlet UILabel *lbl7;
@property (weak, nonatomic) IBOutlet UILabel *lbl10;

@property (strong, nonatomic) Friend *model;                      // 好友界面传进来的好友对象

@property (assign, nonatomic) NSInteger indexSub;                 // 当前的标签  1：日  2：月   3：年

@property (assign, nonatomic) NSInteger yearSub2;                 // 选中的年             // tab2模式下
@property (assign, nonatomic) NSInteger monthSub2;                // 选中的月
@property (assign, nonatomic) NSInteger yearSub3;                 // 选中的年             // tab3模式下
@property (assign, nonatomic) NSInteger percent;                  // 得分   0 - 100;

@property (nonatomic, assign) id<vcThirdDelegate> delegate;

@property (nonatomic, strong) NSArray *arrDataForFriend;

- (void)pickerViewDisappear;

-(void)selectTabIndex:(NSInteger)ind;

@end
