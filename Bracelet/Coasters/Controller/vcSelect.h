//
//  vcSelect.h
//  Bracelet
//
//  Created by 丁付德 on 16/3/5.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcSelect : vcBase

@property (strong, nonatomic) NSArray *arrDataFromThird; // 第三方的一些信息

@property (assign, nonatomic) BOOL isAcceptBack;         // 是否允许返回

@end
