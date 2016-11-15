//
//  BLEManager+Helper.h
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "BLEManager.h"

@interface BLEManager (Helper)


// 验证数据是否正确
-(BOOL)checkData:(NSData *)data;

// 根据字节数组 和字节数组的长度，获取最后的验证字节
-(Byte)getCheck:(char[])chars length:(int)length;

//int数组 拼写字符串
-(NSString *)intArrayToString:(int[])arr length:(int)length;

// int数组， 返回非0的平均值
-(int)intArrayToAVG:(int[])arr length:(int)length;

-(BOOL)intArrayIsHas0:(int[])arr value:(int)value length:(int)length;

-(BOOL)intArrayIsHas12:(int[8][12])arr;

// 验证 屏蔽标示符，返回屏蔽的天数的索引的集合
-(NSMutableArray *)isAllShield:(NSData *)data;

-(int)getTimeValue:(Byte)low height:(Byte)hei;

// 返回小时 分钟 秒
-(NSMutableArray *)getTimesFor:(Byte)low height:(Byte)hei;

-(int)getBiggestIndexInArray:(NSMutableArray *)array;

-(NSData *)get807Data:(int[7][8])array
                 uuid:(NSString *)uuid
              context:(NSManagedObjectContext *)localContext;

-(NSData *)get807ExceptToday:(int[7][8])array indexSub:(NSInteger)indexSub;

@end
