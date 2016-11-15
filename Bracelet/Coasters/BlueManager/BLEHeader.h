//
//  BLEHeader.h
//  MasterDemo
//
//  Created by 丁付德 on 15/6/25.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#ifndef aerocom_BLEHeader_h
#define aerocom_BLEHeader_h

//*************************************************************************************

//--------------------------------------   UUID(统一大写写)   -------------------------- A3版本

//*************************************************************************************


#define ServerUUID                                      @"FF03"             // 主服务UUID

#define R_Name_UUID                                     @"F300"             // 读取设备名称

#define RW_Pair_UUID                                    @"F301"             // 读取配对信息

#define R_HardwareVersionNumber_UUID                    @"F302"             // 读取硬件和软件版本号

#define RW_UserInfo_UUID                                @"F303"             // 读写个人信息

#define RW_Sport_UUID                                   @"F304"             // 读取运动数据(一小时一条记录)

#define R_MAC_UUID                                      @"F305"             // 读取MAC地址和产品序列号

#define RW_DateTime_UUID                                @"F306"             // 读写日期时间

#define RW_Clock_UUID                                   @"F307"             // 读写闹钟设置

#define W_SpecialAlarm_UUID                             @"F308"             // 特殊警报

#define R_RealData_UUID                                 @"F309"             // 实时信息

//--------------------------------------   UUID(统一大写写)   -------------------------- A5版本

#define A5_ServerUUID                                      @"FF08"             // 主服务UUID

#define A5_R_Name_UUID                                     @"F800"             // 读取设备名称

#define A5_R_HardwareVersionNumber_UUID                    @"F801"             // 读取硬件和软件版本号

#define A5_RW_Special_UUID                                 @"F802"             // 特殊控制

#define A5_RW_DateTime_UUID                                @"F803"             // 读写日期时间

#define A5_RW_UseInfoAndSystem_UUID                        @"F804"             // 读写个人设置与系统设置

#define A5_RW_Clock_UUID                                   @"F805"             // 读写闹钟设置

#define A5_R_EveryDayDataAbout_UUID                        @"F806"     // 读取每日概况(DATE ABOUT),每天一条数据.

#define A5_R_DayCounter_UUID                               @"F807"             // 读取日更新计数器列表.

#define A5_W_DayShield_UUID                                @"F807"             // 设置步行数据日屏蔽标识.    屏蔽位

#define A5_R_TodayDataAbout_UUID                           @"F808"        // 读取当日概况(DATE ABOUT),仅一条数据.

#define A5_R_StepAndDistanceAndHeat_UUID                   @"F80A"             // 读取步行数据.含步数,距离,热量三者

#define A5_R_Step_Step_UUID                                @"F80B"             // 读取步行数据之步数.

#define A5_R_Step_Distance_UUID                            @"F80C"             // 读取步行数据之距离.

#define A5_R_Step_Heat_UUID                                @"F80D"             // 读取步行数据之热量.

// 下面是全部的集合
#define Arr_R_UUID                                      @[ R_Name_UUID, RW_Pair_UUID, R_HardwareVersionNumber_UUID, RW_UserInfo_UUID,RW_Sport_UUID, R_MAC_UUID, RW_DateTime_UUID, RW_Clock_UUID, W_SpecialAlarm_UUID, R_RealData_UUID ]

#define A5_Arr_R_UUID     @[ A5_R_Name_UUID, A5_R_HardwareVersionNumber_UUID, A5_RW_Special_UUID, A5_RW_DateTime_UUID, A5_RW_UseInfoAndSystem_UUID, A5_RW_Clock_UUID, A5_R_EveryDayDataAbout_UUID, A5_R_DayCounter_UUID, A5_R_TodayDataAbout_UUID, A5_R_StepAndDistanceAndHeat_UUID, A5_R_Step_Step_UUID, A5_R_Step_Distance_UUID, A5_R_Step_Heat_UUID]

//*************************************************************************************

//--------------------------------------  设备名称   ----------------------------------

//*************************************************************************************


#define Filter_Name                                    @"Glamor-"
#define Filter_Other_Name                              @"Cupcare-"
#define A5_Filter_Name                                 @"HmBracelet-"

#define dataInterval                                    1.2                // 时间间隔


//*************************************************************************************

//--------------------------------------    数据     ----------------------------------

//*************************************************************************************



#define DataFirst                                       0xF5
#define DataOOOO                                        0x00






#endif
