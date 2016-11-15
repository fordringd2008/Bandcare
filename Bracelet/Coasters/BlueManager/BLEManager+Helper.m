//
//  BLEManager+Helper.m
//  aerocom
//
//  Created by 丁付德 on 15/7/3.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "BLEManager+Helper.h"
#import "BLEHeader.h"

@implementation BLEManager (Helper)

// 验证数据是否正确
-(BOOL)checkData:(NSData *)data
{
    if (!data) {
        return  NO;
    }
    NSUInteger count = data.length;
    Byte *bytes = (Byte *)data.bytes;
    int sum = 0;
    
    for (int i = 1; i < count - 1; i++) {
        sum += (bytes[i]) ^ i;
    }
    BOOL isTrue = (sum & 0xFF) == bytes[count - 1];
    return isTrue;
}

-(Byte)getCheck:(char[])chars length:(int)length
{
    int sum = 0;
    for (int i = 1; i < length - 1; i++) {             
        sum += (chars[i]) ^ i;
    }
    return sum & 0xFF;
}



//
-(NSString *)intArrayToString:(int[])arr length:(int)length;
{
    NSMutableString *strResult = [NSMutableString new];
    for (int i = 0; i < length; i++) {
        NSString *str = [NSString stringWithFormat:@"%d", arr[i]];
        [strResult appendString:str];
        if (i != length - 1) {
            [strResult appendString:@","];
        }
    }
    return strResult;
}

-(int)intArrayToAVG:(int[])arr length:(int)length
{
    int sum = 0;
    int count = 0;
    for (int i = 0; i < length; i++) {
        if (arr[i] != 0) {
            count++;
            sum += arr[i];
        }
    }
    int avg = sum / count;
    return avg;
}


-(BOOL)intArrayIsHas0:(int[])arr value:(int)value length:(int)length;
{
    BOOL isHas = NO;
    for (int i = 0; i < length; i++) {
        if (arr[i] == value) {
            isHas = YES;
            break;
        }
    }
    return isHas;
}

-(BOOL)intArrayIsHas12:(int[8][12])arr
{
    BOOL isHas = NO;
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 12; j++)
        {
            if (arr[i][j] == 12) {
                isHas = YES;
                break;
            }
        }
        if (isHas)
            break;
    }
    return isHas;
}

-(NSMutableArray *)isAllShield:(NSData *)data;
{
    NSInteger length    = data.length;
    Byte *byte          = (Byte *)data.bytes;
    NSMutableArray *arr = [@[] mutableCopy];
    for(int i = 2; i < length - 3; i = i + 2)           //
    {
        // 屏蔽的话就按照原来的赋值，不屏蔽就写入 0x8000
        int refreshCount = byte[i] | (byte[i+1] << 8);
        //NSLog(@"%@", @(refreshCount));
        if (refreshCount != 32768)
        {
            [arr addObject:@( i / 2 - 1)];
        }
    }
    return arr;
}

// 获取在数组中最大的那个值的索引  （数组中为NSNumber）
-(int)getBiggestIndexInArray:(NSMutableArray *)array
{
    NSInteger tem = 0;
    NSInteger bigger = 0;
    int ind = 0;              // 索引
    int nowValue = [DFD HmF2KNSDateToInt:DNow];
    for (int i = 0; i < array.count; i++)
    {
        bigger = [array[i] integerValue];
        if (tem < bigger && bigger <= nowValue)
        {
            tem = bigger;
            ind = i;
        }
    }
    return ind;
}


// 返回小时 分钟 秒
-(NSMutableArray *)getTimesFor:(Byte)low height:(Byte)hei
{
    int d3Time = [self getTimeValue:low height:hei];
    NSMutableArray *arr = [DFD getHourMinuteSecondFormDateValue:d3Time];
    return arr;
}

-(int)getTimeValue:(Byte)low height:(Byte)hei
{
    return ( hei<<8 ) | low;
}



-(NSString *)intArrayToString:(NSMutableArray *)arr
{
    NSMutableString *strResult = [NSMutableString new];
    for (int i = 0; i < arr.count; i++)
    {
        NSString *str = [NSString stringWithFormat:@"%@", arr[i]];
        [strResult appendString:str];
        if (i != arr.count - 1)
        {
            [strResult appendString:@","];
        }
    }
    return strResult;
}


// 拼装204数据   // 今天的数据 始终都不屏蔽  为了首页不停的读 localContext
-(NSData *)get807Data:(int[7][8])array
                 uuid:(NSString *)uuid
              context:(NSManagedObjectContext *)localContext
{
    NSData *data;
    int length = 19;
    char bytes[length];
    bytes[0] = DataFirst;
    bytes[1] = DataOOOO;
    
    int todayValue = [DFD HmF2KNSDateToInt:DNow];
    NSString *acc  = myUserInfoAccess;
    
    for (int i = 0; i < 7; i++)
    {
        BOOL isRead = YES;
        int dateValue    = array[i][0];
        int refreshCount = array[i][1];
        if (dateValue == 0 || [DFD HmF2KNSIntToDate:dateValue] == nil)
        {
            NSLog(@"日期为0，或者非法");
            isRead = NO;
        }
        
        DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dateValue == %@ and access == %@ ", @(dateValue), acc] inContext:localContext];
        char byte_low;
        char byte_hight;
        
        if(dr && dateValue != todayValue)
        {
            int refreshCount      = array[i][1];
            int walkCount         = array[i][2];
            int walkDistance      = array[i][3];
            int walkCalorie       = array[i][4];
            int situpCount        = array[i][5];
            int ropeSkippingCount = array[i][6];
            int swimCount         = array[i][7];
            
            NSLog(@"%d,%d,%d,%d,%d,%d,%d",refreshCount, walkCount, walkDistance, walkCalorie,situpCount, ropeSkippingCount,swimCount);
            NSLog(@"%d,%d,%d,%d,%d,%d,%d",[dr.refresh_count intValue], [dr.step_count intValue], [dr.distance_count intValue], [dr.heat_count intValue],[dr.situps_count intValue], [dr.ropeSkipping_count intValue],[dr.swim_count intValue]);
            
            if (refreshCount        == [dr.refresh_count intValue]      && // 只有这三个变化了，才会影响到80A
                walkCount           == [dr.step_count intValue]         &&
                walkDistance        == [dr.distance_count intValue]     &&
                walkCalorie         == [dr.heat_count intValue]         //&&
//                situpCount          == [dr.situps_count intValue]       &&
//                ropeSkippingCount   == [dr.ropeSkipping_count intValue] &&
//                swimCount           == [dr.swim_count intValue]
                )
            {
                isRead = NO;
                NSLog(@"%@ %d, 这一天数据没有变化", [dr.date toString:@"YYYY-MM-dd"], dateValue);
            }
            
        }
        
        // 当需要读取某天的数据时,该天的 REFRESH_COUNT 设置得与读取到的不一致即可,或者置一个大于等于 0x8000 的任意值,因为读取时 REFRESH_COUNT 总是小于 0x8000
        // 屏蔽的话就按照原来的赋值，不屏蔽就写入 0x8000
        if (isRead)
        {
            NSLog(@"%@ %d, 这一天没有数据，或者数据变化了,或者是今天 ~~", [[DFD HmF2KNSIntToDate:dateValue]  toString:@"YYYY-MM-dd"], dateValue);
            byte_low   = 0x00;
            byte_hight = 0x80;
        }else{
            byte_low   = refreshCount & 0xFF;
            byte_hight = ( refreshCount >> 8 ) & 0xFF;
        }
        
//#warning Test       放开全部
//        
//        if (dateValue == 8394 && 0) //  || dateValue == 8393
//        {
//            byte_low   = refreshCount & 0xFF;
//            byte_hight = ( refreshCount >> 8 ) & 0xFF;
//        }else
//        {
//            byte_low   = 0x00;
//            byte_hight = 0x80;
//        }
        
        
        bytes[i * 2 + 2] = byte_low;
        bytes[i * 2 + 3] = byte_hight;
    }
    
    bytes[length - 3] = bytes[length - 2] = DataOOOO;
    bytes[length - 1] = [self getCheck:bytes length:length];
    data = [NSData dataWithBytes:bytes length:length];
    
    return data;
}

-(NSData *)get807ExceptToday:(int[7][8])array indexSub:(NSInteger)indexSub
{
    NSData *data;
    int length = 17;
    char bytes[length];
    bytes[0] = DataFirst;
    bytes[1] = DataOOOO;
    
    int todayValue = [DFD HmF2KNSDateToInt:DNow];
    for (int i = 0; i < 7; i++)
    {
        // 默认是读取
        int dateValue       = array[i][0];
        int refreshCount    = array[i][1];
        char byte_low;
        char byte_hight;
        if (dateValue == todayValue)
        {
            refreshCount++;
        }
        
        byte_low   = refreshCount & 0xFF;
        byte_hight = ( refreshCount >> 8 ) & 0xFF;
        bytes[i * 2 + 2] = byte_low;
        bytes[i * 2 + 3] = byte_hight;
    }
    
    bytes[length - 1] =  [self getCheck:bytes length:length];
    data = [NSData dataWithBytes:bytes length:length];
    return data;
}
















@end
