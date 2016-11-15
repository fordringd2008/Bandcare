//
//  dConfig.h
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#ifndef aerocom_dConfig_h
#define aerocom_dConfig_h

#import <Availability.h>

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

#define isDevelemont                        1 // 是否是开发版   （发布版）
#define isOnlyFirst                         0 // 是否只有第一代    1：只有第一代   0：兼容第一代、第二代


#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
//#define NSLog(...) NSLog(@"%s 第%d行 -> %@",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define NSLog(...) {}
#endif


#define AppNameForServer                    @"bandcare"

#define RGBA(_R,_G,_B,_A)                   [UIColor colorWithRed:_R / 255.0f green:_G / 255.0f blue:_B / 255.0f alpha:_A]
#define RGB(_R,_G,_B)                       RGBA(_R,_G,_B,1)

// ------- 本地存储
#define GetUserDefault(key)                 [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define SetUserDefault(k, v)                [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]; [[NSUserDefaults standardUserDefaults]  synchronize];
#define RemoveUserDefault(k)                [[NSUserDefaults standardUserDefaults] removeObjectForKey:k]; [[NSUserDefaults standardUserDefaults] synchronize];

// ------- 提示
#define MBShowAll                  [MBProgressHUD showHUDAddedTo:self.windowView animated:YES];
#define MBShowAllWithText(_k)      [MBProgressHUD showHUDAddedTo:self.windowView animated:YES text:_k];
#define MBHide                     [MBProgressHUD hideAllHUDsForView:self.windowView animated:YES];
#define LMBShow(message)           [MBProgressHUD show:kString(message) toView:self.windowView];
#define HDDAF                      DDWeak(self) NextWaitInMainAfter(DDStrong(self);if(self)MBHide, 20);

// ------- 系统相关
#define IPhone4                    (ScreenHeight == 480)
#define IPhone5                    (ScreenHeight == 568)
#define IPhone6                    (ScreenHeight == 667)
#define IPhone6P                   (ScreenHeight == 736)


#define SystemVersion              [[[UIDevice currentDevice] systemVersion] doubleValue]  // 当前系统版本
#define IOS7Later                  (SystemVersion>=7.0)?YES:NO    // 系统版本是否是iOS7+
#define IS_IPad                    [[UIDevice currentDevice].model rangeOfString:@"iPad"].length > 0// 是否是ipad

// 中英文
#define kString(_S)               NSLocalizedString(_S, @"")

// ------- 宽高
#define ScreenHeight              [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth               [[UIScreen mainScreen] bounds].size.width
#define StateBarHeight            20//((IOS7Later)?20:0)
#define NavBarHeight              64//((IOS7Later)?64:44)
#define BottomHeight              49
#define RealHeight(_k)            ScreenHeight * (_k / 1280.0)
#define RealWidth(_k)             ScreenWidth * (_k / 720.0)
#define ScreenRadio               0.562 // 屏幕宽高比


#define ConentViewWidth           [UIScreenmainScreen].bounds.size.width   // bounds
#define ConentViewHeight          ((IOS7Later)?([UIScreen mainScreen].bounds.size.height - NavBarHeight):([UIScreen mainScreen].bounds.size.height - NavBarHeight -20))
#define MaskViewDefaultFrame      CGRectMake(0,NavBarHeight,ConentViewWidth,ConentViewHeight)
#define MaskViewFullFrame         CGRectMake(0,0,ConentViewWidth,[UIScreen mainScreen].bounds.size.height-20)

// ------- 控件相关
#define dHeightForBigView          200
#define dCellHeight                44
#define dTextSize(_key)            [UIFont systemFontOfSize:_key]

#define myUserInfo                          [DFD getUserInfo]
#define myUserInfoAccess                    GetUserDefault(userInfoAccess)
#define NavButtonFrame                      CGRectMake(0, 0, 20, 20)

#define KgToLb                              0.4532
#define CmToFt                              0.0328             // cm -> ft 英尺
#define Picture_Limit_KB                    100
#define DefaultLogo                         @"person_default"
#define DefaultLogo_boy                     @"boy_default"
#define DefaultLogo_girl                    @"girl_default"
#define CurrentLanguage                     @"CurrentLanguage"
#define JPushBindLanguage                   @"JPushBindLanguage"    // 极光绑定的语言
#define LoadImage                           @"logo"
#define DefaultLogoImage                    [UIImage imageNamed:DefaultLogo]
#define LoadingImage                        [UIImage imageNamed:LoadImage]

#define NONetTip                            @"网络异常,请检查网络"
#define NOConnect                           @"请先连接手环"

#define CheckIsOK                           [dic[@"status"] isEqualToString:@"0"]


#define DDWeak(type)                        __weak typeof(type) weak##type = type;
#define DDStrong(type)                      __strong typeof(type) type = weak##type;
#define DDDWeak(type)                       __weak typeof(type) weakd##type = type;     // 防止重复
#define DDDStrong(type)                     __strong typeof(type) type = weakd##type;

#define RequestCheckBefore(_k1, _k2, _k3)   DDWeak(self)[NetManager DF_requestWithAction:^(NetManager *net) {DDStrong(self) if(self){_k1}} success:^(NSDictionary *dic) {DDStrong(self) if(self){_k2}} failError:^(NSError *erro) {_k3} inView:self.windowView isShowError:NO];

#define RequestCheckAfter(_k1, _k2)         DDWeak(self)[NetManager DF_requestWithAction:^(NetManager *net) {DDStrong(self) if(self){_k1}} success:^(NSDictionary *dic) {DDStrong(self)  if(self){_k2}} failError:^(NSError *erro) {} inView:self.windowView isShowError:YES];

#define RequestCheckNoWaring(_k1, _k2)      DDWeak(self)[NetManager DF_requestWithAction:^(NetManager *net) {DDStrong(self) if(self){_k1}} success:^(NSDictionary *dic) {DDStrong(self)  if(self){_k2}} failError:^(NSError *erro) {} inView:self.windowView isShowError:NO];

#define NextWaitInMain(_k)                  [DFD performBlockInMain:^{ _k }]
#define NextWaitInMainAfter(_k, _v)         [DFD performBlockInMain:^{ _k } afterDelay:_v]

#define NextWaitInCurrentTheard(_k, _v)     [DFD performBlockInCurrentTheard:^{ _k } afterDelay:_v]

#define NextWaitInGlobal(_k)                [DFD performBlockInGlobal:^{ _k }]
#define NextWaitInGlobalAfter(_k, _v)       [DFD performBlockInGlobal:^{ _k } afterDelay:_v]


#define LastSysDateTime                     (NSDate *)(GetUserDefault(LastSysDateTimeData)[myUserInfoAccess])  // 获取上次更新时间


#define DDYear                              [DNow getFromDate:1]       // 当前的年份
#define DDMonth                             [DNow getFromDate:2]       // 当前的月份
#define DDDay                               [DNow getFromDate:3]       // 当前的日
#define DDHour                              [DNow getFromDate:4]       // 当前的时
#define DDMinute                            [DNow getFromDate:5]       // 当前的分
#define DDSecond                            [DNow getFromDate:6]       // 当前的秒

#define plantNameLength                     20                       // 字节不能超过20

#define DidSitupColor                       RGB(35,162,125)             // 仰卧起坐的颜色
#define DidSleepColor                       RGB(38,36,83)               // 睡眠的颜色
#define DidConnectColor                     RGB(51,153,170)             // 已连接的颜色  步数的颜色
#define DidDisconnectColor                  RGB(53,63,81)               // 未连接的颜色
#define GirlColor                           RGB(252,132,247)            // 粉色
#define DLightGrayBlackGroundColor          RGBA(240,240,240,1)
#define DButtonHighlight                    RGB(42, 126, 153)
#define SelectedColor                       RGB(250, 131, 20)



#define DWhite3                             [UIColor colorWithWhite:255 alpha:0.3]
#define Bigger(_a, _b)                      ((_a) > (_b) ? (_a) : (_b))
#define Smaller(_a, _b)                     ((_a) < (_b) ? (_a) : (_b))

#define Border(_label, _color)              _label.layer.borderWidth = 1; _label.layer.borderColor = _color.CGColor;

#define TipsListPangeCount                  10


// 默认图片地址
#define DEFAULTIMAGEADDRESS                 @"ios"
#define DEFAULTIMG                          [UIImage imageNamed:DEFAULTIMAGEADDRESS]

#define DEFAULTLOGOADDRESS                  @"thedefault"
#define DEFAULTTHTDEFAULT                   [UIImage imageNamed:DEFAULTLOGOADDRESS]


#define DBefaultContext                     [NSManagedObjectContext MR_defaultContext]
#define DBSave                              [DBefaultContext MR_saveToPersistentStoreAndWait];
#define DLSave                              [localContext MR_saveToPersistentStoreAndWait];

//  ------------------------------------------------------------  常用颜色 -----
#define DWhite                              [UIColor whiteColor]
#define DRed                                [UIColor redColor]
#define DGreen                              [UIColor greenColor]
#define DBlue                               [UIColor blueColor]
#define DBlack                              [UIColor blackColor]
#define DYellow                             [UIColor yellowColor]
#define DBlack                              [UIColor blackColor]
#define DClear                              [UIColor clearColor]
#define DLightGray                          [UIColor lightGrayColor]
#define DWhiteA(_k)                         [UIColor colorWithWhite:255 alpha:_k]
#define DNow                                [NSDate date]

#define ISFISTRINSTALL                      @"ISFISTRINSTALL"   // 第一次运行标记
#define UserUnit                            @"UserUnit"
#define SystemPromptBegin                   @"SystemPromptBegin"
#define SystemPromptFinish                  @"SystemPromptFinish"
#define RangeUnit                           @"RangeUnit"
#define TemperatureUnit                     @"TemperatureUnit"
#define Latitude_Longitude                  @"Latitude_Longitude"
#define IsGetUserAddress                    @"IsGetUserAddress"
#define IndexData                           @"IndexData"     // 字典 ： key : access  value: 数组 0：天 1：步数 2 距离 3 热量 4 有变化 5，仰卧起坐个数 6 跳绳 7 游泳
#define isFirstSys                          @"isFirstSys"                   // 默认为1   每次进入app的时候同步 同步完改为0
#define RemindCount                         @"RemindCount"                  // key flowerID string   value : 报警次数 numbe
#define CheckRemind                         @"CheckRemind"
#define HelpUrlVersion                      @"HelpUrlVersion"
#define isNotRealNewBLE                     @"isNotRealNewBLE"              //默认为O  在index设置为1
#define BLEisON                             @"BLEisON"
#define IsLogined                           @"IsLogined"// 是否登录过每次打开APP， 都要重新登录 YES 登录过  NO 没有
#define LastSysDateTimeData                 @"LastSysDateTimeData"          // 上次同步的时间  字典 key: access value: 时间
#define LastUpLoadDateTimeData              @"LastUpLoadDateTimeData"       // 上次上传服务器时间  字典 key: access value: 时间
#define DFD_Notif_LongTime                  @"DFD_Notif_LongTime"           // 本地推送 3天不登陆的推送
#define DFD_Notif_Clock                     @"DFD_Notif_Clock"              // 一次性闹钟提醒
#define is24                                @"is24"
#define NewPushData                         @"NewPushData"      //有新的推送消息
#define IndexFirstLoad                      @"IndexFirstLoad"   //首页的第一次加载
#define dicRemindWater                      @"dicRemindWater"   // 喝水提醒  key: uuid  value: NSArray[2] 1:工作日 2: 休息日
#define userInfoAccess                      @"userInfoAccess"
#define PushAlias                           @"PushAlias"
#define userInfoData                        @"userInfoData"     // key ：access  value: 数组：0: email 1:密码 2：uerid
                                                                // value:0 email 或者 电话 或者第三方ID
                                                                // value:1 密码
                                                                // value:2 uerid
                                                                // value:3 登陆的类型 0 邮箱 1 电话 2 QQ 3 微博 4 face 5 twi

#define BraceletSystem                      @"BraceletSystem"   // 手环一代(1)，手环二代(2) 在选择手环的时候，还有蓝牙连接的时候赋值
#define JPushBind                           @"JPushBind"        // 本地表示，nil：未绑定

#define readBLEBack                         @"readBLEBack"    // 新数据更新
#define DNet                                @"DNet"           // 网络更新
#define IndexTabelReload                    @"IndexTabelReload"     // 强制首页刷新
#define isTag_                              @"isTag_"
#define isSynDataOver                       @"isSynDataOver"     // 同步结束
#define dateLastPostSMS                     @"dateLastPostSMS"   // 数组 0：5856 2： 上一次发短信的时间 3，第几次
#define MdIndexData                         @"MdIndexData"       // 字典 key:access+8964(日期) value:
                                                                 // NSDate类型 (model_half,model_All,model_sleep,model_heat,model_continue)
#define SynHistoryDataForLeftStep           @"SynHistoryDataForLeftStep" 
#define ExitUserOnce                        @"ExitUserOnce"     // 退出登录标示符 用于拉去首页第一次数据



//  ------------------------------------------------------------  首页列表图片   -----

#define MDIndexType1                        @"water"
#define MDIndexType2                        @"water"
#define MDIndexType3                        @"news_01"
#define MDIndexType4                        @"remind"
#define MDIndexType5                        @"news_01"
#define MDIndexType6                        @"news_01"
#define GoodSleepMsg                        kString(@"昨天晚上睡的非常好哟!")
#define BadSleepMsg                         kString(@"昨天晚上睡的不怎么好哟!")

#define DeletedLevelFirMsg                  kString(@"您消耗的热量相当于一碗米饭。")
#define DeletedLevelSecMsg                  kString(@"您消耗的热量相当于一瓶可乐。")
#define DeletedLevelThiMsg                  kString(@"您消耗的热量相当于一盘牛肉。")
#define DeletedLevelForMsg                  kString(@"您消耗的热量相当于两盘牛肉。")
#define DeletedLevelFifMsg                  kString(@"您消耗的热量相当于三盘牛肉。")
#define DeletedLevelSixMsg                  kString(@"您消耗的热量相当于四盘牛肉。")
#define DeletedLevelSevMsg                  kString(@"您消耗的热量相当于五盘牛肉。")
#define DeletedLevelEigMsg                  kString(@"您消耗的热量相当于六盘牛肉。")
#define DeletedLevelNinMsg                  kString(@"您消耗的热量相当于七盘牛肉。")
#define DeletedLevelTenMsg                  kString(@"您消耗的热量相当于八盘牛肉。")



#define orReaderPrefix                      @"http://www.sz-hema.com/download"

//  ------------------------------------------------------------  第三方配置 -----


#define ShareID                             @"10254862e02bb"                                        //
#define ShareSecret                         @"e636b81b2f1138354517a7e44a81bb3b"
#define SMSAppKey                           @"102558edc4fe0"                                        // OK
#define SMSAppSecret                        @"184f541ad9aa1103c4cb4d41592317b2"                     //
#define APPID                               1089456223                                              // OK
#define ShareContent                        @""                                                     //
#define ShareDescription                    @""                                                     //
#define ShareUrl                            @"http://www.sz-hema.com/"                              //
#define SinaKEY                             @"2947068316"                                           // 已OK
#define SinaSECRET                          @"bb51f5693275a27e220f9601c1e9f612"                     //
#define SinaURL                             ShareUrl                                                //
#define QQKEY                               @"1105159301"   // QQ41DF6485                           // 已OK
#define QQSECRET                            @"elRC66DerdgLkPpT"                                     //
#define WeiXinKEY                           @"wx730362253a1461c3"                                   // 已OK
#define WeiXinSECRET                        @"9a71a53aa53ed05d7f3003f1ee3f798d"                     //
#define TwitterKEY                          @"vXNFq6tsW9vjSGCIwS1PMWbGa"                            // 已OK
#define TwitterSECRET                       @"GC6S26wzK9NOzhju1f2dotCqxcc6vlWfOGsPinTrkfLqVWPfVg"   //
#define FacebookKEY                         @"1013503165354484"                                     // 已OK
#define FacebookSECRET                      @"0efa20419b31e0aeae76e52b167269d1"                     //
#define JPushKEY                            @"b863db6f711ac4e6f21d67ea"                             // 已OK
#define JPushSECRET                         @"37b20d9694ed85c2fb5f967c"                             //
#define BugTagsAppKey                       @"6721dc290745432a68b8ea6e4f89ae50"
#define BugTagsSecret                       @"cce614f59e13e82e252c417f6512a884"
#define JSPatchKey                          @"4fdadb940b9e1885"              // 1.4 版本
#define UMengKey                            @"571adddfe0f55a3ce0000d7f"


#endif
