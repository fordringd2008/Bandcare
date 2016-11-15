//
//  vcShare.h
//  Coasters
//
//  Created by 丁付德 on 15/8/23.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

typedef enum{
    SportTpe = 1,
    SleepTpe = 2,
    SitupTpe = 3
} ShareType;

@interface vcShare : vcBase

@property (strong, nonatomic) NSMutableArray *arrShareData; //传进的数组
                                                            // 0: 2015年10月15日喝水记录"
                                                            // 1: lbl1.text
                                                            // 2: lbl2
                                                            // 3: lbl3
                                                            // 4: lbl4
                                                            // 5: lbl5
                                                            // 6: lbl6
                                                            // 7: lbl7
                                                            // 8: lbl8
                                                            // 9: lbl9
                                                            // 10: lbl10
                                                            // 11: lbl11
                                                            // 12: lbl12

@property (assign, nonatomic) ShareType shareType;

@end
