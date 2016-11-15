//
//  BLEManager.h
//  BLE
//
//  Created by 丁付德 on 15/5/24.
//  Copyright (c) 2015年 丁付德. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSData+ToString.h"

// 蓝牙协议
@protocol BLEManagerDelegate <NSObject>  // 回调函数


@optional // -------------------------------------------------------  根据需要实现的代理方法（ 可以不实现 ）
/**
 *  扫描到的设备字典
 *
 *  @param recivedTxt 字典： key ： uuidString  value: CBPeripheral(设备)
 */
-(void)Found_CBPeripherals:(NSMutableDictionary *)recivedTxt;

// ------------------------------------------------------- 蓝牙的系统回调

/**
 *  连接上设备的回调
 *
 *  @param uuidString 设备的uuidString
 */
-(void)CallBack_ConnetedPeripheral:(NSString *)uuidString;


/**
 *  断开了设备的回调
 *
 *  @param uuidString 设备的uuidString
 */
-(void)CallBack_DisconnetedPerpheral:(NSString *)uuidString;


// ------------------------------------------------------- 根据业务的需要，自定义的回调

/**
 *  业务回调
 *
 *  @param uuidString 设备的uuidString
 *
 *  @param uuidString
 */
-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj;



@end

@interface BLEManager : NSObject
{
    NSMutableDictionary *dic;                //  过滤后的蓝牙设备  key:uuidString  value: CBPeripheral_D 对象
    
    NSDate *beginDate;                       //  私有时间日期，用于记录重发，和重连  时间比较
    
    NSInteger num;                           //  私有次数变量，用于记录重发，和重连  次数比较
    
    NSTimer *timeRealTime;                   //  实时监控循环器
    
    NSTimer *timeCall;                       //  来电闹钟循环器
    
    NSMutableArray *shieldCountOfDay;        //  屏蔽那些下标的数据 用于读取大数据时，相关下标数据再来的时候舍弃
    
    BOOL isOnlySetClock;                     //  是否只是设置闹钟
    
    BOOL isOnlySetUserInfo;                  //  是否只是设置用户信息
    
    NSInteger todayIndexInSysData;           //  今天在数据中的索引
    
    NSData *data807ExceptToday;              //  除了今天之外， 全部屏蔽的807数据
    
    BOOL isRest;
}

@property (nonatomic, strong) id<BLEManagerDelegate>      delegate;

@property (nonatomic, strong) CBCentralManager *        Bluetooth;              // 中心设备实例

@property (nonatomic, strong) NSMutableDictionary *     dicConnected;           // 连接中的设备集合  key:uuidString  value:连接的对象

@property (nonatomic, strong) CBPeripheral *            per;                    // 当前的设备处理对象

@property (nonatomic, copy)   NSString *                filter;                 //  过滤条件 （名字）

@property (nonatomic, assign) NSInteger                 connetNumber;           //  重连的次数

@property (nonatomic, assign) NSInteger                 connetInterval;         //  重连的时间间隔 （单位：秒）

@property (nonatomic, assign) NSInteger                 sendNumber;             //  重发的次数

@property (nonatomic, assign) NSInteger                 sendInterval;           //  重发的时间间隔 （单位：秒）

@property (nonatomic, assign) BOOL                      isFailToConnectAgain;   //  是否断开重连

@property (nonatomic, assign) BOOL                      isSendRepeat;           //  是否在没收到回复的时候 重新发送指令

@property (nonatomic, assign) BOOL                      isLock;                 //   加锁  用于读取数据过程中

@property (nonatomic, assign) BOOL                      isBeginOK;              //   是否正常开始了 （ 读时间是否有回来 ）

@property (nonatomic ,assign) BOOL                       isLink;                // 当前是否连接上  // nonatomic

@property (nonatomic ,assign) BOOL                       isOn;                  // 蓝牙是否开启

@property (nonatomic ,assign) BOOL                       isReRead;              // 是否重新设置屏蔽位

@property (nonatomic ,assign) BOOL                       isReadRealOnce;        // 读取实时数据一次

@property (nonatomic ,assign) int                        isResetLoadForIndex;   // 让主界面刷新一次 原始值 0

@property (nonatomic ,strong) NSDate *                   LastDateSys;           // 上一次大同步的时间



//实例化 单例方法
+ (BLEManager *)sharedManager;

+ (void)resetBLE;

//开始扫描 （ 初始化中心设备，会导致已经连接的设备断开 ）
-(void)startScan;

//开始扫描 （ 保持之前连接的对象 ）
-(void)startScanNotInit;

//连接设备
- (void)connectDevice:(CBPeripheral *)peripheral;

//主动断开的设备。如果为nil，会断开所有已经连接的设备
-(void)stopLink:(CBPeripheral *)peripheral;

//停止扫描
- (void)stopScan;

/**
 *  自动重连
 *
 *  @param uuidString uuidString
 */
-(void)retrievePeripheral:(NSString *)uuidString;

/// 开始整个流程
-(void)begin:(NSString *)uuid;

// 再次读取大数据
- (void)readSportAgain:(NSString *)uuid;

// 读取实时数据
- (void)realRealData:(NSString *)uuid;

// 设置闹钟   是否是前四个
-(void)setClock:(NSString *)uuidString;

// 读取闹钟
-(void)readClock:(NSString *)uuidString;

// 写入个人信息
-(void)setUserInfo:(NSString *)uuidString arr:(NSArray *)arr; //

// 设置用户 并读取
-(void)setUserinfoAndRead:(NSString *)uuidString;

-(void)readChara:(NSString *)uuidString charUUID:(NSString *)charUUID;


-(void)readName:(NSString *)uuidString;



@end
