//
//  BLEManager.m
//  BLE
//
//  Created by 丁付德 on 15/5/24.
//  Copyright (c) 2015年 丁付德. All rights reserved.
//

#import "BLEManager.h"
#import "BLEManager+Helper.h"

static BLEManager *manager;
@interface BLEManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    dispatch_queue_t __syncQueueMangerDidUpdate;
}

@end

@implementation BLEManager

+(BLEManager *)sharedManager
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[BLEManager alloc] init];
        manager -> __syncQueueMangerDidUpdate = dispatch_get_global_queue(0, 0);
        manager.isOn = YES;
        [self resetBLE];
        manager -> dic = [[NSMutableDictionary alloc] init];
        manager -> beginDate = DNow;
        manager -> num = 0;
        manager.connetNumber = 100000000;
        manager.connetInterval = 1;
        manager.dicConnected = [[NSMutableDictionary alloc] init];
        manager.isFailToConnectAgain = YES;
        manager.isSendRepeat = NO;
        manager.isBeginOK = NO;
        manager.isResetLoadForIndex = 0;
        manager -> isRest = YES;
        
        
    });
    return manager;
}


+(void)resetBLE
{
    manager -> beginDate = DNow;
    manager -> num = 0;
    manager.connetNumber = 100000000;
    manager.connetInterval = 1;
    manager.dicConnected = [[NSMutableDictionary alloc] init];
    manager.isFailToConnectAgain = YES;
    manager.isSendRepeat = NO;
    manager.isBeginOK = NO;
}


-(void)startScan
{
    if (!self.Bluetooth)
    {
        dispatch_queue_t centralQueue = dispatch_queue_create("com.xinyi.Coasters", DISPATCH_QUEUE_SERIAL);
        self.Bluetooth = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
    }
    
    self.Bluetooth.delegate = self;
    dic = [[NSMutableDictionary alloc]init];
    [self.Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

-(void)startScanNotInit
{
    //NSLog(@"----------------正在扫描");
    self.Bluetooth.delegate = self;
    dic = [[NSMutableDictionary alloc] init];
    [self.Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
}

- (void)stopScan
{
    if (self.Bluetooth)
    {
        [self.Bluetooth stopScan];
    }
}

- (void)connectDevice:(CBPeripheral *)peripheral
{
    if (peripheral) {
        [_Bluetooth connectPeripheral:peripheral options:nil];
    }
}

-(void)stopLink:(CBPeripheral *)peripheral
{
    self.isFailToConnectAgain = NO;
    self.per = nil;
    if (peripheral)
    {
        [_Bluetooth cancelPeripheralConnection:peripheral];
    }
    else
    {
        for (int i = 0; i < self.dicConnected.count ; i++)
            [_Bluetooth cancelPeripheralConnection:self.dicConnected.allValues[i]];
    }
}

/**
 *  自动连接
 *
 *  @param uuidString uuidString
 */
-(void)retrievePeripheral:(NSString *)uuidString
{
    NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:uuidString];
    BOOL isResStart = NO;
    if(nsUUID)
    {
        NSArray *peripheralArray = [self.Bluetooth retrievePeripheralsWithIdentifiers:@[nsUUID]];
        NSLog(@"NSUUID=%@", @(peripheralArray.count));
        if([peripheralArray count] > 0)
        {
            for(CBPeripheral *peripheral in peripheralArray)
            {
                [self stopScan];
                peripheral.delegate = self;
                [self connectDevice:peripheral];
            }
        }else{
            isResStart = YES;
        }
    }
    CBUUID *cbUUID = [CBUUID UUIDWithNSUUID:nsUUID];
    if (cbUUID)
    {
        NSArray *connectedPeripheralArray = [self.Bluetooth retrieveConnectedPeripheralsWithServices:@[cbUUID]];
        NSLog(@"CBUUID=%@", @(connectedPeripheralArray.count));
        if([connectedPeripheralArray count] > 0)
        {
            for(CBPeripheral *peripheral in connectedPeripheralArray)
            {
                [self stopScan];
                peripheral.delegate = self;
                [_Bluetooth connectPeripheral:peripheral options:nil];
            }
        }else{
            isResStart = YES;
        }
    }
    
    if (isResStart)
    {
        //NSLog(@"自动连接--- 重新扫描");
        [self startScan];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([dic.allKeys containsObject:uuidString]) {
                [self connectDevice:dic[uuidString]];
            }
        });
    }
}
#pragma mark - CBCentralManagerDelegate 中心设备代理

/**
 *  当Central Manager被初始化，我们要检查它的状态，以检查运行这个App的设备是不是支持BLE
 *
 *  @param central 中心设备
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    dispatch_barrier_async(__syncQueueMangerDidUpdate, ^
    {
        if (![self isMemberOfClass:[BLEManager class]])return;
        switch (_Bluetooth.state) {
            case CBCentralManagerStatePoweredOff:
            case CBCentralManagerStateUnknown:
            case CBCentralManagerStateResetting:
            case CBCentralManagerStateUnsupported:
            case CBCentralManagerStateUnauthorized:
            {
                self.isBeginOK = NO;
                self.isLink    = NO;
                self.isOn      = NO;
                SetUserDefault(BLEisON, @(0));
                [self.dicConnected removeAllObjects];
                self.per = nil;
            }
                break;
            case CBCentralManagerStatePoweredOn:
            {
                self.isOn = YES;
                SetUserDefault(BLEisON, @(1));
                [_Bluetooth scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
                
            }
                break;
        }
    });
}


/**
 *  扫描到设备的回调
 *
 *  @param central           中心设备
 *  @param peripheral        扫描到的外设
 *  @param advertisementData 外设的数据集
 *  @param RSSI              信号
 */
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    float juli = powf(10, (abs([RSSI intValue]) - 59) / (10 * 2.0));
    NSLog(@"设备名称 : %@ %@  距离 %.1f米", peripheral.name, [peripheral.identifier UUIDString], juli);
    
    if (peripheral.name && ([peripheral.name rangeOfString:Filter_Name].length
                            || [peripheral.name rangeOfString:Filter_Other_Name].length
                            || [peripheral.name rangeOfString:A5_Filter_Name].length))
    {
        if ([peripheral respondsToSelector:@selector(identifier)]) {
            
//#warning Test
            
            // 大电池 - 4s  5109D26F-E486-5E45-52A5-73A06BE22D47
            // 小电池   6   5109D26F-E486-5E45-52A5-73A06BE22D47
            
            // 江华 - 4s 7368CDDA-23E0-9370-0DB1-7A3B44B26E89
            
//            if ([[peripheral.identifier UUIDString] isEqualToString:@"5109D26F-E486-5E45-52A5-73A06BE22D47"]
//                || [peripheral.name rangeOfString:Filter_Name].length)
            
                
                [dic setObject:peripheral forKey:[peripheral.identifier UUIDString]];
        }
    }
    
    if (dic.count > 0 && [self.delegate respondsToSelector:@selector(Found_CBPeripherals:)])
    {
        [self.delegate Found_CBPeripherals:dic];
    }
    
    if (self.isLink) {
        [self stopScan];
    }
    
}


/**
 *  连接设备成功的方法回调
 *
 *  @param central    中央设备
 *  @param peripheral 外设
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    NSString *uuidString = [peripheral.identifier UUIDString];
    [self.dicConnected setObject:peripheral forKey:uuidString];
    self.per = peripheral;
    
    if ([self.delegate respondsToSelector:@selector(CallBack_ConnetedPeripheral:)])
    {
        if ([peripheral.name rangeOfString:A5_Filter_Name].length) {
            [DFD shareDFD].isForA5 = YES;
            
        }else{
            [DFD shareDFD].isForA5 = NO;
        }
        [self.delegate CallBack_ConnetedPeripheral:uuidString];
    }
    self.isLink = YES;
    [self.Bluetooth stopScan];
    NSLog(@"连接成功了, 当前个数：%@  地址: %@", @(self.dicConnected.count), self);
}


/**
 *  连接失败的回调
 *
 *  @param central    中心设备
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"无法连接");
    if (self.isFailToConnectAgain)
        [self beginLinkAgain:peripheral];
}


/**
 *  被动断开
 *
 *  @param central    中心设备
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"------------- > 连接被断开了");
    NSString *uuidString = [[peripheral identifier] UUIDString];
    
    self.isLink = NO;
    self.isLock = NO;
    self.isBeginOK = NO;
    self.isResetLoadForIndex = 0;
    self.isReadRealOnce = YES;
    isOnlySetUserInfo = NO;                 // 断开后重置为NO
    isOnlySetClock = NO;
    
    [self.dicConnected removeObjectForKey:uuidString];
    self.per = nil;
    
    if ([self.delegate respondsToSelector:@selector(CallBack_DisconnetedPerpheral:)])
        [self.delegate CallBack_DisconnetedPerpheral:uuidString];
    
    if (self.isFailToConnectAgain)
        [self beginLinkAgain:peripheral];
}

/**
 *  发现服务 扫描特性
 *
 *  @param peripheral 外设
 *  @param error      error
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error)
    {
        peripheral.delegate = self;
        for (CBService *service in peripheral.services)
        {
            [peripheral discoverCharacteristics:nil forService:service];  // 扫描特性
        }
    }
    else
    {
        //NSLog(@"error:%@",error);
    }
}

/**
 *  发现特性 订阅特性    ----------------  IOS9  这里可能不会触发回调
 *
 *  @param peripheral 外设
 *  @param service    服务
 *  @param error      error
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error//4
{
    //
//    if (!error)
//    {
//        for (CBCharacteristic *chara in [service characteristics])
//        {
//            
//            NSString *uuidString = [chara.UUID UUIDString];
//            if ([Arr_R_UUID containsObject:uuidString]) {
//                [peripheral setNotifyValue:YES forCharacteristic:chara];   // 订阅特性
//            }
//        }
//    }
}


/**
 *  订阅结果回调，我们订阅和取消订阅是否成功
 *
 *  @param peripheral     外设
 *  @param characteristic 特性
 *  @param error          error
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        //NSLog(@"error  %@",error.localizedDescription);
    }
    else
    {
        [peripheral readValueForCharacteristic:characteristic];
        //读取服务 注意：不是所有的特性值都是可读的（readable）。通过访问 CBCharacteristicPropertyRead 可以知道特性值是否可读。如果一个特性的值不可读，使用 peripheral:didUpdateValueForCharacteristic:error:就会返回一个错误。
    }
    
//    NSString *uuidString = [characteristic.UUID UUIDString];
//      如果不是我们要特性就退出
//    if (![uuidString isEqualToString:FeiTu_TIANYIDIAN_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNZU_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNDONG_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNCHENG_ReadUUID] &&
//        ![uuidString isEqualToString:FeiTu_YUNHUAN_ReadUUID])
//    {
//        return;
//    }
    
    if (characteristic.isNotifying)
    {
        //NSLog(@"外围特性通知开始");
    }
    else
    {
        //NSLog(@"外围设备特性通知结束，也就是用户要下线或者离开%@",characteristic);
    }
}


/**
 *  当我们订阅的特性值发生变化时 （ 就是， 外设向我们发送数据 ）
 *
 *  @param peripheral     外设
 *  @param characteristic 特性
 *  @param error          error
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error//6
{
    NSData *data = characteristic.value;   // 数据集合   长度和协议匹配
    NSString *uu = [characteristic.UUID UUIDString];
    //[data LogDataAndPrompt:uu];
    if ([Arr_R_UUID containsObject:uu] || [A5_Arr_R_UUID containsObject:uu])
    {
        [self setData:data peripheral:peripheral charaUUID:uu];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *uu = [characteristic.UUID UUIDString];
    uu = uu;
    NSLog(@"%@ 写入成功",uu);
}

-(void)readChara:(NSString *)uuidString charUUID:(NSString *)charUUID
{
     CBPeripheral * cbp = self.dicConnected[uuidString];
     NSArray *arry = [cbp services];
     if (!arry.count) NSLog(@"这里为空   charUUID:%@", charUUID);
     for (CBService *ser in arry)
     {
         NSString *serverUUIDTag = ![DFD shareDFD].isForA5 ? ServerUUID : A5_ServerUUID;
         if ([[ser.UUID UUIDString] isEqualToString:serverUUIDTag])
         {
             for (CBCharacteristic *chara in [ser characteristics])
             {
                 if ([[chara.UUID UUIDString] isEqualToString:charUUID])
                 {
                     NSLog(@"开始读  %@", charUUID);
                     [cbp readValueForCharacteristic:chara];
                     break;
                 }
             }
         }
     }
}


/**
 *  写入数据
 *
 *  @param data      数据集
 *  @param charaUUID  写入的特性值
 */
-(void)Command:(NSData *)data uuidString:(NSString *)uuidString charaUUID:(NSString *)charaUUID
{
    self.per = self.dicConnected[uuidString];
    if(!self.per || !data) return;
    NSArray *arry = [self.per services];
    for (CBService *ser in arry)
    {
        NSString *serverUUID = [ser.UUID UUIDString];
        NSString *serverUUIDTag = ![DFD shareDFD].isForA5 ? ServerUUID : A5_ServerUUID;
        if ([serverUUID isEqualToString:serverUUIDTag])
        {
            for (CBCharacteristic*chara in [ser characteristics])
            {
                if ([[chara.UUID UUIDString] isEqualToString:charaUUID])
                {
                    NSString *uuid = [[self.per identifier] UUIDString];
                    [data LogDataAndPrompt:uuid promptOther:[NSString stringWithFormat:@"%@ -- >", charaUUID]];
                    [self.per writeValue:data
                       forCharacteristic:chara
                                    type:CBCharacteristicWriteWithResponse];
                    break;
                }
            }
            break;
        }
    }
}

         
-(void)setData:(NSData *)data peripheral:(CBPeripheral *)peripheral charaUUID:(NSString *)charaUUID
{
    //  ------------------------------------------------------------------------ A3 版
    //  第一次连接的流程
    //  流程  连接 -->  检查时间（如果时间不对，写入时间  306）- >  读取个人信息，如果个人信息不对，写入个人信息  303）—> 读一次实时 -> 读取运动数据304 —> 循环读取实时

    // 闹钟界面，才读取闹钟
    
    
    NSString *uuid = [[peripheral identifier] UUIDString];
    Byte *bytes = (Byte *)data.bytes;
    if ([self checkData:data])
    {
        //  A3
        if ([charaUUID isEqualToString:RW_DateTime_UUID])
        {
            self.isBeginOK = YES;
            RemoveUserDefault(isSynDataOver);
            
            NSNumber *year   = @(2000 + bytes[1]);
            NSNumber *month  = @(1 + bytes[2]);
            NSNumber *day    = @(1 + bytes[3]);
            NSNumber *hour   = @(bytes[4]);
            NSNumber *minute = @(bytes[5]);
            //NSNumber *second = [NSNumber numberWithInt:bytes[6]];
            NSDate *date = [DFD getDateFromArr:@[year, month, day, hour, minute, @0]];
            
            //NSLog(@"---- 解析后的时间为 :%@", date);
            NSDate *now = [DNow getNowDateFromatAnDate];
            double inter = [now timeIntervalSinceDate:date];
            
//            [self setDate:uuid];  // 清空当天数据，只需把时间调前一天
            NSLog(@"间隔：%f", inter);
            if (fabs(inter) > 120)
            {
                [self setDate:uuid];   // 先重新设置时间后， 间隔一段时间，后再同步   // 写完， 读
                DDWeak(self)
                NextWaitInCurrentTheard([weakself readChara:uuid charUUID:RW_DateTime_UUID];, dataInterval);
            }
            else
            {
                //[self readChara:uuid charUUID:RW_UserInfo_UUID];// 设置个人信息 加入的第一次的大循环中
            }
        }
        else if([charaUUID isEqualToString:RW_UserInfo_UUID])
        {
            [data LogData];
            
            int height = bytes[1];
            int weight = bytes[2];
            BOOL gender = !(BOOL)(bytes[3] & 0x01);                      // YES: 男               NO: 女
            BOOL iS24 = !(BOOL)((bytes[3] >> 1) & 0x01);                 // YES: 24小时制          NO: 12小时制
            BOOL isMetric = !(BOOL)((bytes[3] >> 2) & 0x01);             // YES: 公制              NO: 英制
            BOOL isLightWhenLift = (BOOL)((bytes[3] >> 3) & 0x01);       // YES: 开启              NO: 关闭
            BOOL isChinese = (BOOL)((bytes[3] >> 4) & 0x01);             // YES: 中文              NO: 英文
            BOOL isShowDate = (BOOL)((bytes[3] >> 5) & 0x01);            // YES: 显示              NO: 不显示
            BOOL isShockWhenDisconnect = !(BOOL)((bytes[3] >> 6) & 0x01);// YES:震动               NO: 不震动
            int age = bytes[4];
            int target = ( bytes[5] << 8 )| bytes[6];
            
            NSLog(@"收到  -> 身高:%d, 体重:%d, 性别:%@, 24小时:%@, 公制:%@, 抬手亮屏:%@, 中文:%@, 显示日期:%@, 断开震动:%@, 年龄:%d, 目标:%d", height, weight, @(gender), @(iS24), @(isMetric), @(isLightWhenLift), @(isChinese), @(isShowDate), @(isShockWhenDisconnect), age, target);
            
            UserInfo *userinfo = myUserInfo;
            
            int user_height                 = [userinfo.user_height intValue];
            int user_weight                 = [userinfo.user_weight intValue];
            // 协议和接口正好相反造成的   和上面保持一致
            BOOL user_gender                = ![userinfo.user_gender boolValue];
            BOOL user_24                    = [DFD isSysTime24];
            BOOL user_isMetric              = [userinfo.unit intValue];
            BOOL user_isLightWhenLift       = [userinfo.swithShowSreenWhenPut boolValue];
            BOOL user_isChinese             = [DFD getLanguage] == 1;
            BOOL user_isShowDate            = [userinfo.swithShowMenu boolValue];
            BOOL user_isShockWhenDisconnect = [userinfo.swithShockWhenDisconnect boolValue];
            int user_age                    = [DFD getAgeFromBirthDay:userinfo.user_birthday];
            int user_target                 = [userinfo.user_sport_target intValue];
            
            user_isLightWhenLift       = user_isLightWhenLift;
            user_isShowDate            = user_isShowDate;
            user_isShockWhenDisconnect = user_isShockWhenDisconnect;
            
            NSLog(@"本地  -> 身高:%d, 体重:%d, 性别:%@, 24小时:%@, 公制:%@, 抬手亮屏:%@, 中文:%@, 显示日期:%@, 断开震动:%@, 年龄:%d, 目标:%d", user_height, user_weight, @(user_gender), @(user_24), @(user_isMetric), @(user_isLightWhenLift), @(user_isChinese), @(user_isShowDate), @(user_isShockWhenDisconnect), user_age, user_target);
            
            NSArray *arr = @[ @(isLightWhenLift),@(isShowDate),@(isShockWhenDisconnect) ];
            if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                [self.delegate CallBack_Data:250 uuidString:uuid obj:arr];
            }
            
            if(height != user_height        ||
               weight != user_weight        ||
               gender != user_gender        ||
               iS24   != user_24            ||
               isMetric != user_isMetric    ||
               isChinese != user_isChinese  ||
               target != user_target        ||
               user_age != age
               )
            {
                [self setUserInfo:uuid arr:arr];
                DDWeak(self)
                NextWaitInCurrentTheard(
                        DDStrong(self)
                        [self readChara:uuid charUUID:RW_UserInfo_UUID];, dataInterval);// 再次读取
            }else
            {
                if (!isOnlySetUserInfo) {
                    self.isReadRealOnce = YES;
                    [self readChara:uuid charUUID:R_RealData_UUID];
                }
            }
        }
        else if([charaUUID isEqualToString:RW_Sport_UUID])
        {
            [data LogData];
            
            // 总共56条数据
            static int numbSub[56] = { 56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56 };
            static int dateValue[7] = { 7,7,7,7,7,7,7 };
            
            int sub = ((int)bytes[1] / 16) * 8 + (int)bytes[1] % 16;
            numbSub[sub] = sub;
            
            int f2kDate = ( bytes[3] << 8 ) | bytes[2];
            
            NSMutableArray *arrF2kDate = [DFD HmF2KIntToDate:f2kDate];
            
            int year  = [arrF2kDate[0] intValue];
            int month = [arrF2kDate[1] intValue];
            int Day   = [arrF2kDate[2] intValue];
            
            
            int datevalue = [DFD HmF2KDateToInt:[@[@(year),@(month),@(Day)] mutableCopy]];
            
            //NSLog(@"----->f2kDate :%d, datevalue:%d", f2kDate, datevalue);
            
            if(dateValue[(int)bytes[1] / 16] == 7){
                dateValue[(int)bytes[1] / 16] = datevalue;
            }
            static int step[7][24] = {  { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 }};
            static int dist[7][24] = {  { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 },
                                        { 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24 }};
            if ((int)bytes[1] % 16 < 4)
            {
                for (int i = 0; i < 6; i++) {
                    step[bytes[1] / 16][i + ((int)bytes[1] % 16) * 6] = bytes[i*2+5] << 8 | bytes[i*2+4];
                }
                
            }else
            {
                for (int i = 0; i < 6; i++) {
                    dist[bytes[1] / 16][i + (((int)bytes[1] % 16) - 4) * 6] = bytes[i*2+5] << 8 | bytes[i*2+4];
                }
            }
            
            BOOL isAgainRead = NO;
            for (int i = 0; i < 56; i++) {
                if (numbSub[i] == 56) {
                    isAgainRead = YES;
                    break;
                }
            }
            
            for (int i = 0; i < 7; i++) {
                if (dateValue[i] == 7) {
                    isAgainRead = YES;
                    break;
                }
            }
            
            if (isAgainRead)
            {
                [self readChara:uuid charUUID:RW_Sport_UUID];
            }
            else
            {
                // 读取所有日期完成  再存入数据库
                NSLog(@"%d-%d-%d-%d-%d-%d-%d-", dateValue[0],dateValue[1],dateValue[2],dateValue[3],dateValue[4],dateValue[5],dateValue[6]);
                
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
                {
                    for (int i = 0; i < 7; i++)
                    {
                        int sumStep[7] = { 0,0,0,0,0,0,0 };
                        int sumDist[7] = { 0,0,0,0,0,0,0 };
                        for (int j = 0; j < 24; j++) {
                            sumStep[i] += step[i][j];
                            sumDist[i] += dist[i][j];
                        }
                        NSString *step_arr = [self intArrayToString:step[i] length:24];
                        NSString *dis_arr = [self intArrayToString:dist[i] length:24];
                        NSString *strDate = [DFD toStringFromDateValue:dateValue[i]];
                        strDate = strDate;
                        int datevalue = dateValue[i];
                        if (datevalue == 7) continue;
                        NSDate *date = [DFD HmF2KNSIntToDate:datevalue];
                        
                        NSLog(@"%@ %@的总步数：%d，总距离：%d", date, strDate, sumStep[i], sumDist[i]);
                        
                        DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", myUserInfoAccess, @(datevalue)] inContext:localContext];
                        if (!dr) {
                            dr = [DataRecord MR_createEntityInContext:localContext];
                            dr.access = myUserInfoAccess;
                            dr.dateValue = @(datevalue);
                            dr.date = date;
                        }
                        
                        if([dr.step_count intValue] != sumStep[i])
                        {
                            NSLog(@"这有一个更新的，日期:%@, 旧总数:%@, 新总数:%@", dr.date, dr.step_count, @(sumStep[i]));
                            dr.isUpload = @NO;
                        }else
                        {
                            NSLog(@"覆盖旧数据");
                        }
                        
                        
                        dr.step_array = step_arr;
                        dr.distance_array = dis_arr;
                        dr.step_count = @(sumStep[i]);
                        dr.distance_count = @(sumDist[i]);
                        dr.heat_count = @(([myUserInfo.user_weight doubleValue] * sumDist[i]) / 800); // 卡路里 = (体重 * 距离)/8
                        [dr perfect];
                        
                        DLSave;
                        DBSave;
                    }
                    
                    self.isLock = NO;
                    self.LastDateSys = DNow;
                    
                    [DFD setLastSysDateTime:DNow access:myUserInfoAccess];                      // 设置最后的更新时间
                    [self.delegate CallBack_Data:304 uuidString:uuid obj:nil];
                    
                    self.isResetLoadForIndex = 1;
                    
                    for (int i = 0; i < 56; i++) numbSub[i] = 56;
                    for (int i = 0; i <  7; i++) dateValue[i] = 7;
                    for (int i = 0; i < 7; i ++) {
                        for(int j = 0; j < 24; j++)
                        {
                            step[i][j] = 24;
                            dist[i][j] = 24;
                        }
                    }
                }];
            }
        }
        else if([charaUUID isEqualToString:RW_Clock_UUID] || [charaUUID isEqualToString:A5_RW_Clock_UUID])
        {
            [data LogData];
            static int numData[2] = { 2, 2 };
            // 这里存放的闹钟的原始数据，4个一组，共8组， 32个
            static int clockDataSub[32] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
            
            int sub = bytes[1];
            if (numData[0] == 2 || numData[1] == 2)
            {
                numData[sub] = sub;
                for (int i = 0; i < 4; i++)
                {
                    clockDataSub[sub * 16 + i * 4 + 0] = bytes[i * 4 + 2];
                    clockDataSub[sub * 16 + i * 4 + 1] = bytes[i * 4 + 3];
                    clockDataSub[sub * 16 + i * 4 + 2] = bytes[i * 4 + 4];
                    clockDataSub[sub * 16 + i * 4 + 3] = bytes[i * 4 + 5];
                }
                
                if (numData[0] == 2 || numData[1] == 2)
                {
                    [self readChara:uuid charUUID:(![DFD shareDFD].isForA5 ? RW_Clock_UUID : A5_RW_Clock_UUID)];
                }
                else
                {
                    NSLog(@"-------闹钟读取完毕");
                    numData[0] = numData[1] = 2;
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
                    {
                        for (int i = 0; i < 8; i++)
                        {
                            Clock *cl = [Clock findFirstByAttribute:@"iD" withValue:@(i) inContext:localContext];
                            
                            int byte1 = clockDataSub[i * 4 + 0];
                            int byte2 = clockDataSub[i * 4 + 1];
                            int byte3 = clockDataSub[i * 4 + 2];
                            int byte4 = clockDataSub[i * 4 + 3];
                            
                            int typeTag = byte1;
                            if (typeTag != 0 && typeTag != 1 && typeTag != 2 && typeTag != 4) {
                                typeTag = 1;
                            }
                            cl.type = @(typeTag);          // 这里用 type 来区分  00:00分 一次性闹钟的问题
                            
                            cl.isOn = @((int)(byte2 >> 7));
                            
                            int hourF     = byte3 & 0x7F;
                            int minuteF   = byte4 & 0x3F;
                            cl.hour       = @(hourF);
                            cl.minute     = @(minuteF);

                            int sunday    = ( byte2 >> 6 ) & 0x01;
                            int monday    = ( byte2 >> 5 ) & 0x01;
                            int tuesday   = ( byte2 >> 4 ) & 0x01;
                            int wednesday = ( byte2 >> 3 ) & 0x01;
                            int thursday  = ( byte2 >> 2 ) & 0x01;
                            int friday    = ( byte2 >> 1)  & 0x01;
                            int saturday  = byte2 & 0x01;
                            
                            if (hourF || minuteF || (int)(byte2 >> 7)) {      // 兼容 老的APP
                                if ([cl.type intValue] != 1 &&
                                    [cl.type intValue] != 2 &&
                                    [cl.type intValue] != 4) {
                                    cl.type = @1;
                                }
                            }
                            
                            cl.repeat = [NSString stringWithFormat:@"%d-%d-%d-%d-%d-%d-%d", sunday, monday, tuesday, wednesday,thursday,friday, saturday];
                            [cl perfect];
                            
                            DLSave
                            DBSave
                            NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@ hour:%@ minute:%@", cl.isOn, cl.strRepeat, cl.strTime, cl.type, cl.hour, cl.minute);
                        }
                        
                        for (int i = 0; i < 32; i++)
                            clockDataSub[i] = 0;
                        
                        [self.delegate CallBack_Data:307 uuidString:uuid obj:nil];
                    }];
                }
            }
        }
        else if([charaUUID isEqualToString:R_RealData_UUID])
        {
            int hour = bytes[3];
            int minute = bytes[4];
            int second = bytes[5];
            
            int walk = bytes[9] << 24 | bytes[8] << 16 | bytes[7] << 8 | bytes[6] ;
            int distance = (bytes[13] << 24 | bytes[12] << 16 | bytes[11] << 8 | bytes[10] ) / 10;
            int calorie = (bytes[17] << 24 | bytes[16] << 16 | bytes[15] << 8 | bytes[14] ) / 100;
            
            [self.delegate CallBack_Data:309 uuidString:uuid obj:@[@(hour),@(minute),@(second),@(walk),@(distance),@(calorie)]];
            if (self.isResetLoadForIndex < 10) {
                self.isResetLoadForIndex++;
            }
            
            if (self.isReadRealOnce) {
                self.isReadRealOnce = NO;
                
                NSTimeInterval interLastSysDateTime = [DNow timeIntervalSinceDate:[DFD getLastSysDateTime:myUserInfoAccess]];
                if (fabs(interLastSysDateTime) > 20 * 60)         // 距离上次大同步的时间 大于20分钟时， 再同步大数据
                {
                    [self readChara:uuid charUUID:RW_Sport_UUID];
                }
                else
                {
                    self.isBeginOK = YES;
                    self.isLock = NO;
                    NSTimeInterval interLastUpLoadDateTime = [DNow timeIntervalSinceDate:[DFD getLastUpLoadDateTime:myUserInfoAccess ]];
                    if (fabs(interLastUpLoadDateTime) > 20 * 60)         // 距离上次上传的时间 大于20分钟
                    {
                        [self.delegate CallBack_Data:304 uuidString:uuid obj:nil];
                    }
                }
            }
        }
        else if([charaUUID isEqualToString:R_Name_UUID])
        {
            [data LogData];
            
            NSMutableString *stringResult = [[NSMutableString alloc] init];
            
            for (int i = 1; i < data.length - 1; i++)
            {
                int asciiCode = bytes[i];
                NSString *string = [NSString stringWithFormat:@"%c", asciiCode]; // A
                [stringResult appendString:string];
                
            }
            
            NSLog(@"%@", stringResult);
            
        }
        
        
        
        //  A5
        //  ------------------------------------------------------------------------ A5 版
        //  第一次连接的流程
        //  流程  连接 -->  检查时间（如果时间不对，写入时间  F803）- >  读取个人信息，如果个人信息不对，写入个人信息 F804）—> 读一次实时F808 -> 读取屏蔽位 然后设置屏蔽位 F807 —>  读取每日概况 F806(共7天)  -->  读取步行数据F80A(这个最大 要看屏蔽位是否对它有效) -> 最后循环读  读一次实时
        
        // 顺序
        // 803(时间)(先读后写) -> 804(个人信息)(先读后写) -> 808(今天一条)(读) ->  806(每日概况.含计数器)(读) -> 807(计数器)(写) ->  F80A(7天的详细数据 最大)(读) ->  808(今天一条)(读)
        
        
        else if([charaUUID isEqualToString:A5_RW_DateTime_UUID])            // 读写日期时间
        {
            self.isBeginOK = YES;
            RemoveUserDefault(isSynDataOver);
            
            NSNumber *year   = @(2000 + bytes[1]);
            NSNumber *month  = @(1 + bytes[2]);
            NSNumber *day    = @(1 + bytes[3]);
            NSNumber *hour   = @(bytes[4]);
            NSNumber *minute = @(bytes[5]);
            NSNumber *second = @(bytes[6]);
            NSDate *date = [DFD getDateFromArr:@[year, month, day, hour, minute, second]];
            
            NSLog(@"---- 解析后的时间为 :%@", date);
            double inter = [[DNow getNowDateFromatAnDate] timeIntervalSinceDate:date];
            
            // [self setDate:uuid];  // 清空当天数据，只需把时间调前一天
            NSLog(@"间隔：%f", inter);
            if (fabs(inter) > 58)
            {
                [self setDate:uuid];   // 先重新设置时间后， 间隔一段时间，后再同步   // 写完， 读
                DDWeak(self)
                NextWaitInCurrentTheard(
                        DDStrong(self)
                        [self readChara:uuid charUUID:A5_RW_DateTime_UUID];, dataInterval);
            }
            else
            {
                [self readChara:uuid charUUID:A5_RW_UseInfoAndSystem_UUID];
            }
        }
        else if([charaUUID isEqualToString:A5_RW_UseInfoAndSystem_UUID])    // 读写个人设置与系统设置
        {
            [data LogData];
            
            // F5, B6, 42, 13, 0, EE, 0, 6, 1, 88, 13, 3, 0, 0, 0, 0, 0, 0, 0, 11
            
            int height  = bytes[1];
            int weight  = bytes[2];
            BOOL gender = !(BOOL)(bytes[3] & 0x01); // YES: 女  NO: 男
            int scene   = bytes[4];
            int year    = ( bytes[5] << 8 )| bytes[6];
            int month   = bytes[7] & 0xFF;
            int day     = bytes[8] & 0xFF;
            int goal    = bytes[9]<<8 | bytes[10];
            
            /*
             
             int nSet0   = bytes[11];
             
             bit0: 是否显示日期和星期菜单          1：显示      0：不显示
             bit1: 12小时进制还是24小时进制        1：12       0：24
             bit2: 按键时振动马达是否开启.         1:振动      0:不振动         默认开
             bit3: USB 插上时保持屏幕亮.          1：亮       0：不亮          默认开
             
             bit4: 是否采用英制单位               1：英制      0：公制
             bit5: 是否采用中文菜单               1：英文      0：中文
             bit6: 是否启用抬手亮屏.              1:开启       0：关闭
             bit7: 日期格式.                     中文菜单(nSet0.bit5=0)时    1:MM/DD/YYYY(英制)   0:YYYY/MM/DD(公制)
                                                英文菜单(nSet0.bit5=1)时    1:DD/MM/YYYY(公制)   0:MM/DD/YYYY(英制)
             int nSet1   = bytes[12];
             
             bit0: 闹钟提醒时振动马达是否关闭        1:不振动     0:振动        默认开
             bit1: 闹钟提醒时 LED 是否不闪烁        1:不闪烁     0:闪烁        默认开
             bit2: 来电等提醒时振动马达是否关闭.     1:不振动     0:振动        默认开
             bit3: 来电等提醒时 LED 是否不闪烁.     1:不闪烁     0:闪烁        默认开
             
             bit4: 步行目标达到提醒时振动马达是否关闭.  1:不振动   0:振动        默认开
             bit5: 步行目标达到提醒时 LED 是否不闪烁.  1:不闪烁   0:闪烁        默认开
             bit6: 低电量提醒时振动马达是否关闭        1:不振动   0:振动        默认开
             bit7: 低电量提醒时 LED 是否不闪烁.       1:不闪烁   0:闪烁        默认开
             
             
             int nSet2   = bytes[13];
             
             bit0: 蓝牙断开时振动马达是否关闭        1:不振动     0:振动
             bit1: 蓝牙断开时 LED 是否不闪烁        1:不闪烁     0:闪烁
             
             */
            
            
            BOOL isShowDate             =  (BOOL)((bytes[11]) & 0x01);     // YES: 显示           NO: 不显示
            BOOL iS24                   = !(BOOL)((bytes[11] >> 1) & 0x01);// YES: 24小时制       NO: 12小时制
            BOOL isShockWhenButtonClick =  (BOOL)((bytes[11] >> 2) & 0x01);// YES: 按键鸣叫        NO:不鸣叫
            BOOL isLightWhenCharging    =  (BOOL)((bytes[11] >> 3) & 0x01);// YES: 充电时点亮      NO:不点亮
            
            BOOL isMetric               = !(BOOL)((bytes[11] >> 4) & 0x01); // YES: 公制           NO: 英制
            BOOL isChinese              = !(BOOL)((bytes[11] >> 5) & 0x01);// YES: 中文           NO: 英文
            BOOL isLightWhenPutUp       =  (BOOL)((bytes[11] >> 6) & 0x01);// YES: 亮屏           NO: 不
            BOOL isDateStyle            =  (BOOL)((bytes[11] >> 7) & 0x01);
                                            // 中文菜单(nSet0.bit5=0)时    1:MM/DD/YYYY(英制)   0:YYYY/MM/DD(公制)
                                            // 英文菜单(nSet0.bit5=1)时    1:DD/MM/YYYY(公制)   0:MM/DD/YYYY(英制)
            
            BOOL isShockWhenClock       = !(BOOL)((bytes[12]) & 0x01); // YES: 闹铃时鸣叫      NO:不鸣叫
            BOOL isLightWhenClock       = !(BOOL)((bytes[12] >> 1) & 0x01);// YES: 闹铃时闪烁      NO:不闪烁
            BOOL isShockWhenCalling     = !(BOOL)((bytes[12] >> 2) & 0x01);// YES:来电震动         NO: 不震动
            BOOL isLightWhenCalling     = !(BOOL)((bytes[12] >> 3) & 0x01);// YES:来电闪烁         NO: 不闪烁
            
            BOOL isShockWhenTarget      = !(BOOL)((bytes[12] >> 4) & 0x01);// YES: 达到目标震动    NO:不震动
            BOOL isLightWhenTarget      = !(BOOL)((bytes[12] >> 5) & 0x01);// YES: 达到目标闪烁    NO:不闪烁
            BOOL isShockWhenLowPower    = !(BOOL)((bytes[12] >> 6) & 0x01);// YES: 低电震动        NO:不震动
            BOOL isLightWhenLowPower    = !(BOOL)((bytes[12] >> 7) & 0x01);// YES: 低电闪烁        NO:不闪烁
            
            BOOL isShockWhenDisconnect  = !(BOOL)((bytes[13]) & 0x01);// YES: 断开蓝牙震动    NO:不震动
            BOOL isLightWhenDisconnect  = !(BOOL)((bytes[13] >> 1) & 0x01);// YES: 断开蓝牙闪烁    NO:不闪烁
            
            UserInfo *userinfo = myUserInfo;
            int user_height  = [userinfo.user_height intValue];
            int user_weight  = [userinfo.user_weight intValue];
            BOOL user_gender = [userinfo.user_gender boolValue];// YES:女 NO:男
            int user_year    = [userinfo.user_birthday getFromDate:1];
            int user_scene   = scene;
            int user_month   = [userinfo.user_birthday getFromDate:2];
            int user_day     = [userinfo.user_birthday getFromDate:3];
            int user_goal    = [userinfo.user_sport_target intValue];
            
            
            BOOL user_is24       = [DFD isSysTime24];
            BOOL user_isMetric   = [userinfo.unit boolValue];
            BOOL user_isChinese  = [DFD getLanguage] == 1;
            
            
            // 这些是默认
            
            BOOL user_isShockWhenButtonClick = YES;
            BOOL user_isLightWhenCharging    = YES;
            BOOL user_isDateStyle            = ([DFD getLanguage] == 1)  == [userinfo.unit boolValue];
            BOOL user_isShockWhenClock       = YES;
            BOOL user_isLightWhenClock       = YES;
            BOOL user_isShockWhenCalling     = YES;
            BOOL user_isLightWhenCalling     = YES;
            BOOL user_isShockWhenTarget      = YES;
            BOOL user_isLightWhenTarget      = YES;
            BOOL user_isShockWhenLowPower    = YES;
            BOOL user_isLightWhenLowPower    = YES;
            
            NSLog(@"\n本地--用户(本地)");
            NSLog(@"\n身高：%@-%@\n                \
                      体重：%@-%@\n                \
                      性别：%@-%@\n                \
                      场景：%@-%@\n                \
                      生日：%@-%@-%@,%@-%@-%@\n    \
                      目标：%@-%@\n                \
                      显示菜单：%@-%@\n             \
                      24小时：%@-%@\n              \
                      按键振动：%@-%@\n             \
                      充电点亮：%@-%@\n             \
                      公制：%@-%@\n                \
                      中文：%@-%@\n                \
                      抬手亮屏：%@-%@\n             \
                      日期格式：%@-%@\n             \
                      闹铃震动：%@-%@\n             \
                      闹铃闪烁：%@-%@\n             \
                      来电震动：%@-%@\n             \
                      来电闪烁：%@-%@\n             \
                      完成目标震动：%@-%@\n          \
                      完成目标闪烁：%@-%@\n          \
                      低电震动：%@-%@\n             \
                      低电闪烁：%@-%@\n             \
                      断开震动：%@-%@\n             \
                      断开闪烁：%@-%@\n          ",
                  @(height),@(user_height),
                  @(weight),@(user_weight),
                  @(gender),@(user_gender),
                  @(scene),@(user_scene),
                  @(year),@(month),@(day),@(user_year),@(user_month),@(user_day),
                  @(goal),@(user_goal),
                  @(isShowDate),@(isShowDate),                          // 这个不参与判断
                  @(iS24),@(user_is24),
                  @(isShockWhenButtonClick),@(user_isShockWhenButtonClick),
                  @(isLightWhenCharging),@(user_isLightWhenCharging),
                  @(isMetric),@(user_isMetric),
                  @(isChinese),@(user_isChinese),
                  @(isLightWhenPutUp),@(isLightWhenPutUp),              // 这个不参与判断
                  @(isDateStyle),@(user_isDateStyle),
                  @(isShockWhenClock),@(user_isShockWhenClock),
                  @(isLightWhenClock),@(user_isLightWhenClock),
                  @(isShockWhenCalling),@(user_isShockWhenCalling),
                  @(isLightWhenCalling),@(user_isLightWhenCalling),
                  @(isShockWhenTarget),@(user_isShockWhenTarget),
                  @(isLightWhenTarget),@(user_isLightWhenTarget),
                  @(isShockWhenLowPower),@(user_isShockWhenLowPower),
                  @(isLightWhenLowPower),@(user_isLightWhenLowPower),
                  @(isShockWhenDisconnect),@(isShockWhenDisconnect),    // 这个不参与判断
                  @(isLightWhenDisconnect),@(isLightWhenDisconnect)     // 这个不参与判断
                  );
            NSArray *arr = @[ @(user_height),
                              @(user_weight),
                              @(user_gender),
                              @(user_scene),
                              @(user_year),
                              @(user_month),
                              @(user_day),
                              @(user_goal),
                              @(isShowDate),                          // 这个不参与判断
                              @(user_is24),
                              @(user_isShockWhenButtonClick),
                              @(user_isLightWhenCharging),
                              @(user_isMetric),
                              @(user_isChinese),
                              @(isLightWhenPutUp),              // 这个不参与判断
                              @(user_isDateStyle),
                              @(user_isShockWhenClock),
                              @(user_isLightWhenClock),
                              @(user_isShockWhenCalling),
                              @(user_isLightWhenCalling),
                              @(user_isShockWhenTarget),
                              @(user_isLightWhenTarget),
                              @(user_isShockWhenLowPower),
                              @(user_isLightWhenLowPower),
                              @(isShockWhenDisconnect),    // 这个不参与判断
                              @(isLightWhenDisconnect)     // 这个不参与判断
                              ];
            
            if ([self.delegate respondsToSelector:@selector(CallBack_Data:uuidString:obj:)]) {
                [self.delegate CallBack_Data:250 uuidString:uuid obj:arr];
            }
            
            if (height                  != user_height                  ||
                weight                  != user_weight                  ||
                gender                  != user_gender                  ||
                year                    != user_year                    ||
                month                   != user_month                   ||
                day                     != user_day                     ||
                goal                    != user_goal                    ||
                iS24                    != user_is24                    ||
                isShockWhenButtonClick  != user_isShockWhenButtonClick  ||
                isLightWhenCharging     != user_isLightWhenCharging     ||
                isMetric                != user_isMetric                ||
                isChinese               != user_isChinese               ||
                isDateStyle             != user_isDateStyle             ||
                isShockWhenClock        != user_isShockWhenClock        ||
                isLightWhenClock        != user_isLightWhenClock        ||
                isShockWhenCalling      != user_isShockWhenCalling      ||
                isLightWhenCalling      != user_isLightWhenCalling      ||
                isShockWhenTarget       != user_isShockWhenTarget       ||
                isLightWhenTarget       != user_isLightWhenTarget       ||
                isShockWhenLowPower     != user_isShockWhenLowPower     ||
                isLightWhenLowPower     != user_isLightWhenLowPower
                )
            {
                [self setUserInfo:uuid arr:arr];
                DDWeak(self)
                NextWaitInCurrentTheard(
                        DDStrong(self)
                        [self readChara:uuid charUUID:A5_RW_UseInfoAndSystem_UUID];, dataInterval);// 再次读取
            }
            else
            {
                // 读取第一次实时，方便首页最先展示
                if (!isOnlySetUserInfo) {
                    self.isReadRealOnce = YES;
                    [self readChara:uuid charUUID:A5_R_TodayDataAbout_UUID];
                }
            }
        }
        else if([charaUUID isEqualToString:A5_R_EveryDayDataAbout_UUID])    // 读取每日概况(DATE ABOUT),每天一条数据.
        {
            [data LogData];
            static int everyDayDataAbout[7] = {7,7,7,7,7,7,7};
            static int everyDayDataAboutDetail[7][8] = {
                {0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0},
                {0,0,0,0,0,0,0,0}};
            int indexInEveryDayDataAbout = bytes[1];
            if (everyDayDataAbout[indexInEveryDayDataAbout] != indexInEveryDayDataAbout)
            {
                everyDayDataAbout[indexInEveryDayDataAbout] = indexInEveryDayDataAbout;
                int f2kDate           = (bytes[3] << 8) | bytes[2];
                int refreshCount      = (bytes[5] << 8) | bytes[4];
                int walkCount         = (bytes[7] << 8) | bytes[6];
                int walkDistance      = (bytes[9] << 8) | bytes[8];
                int walkCalorie       = (bytes[11] << 8) | bytes[10];
                int situpCount        = (bytes[13] << 8) | bytes[12];
                int ropeSkippingCount = (bytes[15] << 8) | bytes[14];
                int swimCount         = (bytes[17] << 8) | bytes[16];
                everyDayDataAboutDetail[indexInEveryDayDataAbout][0] = f2kDate;
                everyDayDataAboutDetail[indexInEveryDayDataAbout][1] = refreshCount;
                everyDayDataAboutDetail[indexInEveryDayDataAbout][2] = walkCount;
                everyDayDataAboutDetail[indexInEveryDayDataAbout][3] = walkDistance;
                everyDayDataAboutDetail[indexInEveryDayDataAbout][4] = walkCalorie;
                everyDayDataAboutDetail[indexInEveryDayDataAbout][5] = situpCount;
                everyDayDataAboutDetail[indexInEveryDayDataAbout][6] = ropeSkippingCount;
                everyDayDataAboutDetail[indexInEveryDayDataAbout][7] = swimCount;
                
                NSLog(@"f2kDate:%@,日期:%@,更新计数:%@,步数:%@,距离:%@,热量:%@,仰卧起坐:%@,跳绳:%@,游泳:%@,",
                      @(f2kDate),
                      [[DFD HmF2KNSIntToDate:f2kDate] toString:@"YYYY-MM-dd"],
                      @(refreshCount),
                      @(walkCount),
                      @(walkDistance),
                      @(walkCalorie),
                      @(situpCount),
                      @(ropeSkippingCount),
                      @(swimCount));
                [self readChara:uuid charUUID:A5_R_EveryDayDataAbout_UUID];// 这里会导致多读一条，无所谓了
            }
            else
            {
                NSLog(@"读完了 7天的每天一条");
                for(int i = 0; i < 7; i++){
                    everyDayDataAbout[i] = 7;
                }
                NSLog(@"这里处理数据");
                
                NSString *acc = myUserInfoAccess;
                if (!acc) {
                    NSLog(@"用户解除了绑定");
                    return;
                }
                DDWeak(self)
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
                {
                    DDStrong(self)
                    todayIndexInSysData = [self getBiggestIndexInArray:[@[@(everyDayDataAboutDetail[0][0]),
                                                                          @(everyDayDataAboutDetail[1][0]),
                                                                          @(everyDayDataAboutDetail[2][0]),
                                                                          @(everyDayDataAboutDetail[3][0]),
                                                                          @(everyDayDataAboutDetail[4][0]),
                                                                          @(everyDayDataAboutDetail[5][0]),
                                                                          @(everyDayDataAboutDetail[6][0])] mutableCopy]];
                    NSData *data807 = [self get807Data:everyDayDataAboutDetail
                                                  uuid:uuid
                                               context:localContext];
                    shieldCountOfDay = [self isAllShield:data807];
                    NSLog(@"屏蔽了这些下标的数据:%@", shieldCountOfDay);
                    data807ExceptToday = [self get807ExceptToday:everyDayDataAboutDetail
                                                        indexSub: todayIndexInSysData];
                    [self Command:data807 uuidString:uuid charaUUID:A5_W_DayShield_UUID];
                    for (int i = 0; i < 7; i++)
                    {
                        int datevalue         = everyDayDataAboutDetail[i][0];
                        int refreshCount      = everyDayDataAboutDetail[i][1];
                        int walkCount         = everyDayDataAboutDetail[i][2];
                        int walkDistance      = everyDayDataAboutDetail[i][3];
                        int walkCalorie       = everyDayDataAboutDetail[i][4];
                        int situpCount        = everyDayDataAboutDetail[i][5];
                        int ropeSkippingCount = everyDayDataAboutDetail[i][6];
                        int swimCount         = everyDayDataAboutDetail[i][7];
                        
                        // 等于 0  或者转化出日期不存在就舍弃
                        if (datevalue && [DFD HmF2KNSIntToDate:datevalue])
                        {
                            DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", acc,  @(datevalue)] inContext:localContext];
                            if (!dr) {
                                NSLog(@"创建 DataRecord, %@,%@", @(datevalue),[DFD HmF2KNSIntToDate:datevalue]);
                                dr = [DataRecord MR_createEntityInContext:localContext];
                                dr.access    = acc;
                                dr.dateValue = @(datevalue);
                                dr.isUpload  = @NO;
                            }
                            if ([dr.refresh_count intValue]     != refreshCount ||
                                [dr.step_count intValue]        != walkCount ||
                                [dr.distance_count intValue]    != walkDistance ||
                                [dr.heat_count intValue]        != walkCalorie ||
                                [dr.situps_count intValue]      != situpCount ||
                                [dr.ropeSkipping_count intValue]!= ropeSkippingCount ||
                                [dr.swim_count intValue]        != swimCount
                                )
                            {
                                dr.isUpload           = @NO;
                                dr.refresh_count      = @(refreshCount);
                                dr.step_count         = @(walkCount);
                                dr.distance_count     = @(walkDistance);
                                dr.heat_count         = @(walkCalorie);
                                dr.situps_count       = @(situpCount);
                                dr.ropeSkipping_count = @(ropeSkippingCount);
                                dr.swim_count         = @(swimCount);
                            }else{
                                dr.isUpload = @YES;
                            }
                            
                            [dr perfect];
                            DLSave
                            DBSave
                        }
                    }
                    
                    isRest = YES;
                    // 读取7天的详细数据 80A  最大
                    [self readChara:uuid charUUID:A5_R_StepAndDistanceAndHeat_UUID];
                }];
            }
        }
        else if([charaUUID isEqualToString:A5_R_TodayDataAbout_UUID])       // 读取当日概况(DATE ABOUT),仅一条数据.
        {
            [data LogData];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
            {
                int datevalue         = (bytes[3] << 8) | bytes[2];
                int refreshCount      = (bytes[5] << 8) | bytes[4];
                int walkCount         = (bytes[7] << 8) | bytes[6];
                int walkDistance      = (bytes[9] << 8) | bytes[8];
                int walkCalorie       = (bytes[11] << 8) | bytes[10];
                int situpCount        = (bytes[13] << 8) | bytes[12];
                int ropeSkippingCount = (bytes[15] << 8) | bytes[14];
                int swimCount         = (bytes[17] << 8) | bytes[16];
                
                // 等于 0  或者转化出日期不存在就舍弃
                if (datevalue && [DFD HmF2KNSIntToDate:datevalue])
                {
                    NSString *acc   = myUserInfoAccess;
                    if (!acc) {
                        NSLog(@"用户解除了绑定");
                        return;
                    }
                    DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", acc,  @(datevalue)] inContext:localContext];
                    if (!dr) {
                        NSLog(@"创建 DataRecord, %@,%@", @(datevalue),[DFD HmF2KNSIntToDate:datevalue]);
                        dr = [DataRecord MR_createEntityInContext:localContext];
                        dr.access    = acc;
                        dr.dateValue = @(datevalue);
                        dr.isUpload  = @NO;
                    }
                    if ([dr.refresh_count intValue]     != refreshCount ||
                        [dr.step_count intValue]        != walkCount ||
                        [dr.distance_count intValue]    != walkDistance ||
                        [dr.heat_count intValue]        != walkCalorie ||
                        [dr.situps_count intValue]      != situpCount ||
                        [dr.ropeSkipping_count intValue]!= ropeSkippingCount ||
                        [dr.swim_count intValue]        != swimCount
                        )
                    {
                        dr.isUpload           = @NO;
                        dr.refresh_count      = @(refreshCount);
                        dr.step_count         = @(walkCount);
                        dr.distance_count     = @(walkDistance);
                        dr.heat_count         = @(walkCalorie);
                        dr.situps_count       = @(situpCount);
                        dr.ropeSkipping_count = @(ropeSkippingCount);
                        dr.swim_count         = @(swimCount);
                    }else{
                        dr.isUpload = @YES;
                    }
                    
                    [dr perfect];
                    DLSave
                    DBSave
                }
                
                // 读完了当天的第一条实时
                [self.delegate CallBack_Data:309 uuidString:uuid obj:@[@(walkCount),@(walkDistance),@(walkCalorie),@(situpCount),@(ropeSkippingCount),@(swimCount)]];
                if (self.isResetLoadForIndex < 10) {
                    self.isResetLoadForIndex++;
                }
                
                if (self.isReadRealOnce) {
                    [self readChara:uuid charUUID:A5_R_EveryDayDataAbout_UUID];
                }
            }];
        }
        else if([charaUUID isEqualToString:A5_R_StepAndDistanceAndHeat_UUID])// 读取步行数据.含步数,距离,热量三者
        {
            int indexDateInData        = bytes[1] >> 4;    // 当前数据在天数据中的索引
            int indexDateDetailsInData = bytes[1] & 0x0F;  // 当前数据在每天数据中中的索引
            
            [data LogDataAndPrompt:[NSString stringWithFormat:@"这是第 %d 天的第 %d 条数据 ", indexDateInData, indexDateDetailsInData]];
            
//#warning Test 这里待硬件正常时放开  && 0
            if ([shieldCountOfDay containsObject:@(indexDateInData)])
            {
                NSLog(@"这是屏蔽的数据，硬件正常时不会收到");
            }
            else
            {
                static int receivedData[7][12];     // 存储已经读到的下标集合
                static int receivedDataF2Date[7];   // 存储已经读到的f2Date集合
                static int stepData[7][24];         // 存储7天的24小时步数集合
                static int distanceData[7][24];     // 存储7天的24小时距离集合
                static int heatData[7][24];         // 存储7天的24小时热量集合
                if (isRest) {
                    isRest = NO;
                    for (int i = 0; i < 7; i++)
                    {
                        receivedDataF2Date[i] = 0;
                        for (int j = 0; j < 24; j++)
                        {
                            if (j < 12)
                                receivedData[i][j] = 12;
                            stepData[i][j] = 0;
                            distanceData[i][j] = 0;
                            heatData[i][j] = 0;
                        }
                    }
                }
                
                int f2Date = (bytes[3] << 8) | bytes[2];
                if (receivedDataF2Date[indexDateInData] != f2Date) {
                    receivedDataF2Date[indexDateInData] = f2Date;
                }
                
                if (receivedData[indexDateInData][indexDateDetailsInData] != indexDateDetailsInData)
                {
                    receivedData[indexDateInData][indexDateDetailsInData] = indexDateDetailsInData;
                    int dataOnce[6] = {0,0,0,0,0,0};
                    for (int i = 0 ; i < 6; i++)
                    {
                        dataOnce[i] = (bytes[i*2+5] << 8) | bytes[i*2+4];
                    }
                    
                    NSDate *dateToday = [DFD HmF2KNSIntToDate:f2Date];
                    if (f2Date && dateToday)    // 过滤无效数据
                    {
                        if (indexDateDetailsInData < 4)                                      // 步数
                        {
                            stepData[indexDateInData][indexDateDetailsInData * 6 + 0] = dataOnce[0];
                            stepData[indexDateInData][indexDateDetailsInData * 6 + 1] = dataOnce[1];
                            stepData[indexDateInData][indexDateDetailsInData * 6 + 2] = dataOnce[2];
                            stepData[indexDateInData][indexDateDetailsInData * 6 + 3] = dataOnce[3];
                            stepData[indexDateInData][indexDateDetailsInData * 6 + 4] = dataOnce[4];
                            stepData[indexDateInData][indexDateDetailsInData * 6 + 5] = dataOnce[5];
                        }
                        else if(indexDateDetailsInData >= 4 && indexDateDetailsInData < 8)    // 距离
                        {
                            distanceData[indexDateInData][(indexDateDetailsInData - 4) * 6 + 0] = dataOnce[0];
                            distanceData[indexDateInData][(indexDateDetailsInData - 4) * 6 + 1] = dataOnce[1];
                            distanceData[indexDateInData][(indexDateDetailsInData - 4) * 6 + 2] = dataOnce[2];
                            distanceData[indexDateInData][(indexDateDetailsInData - 4) * 6 + 3] = dataOnce[3];
                            distanceData[indexDateInData][(indexDateDetailsInData - 4) * 6 + 4] = dataOnce[4];
                            distanceData[indexDateInData][(indexDateDetailsInData - 4) * 6 + 5] = dataOnce[5];
                        }
                        else if(indexDateDetailsInData >= 8 && indexDateDetailsInData < 12)   // 热量
                        {
                            heatData[indexDateInData][(indexDateDetailsInData - 8) * 6 + 0] = dataOnce[0];
                            heatData[indexDateInData][(indexDateDetailsInData - 8) * 6 + 1] = dataOnce[1];
                            heatData[indexDateInData][(indexDateDetailsInData - 8) * 6 + 2] = dataOnce[2];
                            heatData[indexDateInData][(indexDateDetailsInData - 8) * 6 + 3] = dataOnce[3];
                            heatData[indexDateInData][(indexDateDetailsInData - 8) * 6 + 4] = dataOnce[4];
                            heatData[indexDateInData][(indexDateDetailsInData - 8) * 6 + 5] = dataOnce[5];
                        }
                    }
                    else
                    {
                        NSLog(@"无效数据");
                    }
                    
                    [self readChara:uuid charUUID:A5_R_StepAndDistanceAndHeat_UUID];
                }
                else
                {
                    NSLog(@"大数据读完了");
                    
                    //开始写入 只写没有屏蔽的那些天的数据
                    NSString *acc = myUserInfoAccess;
                    if (!acc) {
                        NSLog(@"用户解除了绑定");
                        return;
                    }
                    
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
                     {
                         for (int i = 0 ; i < 7; i ++)
                         {
//#warning Test 这里待硬件正常时放开  && 0
                             if ([shieldCountOfDay containsObject:@(indexDateInData)])
                             {
                                 NSLog(@"这是屏蔽的数据，硬件正常时不会收到");
                             }
                             else
                             {
                                 NSLog(@"日期:%@ %@", @(receivedDataF2Date[i]), [[DFD HmF2KNSIntToDate:receivedDataF2Date[i]] toString:@"YYYY-MM-dd"]);
                                 int datevalue = receivedDataF2Date[i];
                                 if (datevalue)  // 过滤屏蔽的数据  屏蔽的就是0
                                 {
                                     DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", acc, @(datevalue)] inContext:localContext];
                                     if (!dr) {
                                         NSLog(@"这里出错了，前面应该已经创建了");
                                     }
                                     
                                     NSString *step_array     = [self intArrayToString:stepData[i] length:24];
                                     NSString *distance_array = [self intArrayToString:distanceData[i] length:24];
                                     NSString *heat_array     = [self intArrayToString:heatData[i] length:24];
                                     
                                     NSLog(@"\n步数：%@\n距离：%@\n热量：%@",step_array, distance_array ,heat_array);
                                     
                                     dr.step_array     = step_array;
                                     dr.distance_array = distance_array;
                                     dr.heat_array     = heat_array;
                                     dr.isUpload       = @NO;
                                     
                                     DLSave
                                     DBSave
                                 } 
                             }
                         }
                         // 大数据出来完毕
                         self.isBeginOK = YES;
                         self.isLock = NO;
                         NSTimeInterval interLastUpLoadDateTime = [DNow timeIntervalSinceDate:[DFD getLastUpLoadDateTime:acc ]];
                         [DFD setLastSysDateTime:DNow access:acc];  // 设置最后的更新时间
                         self.isLock = NO;
                         self.LastDateSys = DNow;
                         self.isResetLoadForIndex = 1;
                         if (fabs(interLastUpLoadDateTime) > 20 * 60) // 距离上次上传的时间 大于20分钟
                         {
                             [self.delegate CallBack_Data:304 uuidString:uuid obj:nil];
                         }
                     }];
                }
            }
        }
    }
}




// ------------------------------------------------------------------------------

// ----------------------------- 私有方法 ----------------------------------------

// ------------------------------------------------------------------------------

/**
 *  开始断开重连
 *
 *  @param peripheral 要重新连接的设备
 */
-(void)beginLinkAgain:(CBPeripheral *)peripheral
{
    [self retrievePeripheral:[peripheral.identifier UUIDString]];
//    NSTimer *timR;
//    timR = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(link:) userInfo:peripheral repeats:YES];
    //[self.Bluetooth connectPeripheral:peripheral options:nil];
}

-(void)link:(NSTimer *)timerR
{
    NSLog(@"被动断开后，重新");
    CBPeripheral *cp = timerR.userInfo;
    [self retrievePeripheral:[cp.identifier UUIDString]];
}


// ------------------------------------------------------------------------------

// ----------------------------- 帮助方法 ----------------------------------------

// ------------------------------------------------------------------------------



- (void)begin:(NSString *)uuid
{
    if (!uuid || !uuid.length || self.Bluetooth.state != CBCentralManagerStatePoweredOn) return;
    NSLog(@"----------  开始了， uuid:%@", uuid);
    _isLock = YES;
    if (!_isBeginOK && self.isLink) {
        [self readChara:uuid charUUID:![DFD shareDFD].isForA5 ? RW_DateTime_UUID: A5_RW_DateTime_UUID];
    }
    
    // 这里开始读的时候， 可能链接还不稳定，  如果在一定时间内，没有返回数据，  应该再次读取    2秒
    DDWeak(self)
    NextWaitInCurrentTheard(
        DDStrong(self)
        if(self){
            if(!self.isBeginOK){
                [self begin:uuid];
            };
        }, 2);
}
//
//// 设置闹钟 并读取
//-(void)setClockAndRead:(NSString *)uuidString isFirst:(BOOL)isFirst
//{
//    isOnlySetClock = YES;
//    [self setClock:uuidString isFirst:isFirst];
//    DDWeak(self)
//    NextWaitInCurrentTheard(
//        DDStrong(self)
//        [self readChara:uuidString charUUID:![DFD shareDFD].isForA5 ? RW_Clock_UUID : A5_RW_Clock_UUID];, 1);
//}

// 设置用户 并读取
-(void)setUserinfoAndRead:(NSString *)uuidString
{
    isOnlySetUserInfo = YES;
    [self setUserInfo:uuidString arr:nil];
    DDWeak(self)
    NextWaitInCurrentTheard(
        DDStrong(self)
        [self readChara:uuidString charUUID:![DFD shareDFD].isForA5 ?RW_UserInfo_UUID:A5_RW_UseInfoAndSystem_UUID];, 1);
}

-(void)readClock:(NSString *)uuidString
{
    isOnlySetClock = YES;
    [self readChara:uuidString charUUID:![DFD shareDFD].isForA5 ? RW_Clock_UUID : A5_RW_Clock_UUID];
}

// 读取实时数据
- (void)realRealData:(NSString *)uuid
{
    if ([DFD shareDFD].isForA5) {
        self.isReadRealOnce = NO;
    }
    [self readChara:uuid charUUID:(![DFD shareDFD].isForA5 ? R_RealData_UUID : A5_R_TodayDataAbout_UUID)];
}


// 写入时间
-(void)setDate:(NSString *)uuidString
{
    char data[8];
    data[0] = DataFirst;
    data[1] = (DDYear - 2000) & 0xFF;
    data[2] = (DDMonth - 1) & 0xFF;
    data[3] = (DDDay - 1) & 0xFF;
    data[4] = DDHour & 0xFF;
    data[5] = DDMinute & 0xFF;
    data[6] = DDSecond & 0xFF;
    
    int sum = 0;
    for (int i = 1; i < 7; i++) {
        sum += (data[i]) ^ i;
    }
    data[7] = sum & 0xFF;
    
    NSData *dataPush = [NSData dataWithBytes:data length:8];
    [self Command:dataPush
       uuidString:uuidString
        charaUUID:([DFD shareDFD].isForA5 ? A5_RW_DateTime_UUID : RW_DateTime_UUID)];
}


// 写入个人信息
-(void)setUserInfo:(NSString *)uuidString arr:(NSArray *)arr
{
    if (![DFD shareDFD].isForA5)
    {
        UserInfo *userinfo = myUserInfo;
        int length = 8;
        char data[length];
        
        data[0] = DataFirst;
        data[1] = [userinfo.user_height intValue] & 0xFF;
        data[2] = [userinfo.user_weight intValue] & 0xFF;
        
        int gender = [userinfo.user_gender boolValue] ? 1 : 0;  // 硬件协议上  0：女  1 ： 男  本地是 是 YES 女  NO 男
        int isD24 = [DFD isSysTime24] ? 0 : 1;
        int isMetric = [userinfo.unit boolValue] ? 0 : 1;
        
        int isLightWhenLift, isShowDate, isShockWhenDisconnect;
        if (arr) {
            isLightWhenLift = [arr[0] boolValue]? 1:0;
            isShowDate = [arr[1] boolValue]? 1:0;
            isShockWhenDisconnect = [arr[2] boolValue]? 0:1;
        }else{
            isLightWhenLift = [userinfo.swithShowSreenWhenPut boolValue] ? 1:0;
            isShowDate = [userinfo.swithShowMenu boolValue] ? 1:0;
            isShockWhenDisconnect = [userinfo.swithShockWhenDisconnect boolValue] ? 0:1;
        }
        
        
        int isChinese = [DFD getLanguage] == 1 ? 1:0;
        data[3] = gender | (isD24 << 1) | (isMetric << 2)  | (isLightWhenLift << 3)  | (isChinese << 4)  | (isShowDate << 5)  | (isShockWhenDisconnect << 6) ;
        
        int age = [DFD getAgeFromBirthDay:userinfo.user_birthday];
        data[4] = age & 0xFF;
        int target = [userinfo.user_sport_target intValue];
        data[5] = (target >> 8) & 0xFF;
        data[6] = target & 0xFF;
        data[length - 1] = [self getCheck:data length:length];
        
        NSData *dataPush = [NSData dataWithBytes:data length:length];
        [self Command:dataPush uuidString:uuidString charaUUID:RW_UserInfo_UUID];
    }
    else
    {
        int height, weight, gender, scene, year, month, day, goal;
        int isShowDate, iS24, isShockWhenButtonClick, isLightWhenCharging, isMetric, isChinese, isLightWhenPutUp, isDateStyle, isShockWhenClock, isLightWhenClock, isShockWhenCalling, isLightWhenCalling, isShockWhenTarget, isLightWhenTarget, isShockWhenLowPower, isLightWhenLowPower, isShockWhenDisconnect, isLightWhenDisconnect;
        
        /*
        BOOL isShowDate             =  (BOOL)((bytes[11]) & 0x01);     // YES: 显示           NO: 不显示
        BOOL iS24                   = !(BOOL)((bytes[11] >> 1) & 0x01);// YES: 24小时制       NO: 12小时制
        BOOL isShockWhenButtonClick =  (BOOL)((bytes[11] >> 2) & 0x01);// YES: 按键鸣叫        NO:不鸣叫
        BOOL isLightWhenCharging    =  (BOOL)((bytes[11] >> 3) & 0x01);// YES: 充电时点亮      NO:不点亮
        
        BOOL isMetric               = !(BOOL)((bytes[11] >> 4) & 0x01); // YES: 公制           NO: 英制
        BOOL isChinese              = !(BOOL)((bytes[11] >> 5) & 0x01);// YES: 中文           NO: 英文
        BOOL isLightWhenPutUp       =  (BOOL)((bytes[11] >> 6) & 0x01);// YES: 亮屏           NO: 不
        BOOL isDateStyle            =  (BOOL)((bytes[11] >> 7) & 0x01);
        // 中文菜单(nSet0.bit5=0)时    1:MM/DD/YYYY(英制)   0:YYYY/MM/DD(公制)
        // 英文菜单(nSet0.bit5=1)时    1:DD/MM/YYYY(公制)   0:MM/DD/YYYY(英制)
        
        BOOL isShockWhenClock       = !(BOOL)((bytes[12]) & 0x01); // YES: 闹铃时鸣叫      NO:不鸣叫
        BOOL isLightWhenClock       = !(BOOL)((bytes[12] >> 1) & 0x01);// YES: 闹铃时闪烁      NO:不闪烁
        BOOL isShockWhenCalling     = !(BOOL)((bytes[12] >> 2) & 0x01);// YES:来电震动         NO: 不震动
        BOOL isLightWhenCalling     = !(BOOL)((bytes[12] >> 3) & 0x01);// YES:来电闪烁         NO: 不闪烁
        
        BOOL isShockWhenTarget      = !(BOOL)((bytes[11] >> 4) & 0x01);// YES: 达到目标震动    NO:不震动
        BOOL isLightWhenTarget      = !(BOOL)((bytes[11] >> 5) & 0x01);// YES: 达到目标闪烁    NO:不闪烁
        BOOL isShockWhenLowPower    = !(BOOL)((bytes[11] >> 6) & 0x01);// YES: 低电震动        NO:不震动
        BOOL isLightWhenLowPower    = !(BOOL)((bytes[11] >> 7) & 0x01);// YES: 低电闪烁        NO:不闪烁
        
        
        BOOL isShockWhenDisconnect  = !(BOOL)((bytes[11]) & 0x01);// YES: 断开蓝牙震动    NO:不震动
        BOOL isLightWhenDisconnect  = !(BOOL)((bytes[11] >> 1) & 0x01);// YES: 断开蓝牙闪烁    NO:不闪烁
         */
        
        int length = 20;
        char data[length];
        if (!arr)
        {
            UserInfo *userinfo = myUserInfo;
            height                 = [userinfo.user_height intValue];
            weight                 = [userinfo.user_weight intValue];
            gender                 = [userinfo.user_gender boolValue] ? 0 : 1;
                                                    // 硬件协议上  0：女  1 ： 男  本地是 是 1 女  0 男
            scene                  = 0;
            year                   = [userinfo.user_birthday getFromDate:1];
            month                  = [userinfo.user_birthday getFromDate:2];
            day                    = [userinfo.user_birthday getFromDate:3];
            goal                   = [userinfo.user_sport_target intValue];
            isShowDate             = [userinfo.swithShowMenu boolValue] ? 1:0;
            iS24                   = [DFD isSysTime24] ? 0:1;
            isShockWhenButtonClick = 1;
            isLightWhenCharging    = 1;
            isMetric               = [userinfo.unit boolValue] ? 0:1;
            isChinese              = [DFD getLanguage] == 1  ? 0:1;
            isLightWhenPutUp       = [userinfo.swithShowSreenWhenPut boolValue] ? 1:0;
            isDateStyle            = (([DFD getLanguage] == 1)  == [userinfo.unit boolValue]) ? 1:0;
            isShockWhenClock       = 0;
            isLightWhenClock       = 0;
            isShockWhenCalling     = 0;
            isLightWhenCalling     = 0;
            isShockWhenTarget      = 0;
            isLightWhenTarget      = 0;
            isShockWhenLowPower    = 0;
            isLightWhenLowPower    = 0;
            isShockWhenDisconnect  = isLightWhenDisconnect = [userinfo.swithShockWhenDisconnect boolValue] ? 0:1;
        }
        else
        {
            /*
             NSArray *arr = @[ @(user_height),
             1@(user_weight),
             2@(user_gender),
             3@(user_scene),
             4@(user_year),
             5@(user_month),
             6@(user_day),
             7@(user_goal),
             8@(isShowDate),                          // 这个不参与判断
             9@(user_is24),
             10@(user_isShockWhenButtonClick),
             11@(user_isLightWhenCharging),
             12@(user_isMetric),
             13@(user_isChinese),
             14@(isLightWhenPutUp),              // 这个不参与判断
             15@(user_isDateStyle),
             16@(user_isShockWhenClock),
             17@(user_isLightWhenClock),
             18@(user_isShockWhenCalling),
             19@(user_isLightWhenCalling),
             20@(user_isShockWhenTarget),
             21@(user_isLightWhenTarget),
             22@(user_isShockWhenLowPower),
             23@(user_isLightWhenLowPower),
             24@(isShockWhenDisconnect),    // 这个不参与判断
             25@(isLightWhenDisconnect)     // 这个不参与判断
             ];
             */
            
            
            height                 = [arr[0] intValue];
            weight                 = [arr[1] intValue];
            gender                 = [arr[2] boolValue] ? 0 : 1;
            scene                  = [arr[3] intValue];
            year                   = [arr[4] intValue];
            month                  = [arr[5] intValue];
            day                    = [arr[6] intValue];
            goal                   = [arr[7] intValue];
            
            isShowDate             = [arr[8] boolValue]     ? 1:0;
            iS24                   = ![arr[9] boolValue]    ? 1:0;
            isShockWhenButtonClick = [arr[10] boolValue]    ? 1:0;
            isLightWhenCharging    = [arr[11] boolValue]    ? 1:0;
            
            isMetric               = ![arr[12] boolValue]   ? 1:0;
            isChinese              = ![arr[13] boolValue]   ? 1:0;
            isLightWhenPutUp       = [arr[14] boolValue]    ? 1:0;
            isDateStyle            = [arr[15] boolValue]    ? 1:0;
            
            isShockWhenClock       = ![arr[16] boolValue]   ? 1:0;
            isLightWhenClock       = ![arr[17] boolValue]   ? 1:0;
            isShockWhenCalling     = ![arr[18] boolValue]   ? 1:0;
            isLightWhenCalling     = ![arr[19] boolValue]   ? 1:0;
            
            isShockWhenTarget      = ![arr[20] boolValue]   ? 1:0;
            isLightWhenTarget      = ![arr[21] boolValue]   ? 1:0;
            isShockWhenLowPower    = ![arr[22] boolValue]   ? 1:0;
            isLightWhenLowPower    = ![arr[23] boolValue]   ? 1:0;
            
            isShockWhenDisconnect  = isLightWhenDisconnect = ![arr[24] boolValue]    ? 1:0;
        }
        

        data[0]    = DataFirst;
        data[1]    = height & 0xFF;
        data[2]    = weight & 0xFF;
        data[3]    = gender & 0xFF;
        data[4]    = scene & 0xFF;
        data[5]    = (year >> 8) & 0xFF;
        data[6]    = year & 0xFF;
        data[7]    = month & 0xFF;
        data[8]    = day & 0xFF;
        data[9]    = (goal >> 8) & 0xFF;
        data[10]   = goal & 0xFF;
        
        
        
        data[11]   = ((isShowDate                    ) |
                     ((iS24                     << 1)) |
                     ((isShockWhenButtonClick   << 2)) |
                     ((isLightWhenCharging      << 3)) |
                     ((isMetric                 << 4)) |
                     ((isChinese                << 5)) |
                     ((isLightWhenPutUp         << 6)) |
                     ((isDateStyle              << 7)) ) & 0xFF;
        data[12]   = ((isShockWhenClock              ) |
                     ((isLightWhenClock         << 1)) |
                     ((isShockWhenCalling       << 2)) |
                     ((isLightWhenCalling       << 3)) |
                     ((isShockWhenTarget        << 4)) |
                     ((isLightWhenTarget        << 5)) |
                     ((isShockWhenLowPower      << 6)) |
                     ((isLightWhenLowPower      << 7)) ) & 0xFF;
        data[13]   = ((isShockWhenDisconnect         ) |
                     ((isLightWhenDisconnect    << 1)) ) & 0xFF;
        
        data[14] = data[15] = data[16] = data[17] = data[18] = DataOOOO;
        
        data[length - 1] = [self getCheck:data length:length];
        
        NSData *dataPush = [NSData dataWithBytes:data length:length];
        [self Command:dataPush uuidString:uuidString charaUUID:A5_RW_UseInfoAndSystem_UUID];
    }
}


// 设置闹钟   是否是前四个   //  这里 为了保证硬件数据安全， 要发送两条
-(void)setClock:(NSString *)uuidString
{
    DDWeak(self)
    NextWaitInGlobal(
         DDStrong(self);
         [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
          {
              NSArray *arrClock = [Clock findAllSortedBy:@"iD" ascending:YES inContext:localContext];
              NSArray *arrClock1 = [arrClock subarrayWithRange:NSMakeRange(0, 4)];
              NSArray *arrClock2 = [arrClock subarrayWithRange:NSMakeRange(4, 4)];
              [self setClockNext:arrClock1 uuidString:uuidString isFirst:YES];
              sleep(0.4);
              [self setClockNext:arrClock2
                      uuidString:uuidString
                         isFirst:NO];
          }];);
}


-(void)setClockNext:(NSArray *)arrClock
         uuidString:(NSString *)uuidString
            isFirst:(BOOL)isFirst
{
    int length = 19;
    char data[length];
    data[0] = DataFirst;
    data[1] = isFirst? 0x00:0x01;
    
    for (int i = 0; i < 4; i++)
    {
        Clock *cl = arrClock[i];
//        NSLog(@"检测 : cl.isOn = %@, %@, 时间：%@, type : %@ hour:%@ minute:%@ 重复：%@", cl.isOn, cl.strRepeat, cl.strTime, cl.type, cl.hour, cl.minute, cl.repeat);
        data[i * 4 + 2] = [cl.type intValue] & 0xFF;
        NSArray *arr = [cl.repeat componentsSeparatedByString:@"-"];
        data[i * 4 + 3] = (([cl.isOn intValue] << 7) |
                           ([arr[0] intValue] << 6) |
                           ([arr[1] intValue] << 5) |
                           ([arr[2] intValue] << 4) |
                           ([arr[3] intValue] << 3) |
                           ([arr[4] intValue] << 2) |
                           ([arr[5] intValue] << 1) |
                           [arr[6] intValue] ) & 0xFF;
        data[i * 4 + 4] = [cl.hour intValue] & 0xFF;
        data[i * 4 + 5] = [cl.minute intValue] & 0xFF;
    }
    data[length - 1] = [self getCheck:data length:length];
    NSData *dataPush = [NSData dataWithBytes:data length:length];
    [self Command:dataPush uuidString:uuidString charaUUID:![DFD shareDFD].isForA5 ? RW_Clock_UUID:A5_RW_Clock_UUID];
}


- (void)readSportAgain:(NSString *)uuid
{
    self.LastDateSys = DNow;
    [self readChara:uuid charUUID:RW_Sport_UUID];
}



-(void)readName: (NSString *)uuidString
{
    [self readChara:uuidString charUUID:R_Name_UUID];
}





@end
