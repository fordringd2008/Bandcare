//
//  vcIndex.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcIndex.h"
#import "vcLeft.h"
#import <QuartzCore/QuartzCore.h>
#import "tvcIndex.h"
#import "MdIndex.h"
#import "NSString+ToString.h"
#import "NSMutableArray+Sort.h"
#import "vcChart.h"
#import "LineProgressView.h"
#import "CircleView.h"
#import "DFToAppStore.h"

#define tableViewHeight                             Bigger(RealHeight(100), 50)

#define circleDefaultFrame   CGRectMake((ScreenWidth  - RealWidth(280)) / 2, 0, RealWidth(280), RealWidth(280))
#define circleDefaultCenter  CGPointMake(self.viewHeadCircleChart.center.x, self.viewHeadCircleChart.center.y * lblPromptHeightRadio)


void *vcIndexObserver = &vcIndexObserver;

const NSInteger segmentMiniTopInsetValue   = 128;
const CGFloat   lblPromptHeightRadio       = 0.75;
CGFloat   radioInScreenHeight              = 0.4;


@interface vcIndex ()<vcLeftDelegate, UITableViewDelegate, UITableViewDataSource, tvcIndexDelegate, UIAlertViewDelegate, UIScrollViewDelegate>
{
    int                     stepNumber;                  // 当前的总步数
    int                     sleepNumber;                 // 当前睡眠的时长(小时)
    int                     sitUpNumber;                 // 当前仰卧起坐个数   // 1个仰卧起坐=0.24千卡
    int                     situpNumber;                 // 仰卧起坐
    
    int                     lastStepNumber;              // 当前的总步数                              上次的
    int                     lastSleepNumber;             // 当前睡眠的时长(小时)
    int                     lastSitUpNumber;             // 当前仰卧起坐个数   // 1个仰卧起坐=0.24千卡
    
    NSTimer *               timerM;                      // 循环读取硬件数据
    NSTimer *               timerU;                      // 循环读取ChanelID 和 推送数据
    MdIndex *               mmd;                         // 当前操作对象
    BOOL                    isGetApply;                  // 是否已经拉去了好友申请
    BOOL                    isLeft_index;                // 是否离开
    MdIndex *               lastMd;                      // 上一次的数据源的第一个模型  用于高亮
    BOOL                    isTableFirstLineHightLight;  // 第一条是否高亮
    BOOL                    isFirstLoad;                 // 是否是第一次显示
    UIView *                viewMask;                    // 遮罩
    BOOL                    isLoadOK;                    // 是否初始化界面， 网络，数据完成， 防止过急跳转崩溃
    BOOL                    isListChange;                // 列表数据有变化 用于刷新列表
    
    UILabel *               _lblRemind;                  // 今日的喝水总量
    NSInteger               countInTab;                  // tableView的总行数
    
    NSTimer *               timerAutoLink;               // 连接循环器
    CGFloat                 alpha;                       // 当前的透明度
    CGFloat                 inset;                       // 偏移量
    
    int                     numberInHeaderView;          // 头部视图中的个数
    CGFloat                 headerHeightTag;             // 减去头部后的高度
    NSTimer *               timerSys;                    // 同步的循环计时器
    int                     pointsSys;                   // 同步中，标题中点的个数
    
    //  比例
    CGFloat                 centerYCirle;
    CGFloat                 centerYTypeTitle;
    CGFloat                 centerYNumber;
    CGFloat                 centerYImv;
    CGFloat                 centerYOtherNumber;
    BOOL                    isDefaultFrame;              // 当前是否是默认视图
    
    MdIndex *               model_half;
    MdIndex *               model_All;
    MdIndex *               model_leftStep;
    MdIndex *               model_sleep;
    MdIndex *               model_heat;
    MdIndex *               model_continue;
}


@property (assign, nonatomic) CGFloat                       percent;                             // 0 - 100 当前的百分比
@property (assign, nonatomic) CGFloat                       percent3;                            // 0 - 100 当前的百分比

@property (nonatomic, strong) NSTimer *                     theTimer;
@property (nonatomic, assign) float                         motionLastYaw;
@property (nonatomic, strong) UILabel *                     lblRemind;                           // 今日的喝水总量
@property (nonatomic, strong) NSMutableArray *              arrData;                             // 数据源

@property (nonatomic, strong) UIView<ARSegmentPageControllerHeaderProtocol>  *viewHeadCircleChart; //   头部视图
@property (nonatomic, strong) UIScrollView *                                    scvHeadContent;    // 头部滚动视图
@property (nonatomic, strong) UIPageControl *               pageControl;       //
@property (nonatomic, strong) UIView *                      viewLeft;
@property (nonatomic, strong) UIView *                      viewMiddle;
@property (nonatomic, strong) UIView *                      viewRight;
@property (nonatomic, strong) LineProgressView *            lpLeft;
@property (nonatomic, strong) LineProgressView *            lpMiddle;
@property (nonatomic, strong) LineProgressView *            lpRight;

@property (nonatomic, strong) CircleView *                  cirleLeft;
@property (nonatomic, strong) CircleView *                  cirleMiddle;
@property (nonatomic, strong) CircleView *                  cirleRight;



// 步数的布局控件
@property (nonatomic, strong) UIImageView  *                imvTypeLeft;            // 跑步 睡眠 仰卧起坐 图片
@property (nonatomic, strong) UILabel  *                    lblTypeTitleLeft;       // 跑步 睡眠 仰卧起坐 文字
@property (nonatomic, strong) UILabel  *                    lblNumberLeft;          // 中间的数字
@property (nonatomic, strong) UILabel  *                    lblNumberUnitLeft;      // 中间的数字 后面的单位
@property (nonatomic, strong) UILabel  *                    lblOtherNumberLeft;     // 0米 | 0千卡

@property (nonatomic, strong) UIImageView  *                imvTypeMiddle;            // 跑步 睡眠 仰卧起坐 图片
@property (nonatomic, strong) UILabel  *                    lblTypeTitleMiddle;       // 跑步 睡眠 仰卧起坐 文字
@property (nonatomic, strong) UILabel  *                    lblNumberMiddle;          // 中间的数字
@property (nonatomic, strong) UILabel  *                    lblNumberUnitMiddle;      // 中间的数字 后面的单位
@property (nonatomic, strong) UILabel  *                    lblOtherNumberMiddle;     // 0米 | 0千卡

@property (nonatomic, strong) UIImageView  *                imvTypeRight;            // 跑步 睡眠 仰卧起坐 图片
@property (nonatomic, strong) UILabel  *                    lblTypeTitleRight;       // 跑步 睡眠 仰卧起坐 文字
@property (nonatomic, strong) UILabel  *                    lblNumberRight;          // 中间的数字
@property (nonatomic, strong) UILabel  *                    lblNumberUnitRight;      // 中间的数字 后面的单位
@property (nonatomic, strong) UILabel  *                    lblOtherNumberRight;     // 0米 | 0千卡


@property (nonatomic, strong) UITableViewController<ARSegmentControllerDelegate> * table;          //   tabaleView控制器


@end

@implementation vcIndex

@synthesize lpLeft;
@synthesize lpMiddle;
@synthesize lpRight;
@synthesize cirleLeft;
@synthesize cirleMiddle;
@synthesize cirleRight;


-(instancetype)init
{
    self.table = (UITableViewController<ARSegmentControllerDelegate> *)[[UITableViewController alloc] init];
    self.radioInScreenHeight = radioInScreenHeight;
    self.table.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.tableView.delegate = self;
    self.table.tableView.dataSource = self;
    self.table.tableView.showsVerticalScrollIndicator = NO;
    self = [super initWithControllers:self.table, nil];
    radioInScreenHeight = ScreenHeight * 0.5156 - NavBarHeight;
    if (self) {
        self.segmentMiniTopInset = segmentMiniTopInsetValue;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavTitle:self title:@"今日"];
    self.isPop = NO;
    self.navigationController.navigationBarHidden = NO;
    
    [self initLeftButton:@"menu" text:nil];
    [self initRightButton:@"cupcare-Data" text:nil];
    isDefaultFrame = YES;
    
    [self setVcLeftDelegate];
    
    isFirstLoad = YES;
    self.userInfo = myUserInfo;
    
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    isLeft_index = NO;
    isLoadOK = NO;
    isFirstLoad = YES;

    if (self.Bluetooth.isLink && self.userInfo.pUUIDString)
    {
        [self resetColor:YES];
        if(self.Bluetooth.isLock)
        {
            [self resetLv:YES];
        }
    }
    else
        [self resetColor:NO];
    
    if (![GetUserDefault(IsLogined) boolValue])
    {
        DDWeak(self)
        NextWaitInMainAfter([weakself nextLogin];, 1);
    }
    else [self getPushInfoList];

    [self addTarget];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        SetUserDefault(IndexTabelReload, @YES);
        [self refreshData];
        [self readIndexData];
        [self checkViewForBraceletSystem];
    });
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkUserInfo];
    
    timerM = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(readBLEData) userInfo:nil repeats:YES];
    timerU = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRealForChannelAndPushList) userInfo:nil repeats:YES];
    
    
    if (![GetUserDefault(ExitUserOnce) boolValue] && self.userInfo.access)
    {
        DDDWeak(self)
        NextWaitInGlobal(
             DDDStrong(self)
             RequestCheckNoWaring(
                      [net getFriendApplyList:self.userInfo.access];,
                      [self dataSuccessBack_getFriendApplyList:dic];););
    }
    
    
    static dispatch_once_t onceTokenUpdateVersion;
    dispatch_once(&onceTokenUpdateVersion, ^
    {
        [[[DFToAppStore alloc] initWithAppID:APPID] updateGotoAppStore:self];
    });
    
    viewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:viewMask];
    DDWeak(self)
    NextWaitInMainAfter([weakself removeViewMask];, 0.5);
}


- (void)viewWillDisappear:(BOOL)animated
{
    [timerM DF_stop];
    timerM = nil;
    [timerU DF_stop];
    timerU = nil;
    if (timerSys) {
        [timerSys DF_stop];
        timerSys = nil;
        [self setNavTitle:self title:@"今日"];
    }
    
    isLeft_index = YES;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.Bluetooth name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    @try
    {
        [self.Bluetooth removeObserver:self forKeyPath:@"isBeginOK"];
        [self.Bluetooth removeObserver:self forKeyPath:@"isLock"];
    }@catch(id anException){}
    
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    NSLog(@"---------------- init %@", DNow);
    NSLog(@"vcIndex 被销毁");
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)checkUserInfo
{
    if ([self.userInfo.isNeedUpdate boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kString(@"提示") message:kString(@"去完善个人资料?") delegate:self cancelButtonTitle:kString(@"使用默认") otherButtonTitles:kString(@"去完善"), nil];
        alert.tag = 1;
        [alert show];
    }
}

-(void)back
{
    if (self.Bluetooth.isLink && !self.Bluetooth.isBeginOK) return;
    if (isLoadOK)
    {
        YRSideViewController *sideViewController = [self.appDelegate sideViewController];
        [sideViewController showLeftViewController:true]; 
    }
}

-(void)rightButtonClick
{
    
#warning Test
//    [self.navigationController pushViewController:NSClassFromString(@"vcTest").new animated:YES];
//    [self.Bluetooth readName:self.userInfo.pUUIDString];
//    return;
    
    
    if (self.Bluetooth.isLink && !self.Bluetooth.isBeginOK) return;
    if(isLoadOK && !isLeft_index)
    {
        isLeft_index = YES;
        [self performSegueWithIdentifier:@"index_to_chart" sender:nil];
    }
}


-(void)removeViewMask
{
    [viewMask removeFromSuperview];
    isLoadOK = YES;
}

-(void)getPushInfoList
{
    long long interval = (long long)[[DFD getDateFromArr:[ @[ @0,@0,@0,@0 ] mutableCopy]] timeIntervalSince1970] * 1000;
    RequestCheckNoWaring(
          [net getPushInfoList:self.userInfo.access
                          time:interval];,
          [self dataSuccessBack_getPushInfoList:dic];);
}

-(void)addTarget
{
    [self.Bluetooth addObserver:self forKeyPath:@"isBeginOK" options:NSKeyValueObservingOptionNew context:nil];
    [self.Bluetooth addObserver:self forKeyPath:@"isLock" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"segmentToInset" options:NSKeyValueObservingOptionNew context:vcIndexObserver];
}


-(void)readIndexData
{
    if (isLeft_index)return;
    NSDictionary *dicIndexData = GetUserDefault(IndexData);
    
    BOOL isTodayHaveData = YES;
    
    if ([dicIndexData.allKeys containsObject:self.userInfo.access]) //  && self.userInfo.pUUIDString
    {
        NSArray *subArr = dicIndexData[self.userInfo.access];
        int day = [subArr[0] intValue];
        int step = [subArr[1] intValue];
        int dist = [subArr[2] intValue];
        float heat = [subArr[3] doubleValue];
        BOOL isChange = [subArr[4] boolValue];
        int situpCount, ropeSkippingCount,swimCount;
        situpCount = ropeSkippingCount = swimCount = 0;
        if([DFD shareDFD].isForA5)
        {
            situpCount        = [subArr[5] intValue];
            ropeSkippingCount = [subArr[6] intValue];
            swimCount         = [subArr[7] intValue];
        }
        
        if (day == [DNow getFromDate:3])
        {
            if (stepNumber != step || isChange || ([DFD shareDFD].isForA5 && sitUpNumber != situpCount))
            {
                self.isReadBLEChange = NO;
                NSDictionary *dicIndexData = @{ self.userInfo.access : @[ @(day), @(step), @(dist), @(heat), @NO ,@(situpCount),@(ropeSkippingCount),@(swimCount)] };
                SetUserDefault(IndexData, dicIndexData);
                
                
                BOOL isIncrease = (stepNumber == step) && (sitUpNumber == situpCount);
                stepNumber = step;
                sitUpNumber = situpCount;
                
                DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@ ", self.userInfo.access,  @(DDYear), @(DDMonth), @(DDDay)] inContext:DBefaultContext];
                dr.step_count = @(step);
                dr.situps_count = @(situpCount);
                dr.distance_count = @(dist); // 这里没有上传服务器， 等半个小时间隔读取的时候，有更新在上传
                dr.heat_count = @(heat);
                dr.isUpload = @(isIncrease);
                DBSave;
                
                self.percent = stepNumber / [self.userInfo.user_sport_target doubleValue] * 100;
                self.percent = self.percent > 100 ? 100 : self.percent;
                NSLog(@"----- >  当前步数分数 %.2f", self.percent);
                
                [self.lpLeft startAnimation:self.percent];
                self.lblNumberLeft.text = [NSString stringWithFormat:@"%d", stepNumber];
                self.lblOtherNumberLeft.text = [NSString stringWithFormat:@"%@ | %.1f%@", [DFD toStringFromDist:dist isMetric:[self.userInfo.unit boolValue]], heat, kString(@"千卡")];
                
                self.percent3 = sitUpNumber / [self.userInfo.user_situps_target doubleValue] * 100;
                self.percent3 = self.percent3 > 100 ? 100 : self.percent3;
                NSLog(@"----- >  当前仰卧起坐分数 %.2f", self.percent3);
                
                [self.lpRight startAnimation:self.percent3];
                self.lblNumberRight.text = [@(situpCount) description];
                self.lblOtherNumberRight.text = [DFD toStringFromSitups:situpCount];
            }
            
            NSArray *arrValue = [self getDeepNormalShallowHours];
            [self refreshSleepNumber:[arrValue[0] intValue]];
            self.lblOtherNumberMiddle.text = [NSString stringWithFormat:@"%@ | %@", kString(@"睡眠质量"), [self getSleepLevelStr:arrValue]];
        }
        else{
            isTodayHaveData = NO;
        }
    }
    else
    {
        isTodayHaveData = NO;
    }
    
    if(!isTodayHaveData)
    {
        stepNumber = 0;
        sitUpNumber = 0;
        [self.lpLeft startAnimation:0];
        [self.lpMiddle startAnimation:0];
        if (self.lpRight) [self.lpRight startAnimation:0];
        self.lblNumberLeft.text = @"0";
        self.lblOtherNumberLeft.text = [NSString stringWithFormat:@"%@ | %d%@", [DFD toStringFromDist:0 isMetric:[self.userInfo.unit boolValue]], 0, kString(@"千卡")];
        [self refreshSleepNumber:0];
        self.lblOtherNumberMiddle.text = [NSString stringWithFormat:@"%@ | %@", kString(@"睡眠质量"), kString(@"未知")];
//#warning 这里缺少 仰卧起坐的算法  补上后，更新UI
    
    }
}

-(void)refreshSleepNumber:(int)deepSleep
{
    NSString *str = [NSString stringWithFormat:@"%d%@", deepSleep, kString(@"小时")];
    NSMutableAttributedString *strToString = [str toString:str
                                                      rangFirst:NSMakeRange(0, [@(deepSleep) description].length)
                                                     rangSecond:NSMakeRange(0, 0)
                                                        bigSize:30
                                                     littleSize:14];
    self.lblNumberMiddle.attributedText = nil;
    self.lblNumberMiddle.attributedText = strToString;
}



-(void)readBLEData
{
    if ([self.Bluetooth.dicConnected.allKeys containsObject:self.userInfo.pUUIDString] && self.userInfo.pUUIDString && !isLeft_index && !self.Bluetooth.isLock && self.Bluetooth.isBeginOK)
    {
        if (timerSys) {                 // 防止卡循环，不能删
            NSLog(@"------------------------------------ 防止卡循环，不能删-");
            [timerSys DF_stop];
            timerSys = nil;
            [self setNavTitle:self title:@"今日"];
        }
        
        [self.Bluetooth realRealData:self.userInfo.pUUIDString];
        DDWeak(self)
        NextWaitInMainAfter(
                 DDStrong(self)
                 if(self)
                 {
                     NSLog(@"%@", self.isReadBLEChange? @"刷新界面":@"不刷新");
                     if(!self->isLeft_index && self.isReadBLEChange)
                     {
                         [self resetLv:NO];
                         [self readIndexData];
                     }
                 }
                 , 1);
    }
}


-(void)updateRealForChannelAndPushList
{
    if([GetUserDefault(NewPushData) boolValue])
    {
        NSLog(@"有新的消息");
        [self getPushInfoList];
        isListChange = YES;
        [self refreshData];
        SetUserDefault(NewPushData, @NO);
    }
   
    if (self.Bluetooth.isLink && self.Bluetooth.isBeginOK && self.Bluetooth.LastDateSys && fabs([self.Bluetooth.LastDateSys timeIntervalSinceDate:DNow]) > 30 * 60) {
        [self.Bluetooth readSportAgain:self.userInfo.pUUIDString];
    }
    
    if (self.Bluetooth.isResetLoadForIndex == 1) {
        [self readIndexData];
        [self refreshData];
        self.Bluetooth.isResetLoadForIndex++;
    }
}

// 设置代理
-(void)setVcLeftDelegate
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    vcLeft *left = (vcLeft *)delegate.left;
    left.delegate = self;
}

-(void)initData
{
    _arrData = [NSMutableArray new];
    pointsSys = 0;
}

-(void)refreshData
{
    [_arrData removeAllObjects];
    
    int year  = DDYear;
    int month = DDMonth;
    int day   = DDDay;

    if (self.userInfo.pUUIDString)  // 在用户绑定的情况下 才显示喝水数据 //  && !self.Bluetooth.isLock
    {
        NSDate *last_model_half;
        NSDate *last_model_All;
        NSDate *last_model_leftStep;
        NSDate *last_model_sleep;
        NSDate *last_model_heat;
        NSDate *last_model_continue;
        NSDictionary *dicMdDates = (NSDictionary *)GetUserDefault(MdIndexData);
        NSString * todayDateValueString = [NSString stringWithFormat:@"%@%d", self.userInfo.access, [DFD HmF2KNSDateToInt:DNow]];
        if ([dicMdDates.allKeys containsObject:todayDateValueString] && dicMdDates.allValues.count)
        {
            NSArray *arrValues = dicMdDates[todayDateValueString];
            last_model_half     = [arrValues[0] isKindOfClass:[NSDate class]] ? arrValues[0]:nil;
            last_model_All      = [arrValues[1] isKindOfClass:[NSDate class]] ? arrValues[1]:nil;
            last_model_leftStep = [arrValues[2] isKindOfClass:[NSDate class]] ? arrValues[2]:nil;
            last_model_sleep    = [arrValues[3] isKindOfClass:[NSDate class]] ? arrValues[3]:nil;
            last_model_heat     = [arrValues[4] isKindOfClass:[NSDate class]] ? arrValues[4]:nil;
            last_model_continue = [arrValues[5] isKindOfClass:[NSDate class]] ? arrValues[5]:nil;
        }
        
        DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@ ", self.userInfo.access,  @(year), @(month), @(day)] inContext:DBefaultContext];
        if (dr)
        {
            if ([dr.step_count intValue] >= [self.userInfo.user_sport_target intValue] / 2)
            {
                if (!model_half) {
                    model_half = [MdIndex new];
                    model_half.type = 4;
                    model_half.msg = kString(@"您已经完成今天运动目标一半了。");
                    
                    if (!last_model_half) {
                        
                        model_half.date = [NSDate dateWithTimeInterval:-1 sinceDate:[DNow getNowDateFromatAnDate]];
                        [self setNewMdDate:1];
                    }else{
                        model_half.date = [NSDate dateWithTimeInterval:-1 sinceDate:[last_model_half getNowDateFromatAnDate]];
                    }
                }
                [_arrData addObject:model_half];
                
                if ([dr.step_count intValue] >= [self.userInfo.user_sport_target intValue])
                {
                    if (!model_All) {
                        model_All = [MdIndex new];
                        model_All.type = 4;
                        model_All.msg = kString(@"您已经完成今天运动目标了。");
                        if (!last_model_All) {
                            model_All.date = [NSDate dateWithTimeInterval:-2 sinceDate:[DNow getNowDateFromatAnDate]];
                            
                            [self setNewMdDate:2];
                        }else{
                            model_All.date = [NSDate dateWithTimeInterval:-2 sinceDate:[last_model_All getNowDateFromatAnDate]];
                        }
                    }
                    
                    [_arrData addObject:model_All];
                    [_arrData removeObject:model_half];
                }
            }
            
            int leftStep = [self.userInfo.user_sport_target intValue] - [dr.step_count intValue];
            if (leftStep > 0)
            {
                NSString *newMsg = [NSString stringWithFormat:@"%@ %d %@", kString(@"您今天还有"),  leftStep, kString(@"步就完成运动目标啦。")];
                if (!model_leftStep)
                {
                    model_leftStep = [MdIndex new];         // 这个每次 大同步 时间都更新
                    model_leftStep.type = 4;
                    if (!last_model_leftStep) {
                        model_leftStep.date = [NSDate dateWithTimeInterval:-3 sinceDate:[DNow getNowDateFromatAnDate]];
                        [self setNewMdDate:3];
                        model_leftStep.msg = newMsg;
                    }else{
                        model_leftStep.date = [NSDate dateWithTimeInterval:-3 sinceDate:[last_model_leftStep getNowDateFromatAnDate]];
                    }
                }else if (![newMsg isEqualToString:model_leftStep.msg] && GetUserDefault(SynHistoryDataForLeftStep)) {
                    model_sleep.date = [NSDate dateWithTimeInterval:-3 sinceDate:[DNow getNowDateFromatAnDate]];
                    [self setNewMdDate:3];
                    model_leftStep.msg = newMsg;
                    RemoveUserDefault(SynHistoryDataForLeftStep);
                }
                if (!model_leftStep.msg) model_leftStep.msg = newMsg;
                [_arrData addObject:model_leftStep];
            }
        }
        
        // 深睡小于2小时 提醒注意休息 大于4小时提示，昨晚睡的很好
        // 仰卧起坐 目标  和连续   待下个版本
        NSArray *arrValue = [self getDeepNormalShallowHours];
        if (arrValue.count == 3) //  && (self.Bluetooth.isBeginOK || !self.Bluetooth.isLock)
        {
            int hourDeep = [arrValue[0] intValue];
            if (hourDeep >= 4 || hourDeep <= 2)
            {
                NSString *newMsg = hourDeep >= 4 ? GoodSleepMsg : BadSleepMsg;
                if(!model_sleep)
                {
                    model_sleep = [MdIndex new];
                    model_sleep.type = 7;
                    if (!last_model_sleep) {
                        model_sleep.date = [NSDate dateWithTimeInterval:-4 sinceDate:[DNow getNowDateFromatAnDate]];
                        [self setNewMdDate:4];
                    }else{
                        model_sleep.date = [NSDate dateWithTimeInterval:-4 sinceDate:[last_model_sleep getNowDateFromatAnDate]];
                    }
                }else if (![newMsg isEqualToString:model_sleep.msg]) {
                    model_sleep.date = [NSDate dateWithTimeInterval:-4 sinceDate:[DNow getNowDateFromatAnDate]];
                    [self setNewMdDate:4];
                }
                
                model_sleep.msg = newMsg;
                [_arrData addObject:model_sleep];
            }
        }
        
        // 消耗热量
        CGFloat realHeat = [DFD shareDFD].isForA5 ?([dr.heat_count intValue] / 10.0):[dr.heat_count doubleValue];
        if (realHeat >= 116)
        {
            NSString *msgDeleted = DeletedLevelFirMsg;
            if (realHeat >= 153) msgDeleted = DeletedLevelSecMsg;
            if (realHeat >= 309) msgDeleted = DeletedLevelThiMsg;
            if (realHeat >= 618) msgDeleted = DeletedLevelForMsg;
            if (realHeat >= 927) msgDeleted = DeletedLevelFifMsg;
            if (realHeat >= 1236) msgDeleted = DeletedLevelSixMsg;
            if (realHeat >= 1545) msgDeleted = DeletedLevelSevMsg;
            if (realHeat >= 1854) msgDeleted = DeletedLevelEigMsg;
            if (realHeat >= 2163) msgDeleted = DeletedLevelNinMsg;
            if (realHeat >= 2474) msgDeleted = DeletedLevelTenMsg;
            
            if(!model_heat){
                model_heat = [MdIndex new];
                model_heat.type = 7;
                if (!last_model_heat) {
                    model_heat.date = [NSDate dateWithTimeInterval:-5 sinceDate:[DNow getNowDateFromatAnDate]];
                    [self setNewMdDate:5];
                }else{
                    model_heat.date = [NSDate dateWithTimeInterval:-5 sinceDate:[last_model_heat getNowDateFromatAnDate]];
                }
                
            }else{
                if (![msgDeleted isEqualToString:model_heat.msg] ) {
                    model_heat.date = [NSDate dateWithTimeInterval:-5 sinceDate:[DNow getNowDateFromatAnDate]];
                    [self setNewMdDate:5];
                }
            }
            model_heat.msg = msgDeleted;
            [_arrData addObject:model_heat];
        }
        
        // 连续达标的天数
        int countTargated = [self getContinuityDays];
        if (countTargated)
        {
            NSString *newMsg = [DFD getLanguage] == 1 ? [NSString stringWithFormat:@"您已经连续 %d 天完成目标步数啦.",countTargated] :[NSString stringWithFormat:@"You have %d days to complete the target number of steps it.",countTargated];
            if (!model_continue) {
                model_continue = [MdIndex new];
                model_continue.type = 7;
                if (!last_model_continue) {
                    model_continue.date = [NSDate dateWithTimeInterval:-6 sinceDate:[DNow getNowDateFromatAnDate]];
                    [self setNewMdDate:6];
                }else{
                    model_continue.date = [NSDate dateWithTimeInterval:-6 sinceDate:[last_model_continue getNowDateFromatAnDate]];
                }
            }else{
                if (![newMsg isEqualToString:model_continue.msg]) {
                    model_continue.date = [NSDate dateWithTimeInterval:-6 sinceDate:[DNow getNowDateFromatAnDate]];
                    [self setNewMdDate:6];
                }
            }
            model_continue.msg = newMsg;
            [_arrData addObject:model_continue];
        }
        
        if (!_arrData.count && !self.Bluetooth.isLink) {
            
            MdIndex *md = [MdIndex new];
            md.type = 6;
            md.date = [DNow getNowDateFromatAnDate];
            md.msg = kString(@"手环未连接.");
            [_arrData addObject:md];
        }
    }

    NSArray *requestData = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %d and month == %d and day == %d", self.userInfo.access, year, month, day] inContext:DBefaultContext];
    for (int i = 0; i < requestData.count; i++)
    {
        // 这里要把同一个人，同一个个类型的进行过滤
        FriendRequest *fr = requestData[i];   // 1:申请我  2:接受我  3:提醒我  4:回复提醒  5:为你点赞
        MdIndex *model = [MdIndex new];
        model.fr = fr;
        model.uerid = fr.friend_id;
        model.name = fr.friend_name;
        model.isOver = [fr.isOver boolValue];
        //NSLog(@" --------- >  type: %@  isOver%@", fr.type, fr.isOver);
        switch ([fr.type integerValue])
        {
            case 1:
                model.type = 5;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"申请加您为好友")];
                break;
            case 2:
                model.type = 6;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"已经接受了你的好友申请")];
                break;
            case 3:
                model.type = 3;
                model.msg = fr.friend_msg;
                break;
            case 4:
                model.type = 4;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"已经看到了你的提醒信息")];
                break;
            case 5:
                model.type = 7;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"为您运动步数点了个赞")];
                break;
            case 6:
                model.type = 7;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"为您仰卧起坐点了个赞")];
                break;
                
            default:
                break;
        }
        
        model.date = [fr.dateTime getNowDateFromatAnDate];
        [_arrData addObject:model];
    }
    
    _arrData = [_arrData startArraySort:@"date" isAscending:NO];
    
    
    if (_arrData.count > 0)
    {
        isTableFirstLineHightLight = YES;
    }
    
    countInTab = _arrData.count + (self.userInfo.pUUIDString ? 0 : 2);
    if(isListChange || self.isReadBLEChange || GetUserDefault(IndexTabelReload) || self.Bluetooth.isResetLoadForIndex)
    {
        NSLog(@"刷新列表");
        [self.table.tableView reloadData];
        if (GetUserDefault(IndexTabelReload)) RemoveUserDefault(IndexTabelReload);
        RemoveUserDefault(readBLEBack);
    }else
    {
        NSLog(@"不刷新列表");
    }
}


-(void)initView
{
    headerHeightTag = self.headerHeight - NavBarHeight;
    self.viewHeadCircleChart.backgroundColor = DWhite;
    
//    numberInHeaderView = [DFD shareDFD].isForA5 ? 3:2;
    numberInHeaderView = isOnlyFirst ? 2:3;
    
    self.scvHeadContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.headerHeight)];
    
//#warning FIXME  下拉动画占位
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, self.headerHeight, ScreenWidth, 200);
    view.backgroundColor = DWhite;
    [self.viewHeadCircleChart addSubview:view];
    
    self.scvHeadContent.delegate = self;
    self.scvHeadContent.bounces = NO;
    self.scvHeadContent.contentSize = CGSizeMake(ScreenWidth * numberInHeaderView, self.headerHeight);
    self.scvHeadContent.showsHorizontalScrollIndicator = NO;
    self.scvHeadContent.showsVerticalScrollIndicator = NO;
    self.scvHeadContent.pagingEnabled = YES;
    [self.viewHeadCircleChart addSubview:self.scvHeadContent];
    
    self.pageControl = [UIPageControl new];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.frame = CGRectMake(0, 0, 0, 10);
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.center = CGPointMake(0, self.headerHeight - 10);
    self.pageControl.numberOfPages = numberInHeaderView;
    self.pageControl.pageIndicatorTintColor = DWhite3;
    [self.viewHeadCircleChart addSubview:self.pageControl];
    
    self.viewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.headerHeight)];
    [self.scvHeadContent addSubview:self.viewLeft];
    
    self.viewMiddle = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, self.headerHeight)];
    [self.scvHeadContent addSubview:self.viewMiddle];
    
    self.viewRight = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth * 2, 0, ScreenWidth, self.headerHeight)];
    [self.scvHeadContent addSubview:self.viewRight];
    
    CGFloat cirleWidth = ScreenWidth * 0.597;                           // 最外侧大圆圈的宽度
    CGFloat lpwidth =  ScreenWidth *  0.554;                            // 刻度的最大宽度
    CGFloat lowidthOutside = lpwidth * 0.48;
    CGFloat lpwidthInner = lowidthOutside - 0.03 * ScreenWidth;
    centerYCirle = 0.562;
    centerYTypeTitle = 0.5;
    centerYNumber = 0.594;
    centerYImv = 0.41;
    centerYOtherNumber = 0.688;

    if (IPhone4)
    {
        cirleWidth = ScreenWidth * 0.507;
        lpwidth =  ScreenWidth *  0.466;
        lowidthOutside = lpwidth * 0.48;
        lpwidthInner = lowidthOutside - 0.03 * ScreenWidth;
        centerYCirle = 0.572;
    }
    
    lpLeft = [[LineProgressView alloc] initWithFrame:CGRectMake(0, 0, lpwidth, lpwidth)];
    lpLeft.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYCirle);
    lpLeft.bgColor = DidDisconnectColor;
    
    lpLeft.color = DWhiteA(0.3);
    lpLeft.radius = lowidthOutside;                // 放大
    lpLeft.innerRadius = lpwidthInner;             // 内环的大小
    lpLeft.layer.shouldRasterize = YES;
    [self.viewLeft addSubview:lpLeft];
    
    cirleLeft = [[CircleView alloc] initWithFrameAndValue:CGRectMake(0, 0, cirleWidth, cirleWidth) width:1];
    cirleLeft.center = lpLeft.center;
    [self.viewLeft addSubview:cirleLeft];
    
    
    lpMiddle =  [[LineProgressView alloc] initWithFrame:CGRectMake(0, 0, lpwidth, lpwidth)];
    lpMiddle.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYCirle);
    lpMiddle.bgColor = DidDisconnectColor;
    lpMiddle.color = DWhiteA(0.3);
    lpMiddle.radius = lowidthOutside;                  // 放大
    lpMiddle.innerRadius = lpwidthInner;               // 内环的大小
    lpMiddle.layer.shouldRasterize = YES;
    [self.viewMiddle addSubview:lpMiddle];
    cirleMiddle = [[CircleView alloc] initWithFrameAndValue:CGRectMake(0, 0, cirleWidth, cirleWidth) width:1];
    cirleMiddle.center = lpMiddle.center;
    [self.viewMiddle addSubview:cirleMiddle];
    
    
    lpRight = [[LineProgressView alloc] initWithFrame:CGRectMake(0, 0, lpwidth, lpwidth)];
    lpRight.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYCirle);
    lpRight.bgColor = DidDisconnectColor;
    lpRight.color = DWhiteA(0.3);
    lpRight.radius = lowidthOutside;                       // 放大
    lpRight.innerRadius = lpwidthInner;               // 内环的大小
    lpRight.layer.shouldRasterize = YES;
    [self.viewRight addSubview:lpRight];
    
    cirleRight = [[CircleView alloc] initWithFrameAndValue:CGRectMake(0, 0, cirleWidth, cirleWidth) width:1];
    cirleRight.center = lpRight.center;
    [self.viewRight addSubview:cirleRight];
    
    // 步数 的 布局初始化
    self.lblTypeTitleLeft = [[UILabel alloc] init];
    self.lblTypeTitleLeft.frame = CGRectMake(0, 0, 100, 22);
    self.lblTypeTitleLeft.font = [UIFont systemFontOfSize:12];
    self.lblTypeTitleLeft.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYTypeTitle);
    self.lblTypeTitleLeft.textAlignment = NSTextAlignmentCenter;
    self.lblTypeTitleLeft.textColor = DWhiteA(0.7);
    self.lblTypeTitleLeft.text = kString(@"步数");
    [self.viewLeft addSubview:self.lblTypeTitleLeft];
    
    self.lblNumberLeft = [[UILabel alloc] init];
    self.lblNumberLeft.frame = CGRectMake(0, 0, 95, 24);
    self.lblNumberLeft.font = [UIFont systemFontOfSize:30];
    self.lblNumberLeft.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYNumber);
    self.lblNumberLeft.textAlignment = NSTextAlignmentCenter;
    self.lblNumberLeft.textColor = DWhite;
    self.lblNumberLeft.text = @"0";
    [self.viewLeft addSubview:self.lblNumberLeft];
    
    
    self.lblNumberUnitLeft = [[UILabel alloc] init];
    self.lblNumberUnitLeft.frame = CGRectMake(0, 0, 50, 24);
    self.lblNumberUnitLeft.font = [UIFont systemFontOfSize:12];
    self.lblNumberUnitLeft.center = CGPointMake(ScreenWidth / 2 + 48, self.headerHeight * centerYNumber);
    self.lblNumberUnitLeft.alpha = 0;
    self.lblNumberUnitLeft.textAlignment = NSTextAlignmentCenter;
    self.lblNumberUnitLeft.textColor = DWhite;
    self.lblNumberUnitLeft.text = kString(@"步");
    [self.viewLeft addSubview:self.lblNumberUnitLeft];
    
    
    self.imvTypeLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"running_01"]];
    self.imvTypeLeft.frame = CGRectMake(0, 0, 20, 20);
    self.imvTypeLeft.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYImv);
    [self.viewLeft addSubview:self.imvTypeLeft];
    
    self.lblOtherNumberLeft = [[UILabel alloc] init];
    self.lblOtherNumberLeft.frame = CGRectMake(0, 0, 150, 24);
    self.lblOtherNumberLeft.font = [UIFont systemFontOfSize:IPhone4 ? 10:12];
    self.lblOtherNumberLeft.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYOtherNumber);
    self.lblOtherNumberLeft.textAlignment = NSTextAlignmentCenter;
    self.lblOtherNumberLeft.textColor = DWhiteA(0.7);
    self.lblOtherNumberLeft.text = [NSString stringWithFormat:@"%@ | %d%@", [DFD toStringFromDist:0 isMetric:[self.userInfo.unit boolValue]], 0, kString(@"千卡")];
    [self.viewLeft addSubview:self.lblOtherNumberLeft];
    
    // 睡眠 的 布局初始化
    self.lblTypeTitleMiddle = [[UILabel alloc] init];
    self.lblTypeTitleMiddle.frame = CGRectMake(0, 0, 100, 22);
    self.lblTypeTitleMiddle.font = [UIFont systemFontOfSize:12];
    self.lblTypeTitleMiddle.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYTypeTitle);
    self.lblTypeTitleMiddle.textAlignment = NSTextAlignmentCenter;
    self.lblTypeTitleMiddle.textColor = DWhiteA(0.7);
    self.lblTypeTitleMiddle.text = kString(@"深度睡眠时长");
    [self.viewMiddle addSubview:self.lblTypeTitleMiddle];
    
    self.lblNumberMiddle = [[UILabel alloc] init];
    self.lblNumberMiddle.frame = CGRectMake(0, 0, 100, 24);
    self.lblNumberMiddle.font = [UIFont systemFontOfSize:30];
    self.lblNumberMiddle.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYNumber);
    self.lblNumberMiddle.textAlignment = NSTextAlignmentCenter;
    self.lblNumberMiddle.textColor = DWhite;
    self.lblNumberMiddle.text = @"0";
    [self.viewMiddle addSubview:self.lblNumberMiddle];
    
    self.lblNumberUnitMiddle = [[UILabel alloc] init];
    self.lblNumberUnitMiddle.frame = CGRectMake(0, 0, 50, 24);
    self.lblNumberUnitMiddle.font = [UIFont systemFontOfSize:12];
    self.lblNumberUnitMiddle.center = CGPointMake(ScreenWidth / 2 + 65, self.headerHeight * centerYNumber);
    self.lblNumberUnitMiddle.alpha = 0;
    self.lblNumberUnitMiddle.textAlignment = NSTextAlignmentCenter;
    self.lblNumberUnitMiddle.textColor = DWhite;
    self.lblNumberUnitMiddle.text = @"";//kString(@"小时");                          // 这个舍弃，暂时不删
    [self.viewMiddle addSubview:self.lblNumberUnitMiddle];
    
    self.imvTypeMiddle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sleep_01"]];
    self.imvTypeMiddle.frame = CGRectMake(0, 0, 20, 20);
    self.imvTypeMiddle.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYImv);
    [self.viewMiddle addSubview:self.imvTypeMiddle];
    
    self.lblOtherNumberMiddle = [[UILabel alloc] init];
    self.lblOtherNumberMiddle.frame = CGRectMake(0, 0, 150, 22);
    self.lblOtherNumberMiddle.font = [UIFont systemFontOfSize:IPhone4 ? 10:12];
    self.lblOtherNumberMiddle.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYOtherNumber);
    self.lblOtherNumberMiddle.textAlignment = NSTextAlignmentCenter;
    self.lblOtherNumberMiddle.textColor = DWhiteA(0.7);
    self.lblOtherNumberMiddle.text = @"";
    [self.viewMiddle addSubview:self.lblOtherNumberMiddle];
    
    // 仰卧起坐的布局
    self.lblTypeTitleRight = [[UILabel alloc] init];
    self.lblTypeTitleRight.frame = CGRectMake(0, 0, 100, 22);
    self.lblTypeTitleRight.font = [UIFont systemFontOfSize:12];
    self.lblTypeTitleRight.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYTypeTitle);
    self.lblTypeTitleRight.textAlignment = NSTextAlignmentCenter;
    self.lblTypeTitleRight.textColor = DWhiteA(0.7);
    self.lblTypeTitleRight.text = kString(@"仰卧起坐");
    [self.viewRight addSubview:self.lblTypeTitleRight];
    
    self.lblNumberRight = [[UILabel alloc] init];
    self.lblNumberRight.frame = CGRectMake(0, 0, 100, 24);
    self.lblNumberRight.font = [UIFont systemFontOfSize:30];
    self.lblNumberRight.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYNumber);
    self.lblNumberRight.textAlignment = NSTextAlignmentCenter;
    self.lblNumberRight.textColor = DWhite;
    self.lblNumberRight.text = @"0";
    [self.viewRight addSubview:self.lblNumberRight];
    
    self.lblNumberUnitRight = [[UILabel alloc] init];
    self.lblNumberUnitRight.frame = CGRectMake(0, 0, 50, 24);
    self.lblNumberUnitRight.font = [UIFont systemFontOfSize:12];
    self.lblNumberUnitRight.center = CGPointMake(ScreenWidth / 2 + 65, self.headerHeight * centerYNumber);
    self.lblNumberUnitRight.alpha = 0;
    self.lblNumberUnitRight.textAlignment = NSTextAlignmentCenter;
    self.lblNumberUnitRight.textColor = DWhite;
    self.lblNumberUnitRight.text = kString(@"个");
    [self.viewRight addSubview:self.lblNumberUnitRight];
    
    self.imvTypeRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sit_ups_01"]];
    self.imvTypeRight.frame = CGRectMake(0, 0, 20, 20);
    self.imvTypeRight.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYImv);
    [self.viewRight addSubview:self.imvTypeRight];
    
    self.lblOtherNumberRight = [[UILabel alloc] init];
    self.lblOtherNumberRight.frame = CGRectMake(0, 0, 150, 22);
    self.lblOtherNumberRight.font = [UIFont systemFontOfSize:IPhone4 ? 10:12];
    self.lblOtherNumberRight.center = CGPointMake(ScreenWidth / 2, self.headerHeight * centerYOtherNumber);
    self.lblOtherNumberRight.textAlignment = NSTextAlignmentCenter;
    self.lblOtherNumberRight.textColor = DWhiteA(0.7);
    self.lblOtherNumberRight.text = [NSString stringWithFormat:@"0%@", kString(@"千卡")];
    [self.viewRight addSubview:self.lblOtherNumberRight];
}


#pragma mark - override
-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    self.viewHeadCircleChart = (UIView<ARSegmentPageControllerHeaderProtocol> *)[[UIView alloc] init];
    return self.viewHeadCircleChart;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (isLeft_index)return;
    DDWeak(self)
    if ([object isEqual:self.Bluetooth] && [keyPath isEqual:@"isBeginOK"] )
    {
        if(self.Bluetooth.isBeginOK && self.Bluetooth.isLink && self.Bluetooth.isOn && self.userInfo.pUUIDString)
        {
            NextWaitInMain(
                   DDStrong(self)
                   [self resetLv:YES];
                   [self resetColor:YES];
            );
        }
        else
        {
            NextWaitInMain(
                 DDStrong(self)
                 [self resetColor:NO];
                 if (self->timerSys) {
                     [self->timerSys DF_stop];
                     self->timerSys = nil;
                     [self setNavTitle:self title:@"今日"];
                 }
            );
        }
    }
    else if([object isEqual:self.Bluetooth] && [keyPath isEqualToString:@"isLock"])
    {
        NextWaitInMain(
               DDStrong(self)
               if(self){
                   if(!self.Bluetooth.isLock)
                   {
                       [self resetLv:NO];
                   }
               }
        );
    }
    else if([keyPath isEqual:@"contentOffset"] || [keyPath isEqual:@"segmentToInset"] )
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        if (context == vcIndexObserver)
        {
            inset = [change[NSKeyValueChangeNewKey] floatValue];
            
            [self.viewHeadCircleChart setFrame:CGRectMake(0, 0, ScreenWidth, inset)];
            alpha =  (inset - segmentMiniTopInsetValue) / (self.headerHeight - segmentMiniTopInsetValue);
            alpha = alpha > 1 ? 1: alpha;
            alpha = alpha < 0 ? 0: alpha;
            if (inset < self.headerHeight)
            {
                [self change:NO];
            }
        }
    }
}

// 开始/完成 同步
- (void)resetLv:(BOOL)isBegin
{
    if (self.Bluetooth.isLock && !isBegin) return;
    if (isBegin)
    {
        if (!timerSys) {
            DDWeak(self)
            NextWaitInGlobal(
                 DDStrong(self)
                 self->timerSys = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                   target:self
                                                                 selector:@selector(refreshTitle)
                                                                 userInfo:nil repeats:YES];
                 [[NSRunLoop currentRunLoop] run];);
        }
        
    }else
    {
        [timerSys DF_stop];
        timerSys = nil;
        [self setNavTitle:self title:@"今日"];
    }
}

-(void)refreshTitle
{
    if (self.Bluetooth.isLink && self.Bluetooth.isLock) {
        pointsSys++;
        pointsSys = pointsSys == 3 ? 0 : pointsSys;
        NSMutableString *mStr = [NSMutableString new];
        for(int i = 0; i <= pointsSys; i++)
        {
            [mStr appendString:@"."];
        }
        NSString *str1 = [NSString stringWithFormat:@"正在同步%@", mStr];
        DDWeak(self)
        NextWaitInMain(
               DDStrong(self)
               [self setNavTitle:self title:str1];);
    }else{
        [timerSys DF_stop];
        timerSys = nil;
        [self setNavTitle:self title:@"今日"];
    }
}

-(void)resetColor:(BOOL)isLink
{
    if (isLeft_index) return;
    if (isLink)
    {
        lpLeft.bgColor = self.viewLeft.backgroundColor = DidConnectColor;
        lpMiddle.bgColor = self.viewMiddle.backgroundColor = DidSleepColor;
        lpRight.bgColor = self.viewRight.backgroundColor = DidSitupColor;
    }
    else
    {
        self.viewLeft.backgroundColor = self.viewMiddle.backgroundColor = self.viewRight.backgroundColor =  DidDisconnectColor;
        lpLeft.bgColor = lpMiddle.bgColor = lpRight.bgColor = DidDisconnectColor;
    }
    [lpLeft.layer setNeedsDisplay];
    [lpMiddle.layer setNeedsDisplay];
    
    [lpLeft startAnimation:self.percent];
    [lpMiddle startAnimation:0];
    [lpRight startAnimation:self.percent3];
}

-(void)checkViewForBraceletSystem
{
    NSLog(@"%@", @([DFD shareDFD].isForA5 ? 3:2));
    if (numberInHeaderView != ([DFD shareDFD].isForA5 ? 3:2))
    {
        numberInHeaderView = ([DFD shareDFD].isForA5 ? 3:2);
        self.scvHeadContent.contentSize = CGSizeMake(ScreenWidth * numberInHeaderView, self.headerHeight);
        self.pageControl.numberOfPages = numberInHeaderView;
    }
}



#pragma mark - vcLeftDelegate
-(void)selected:(NSInteger)ind
{
    if (isLeft_index) return;
    isLeft_index = YES;
    
    switch (ind)
    {
        case 0:
            [self performSegueWithIdentifier:@"index_to_user" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"index_to_friend" sender:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"index_to_clock" sender:nil];
            break;
        case 3:
            [self performSegueWithIdentifier:@"index_to_set" sender:nil];
            break;
        default:
            break;
    }
}

-(void)refreshNumber
{
    NSDictionary *dicIndexData = GetUserDefault(IndexData);
    if (dicIndexData && [dicIndexData.allKeys containsObject:self.userInfo.access])
    {
        NSArray *subArr = dicIndexData[self.userInfo.access];
        int day = [subArr[0] intValue];
        int step = [subArr[1] intValue];
        int dist = [subArr[2] intValue];
        int heat = [subArr[3] intValue];
        if (day == [DNow getFromDate:3])
        {
            stepNumber = step;
            self.lblNumberLeft.text = [NSString stringWithFormat:@"%d", stepNumber];
            
            NSString *disStr = dist >= 1000 ? [NSString stringWithFormat:@"%.2f%@", dist / 1000.0, kString(@"公里")] : [NSString stringWithFormat:@"%d%@", dist, kString(@"米")];
            NSString *heatStr = [NSString stringWithFormat:@"%d%@", heat, kString(@"千卡")];
            self.lblOtherNumberLeft.text = [NSString stringWithFormat:@"%@ | %@", disStr, heatStr];
            
            self.lblNumberMiddle.text = [NSString stringWithFormat:@"%d%@", stepNumber, kString(@"小时")];
            if (numberInHeaderView == 3) {
                self.lblNumberLeft.text = [NSString stringWithFormat:@"%4d", stepNumber];
            }
        }
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return countInTab;// ? countInTab : 1;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcIndex *cell = [tvcIndex cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!self.userInfo.pUUIDString)
    {
        if (indexPath.row == 0)
        {
            cell.title2 = kString(@"欢迎使用 Bandcare");
            [cell.imvRight setHidden:YES];
        }
        else if(indexPath.row == 1)
        {
            cell.title2 = kString(@"您还未绑定设备,点击绑定");
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else
        {
            MdIndex *model = _arrData[indexPath.row - 2];
            cell.model = model;
            cell.delegate = self;
            if (!(indexPath.row - 2) && isTableFirstLineHightLight) //  && !isFirstLoad
            {
                if (isFirstLoad)
                    isFirstLoad = NO;
                else
                {
                    [cell hightLight];
                    isTableFirstLineHightLight = NO;
                }
            }
        }
    }
    else
    {
        if (self.arrData.count > indexPath.row)
        {
            MdIndex *model = _arrData[indexPath.row];
            cell.model = model;
            cell.delegate = self;
            if (!indexPath.row && isTableFirstLineHightLight) //  && !isFirstLoad
            {
                if (isFirstLoad)
                    isFirstLoad = NO;
                else
                {
                    [cell hightLight];
                    isTableFirstLineHightLight = NO;
                }
            }
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(!self.userInfo.pUUIDString && indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"index_to_search" sender:nil];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.userInfo.pUUIDString || (!self.userInfo.pUUIDString && _arrData.count))
    {
        if((!self.userInfo.pUUIDString && indexPath.row < 2) || !_arrData.count)  // 正在加载的时候
            return tableViewHeight;
        MdIndex *model= _arrData[indexPath.row - (self.userInfo.pUUIDString ? 0 : 2)];
        if (model.type == 3 || model.type == 4 || model.type == 5|| model.type == 6|| model.type == 7)
        {
            NSString *str = [NSString stringWithFormat:@"%@", model.msg];
            CGFloat tag = (model.type == 3 || model.type == 5) ? 160 : 100;
            
            CGFloat titleHeight = [DFD getTextSizeWith:str fontNumber:14 biggestWidth:(ScreenWidth - tag)].height;
            
            titleHeight = (titleHeight > 21 ? titleHeight : 21) + (tableViewHeight - 21);
            return titleHeight;
        }
        return tableViewHeight;
    }
    else return tableViewHeight;
}


#pragma mark tvcIndexDelegate
-(void)btnClick:(tvcIndex *)sender
{
    MdIndex *md = sender.model;
    for (int i = 0 ; i < _arrData.count; i++)
    {
        mmd = _arrData[i];
        if (mmd.type == md.type && [mmd.msg isEqualToString:md.msg])
        {
            isListChange = YES;  // 让刷新
            mmd.isOver = YES;
            if (mmd.type == 5)          // 接受对方的好友申请
            {
                FriendRequest *fr = mmd.fr;
                NSArray *arrFriendRequests = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", fr.access, fr.friend_id, fr.type] inContext:DBefaultContext];
                for (int i = 0; i < arrFriendRequests.count; i++) {
                    fr.isOver = @YES;
                }
                DBSave;
                DDDWeak(self)
                // 失败的回调
                void (^blockFail)() = ^{
                    DDDStrong(self)
                    FriendRequest *friendRequest = [[FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", fr.access, fr.friend_id, fr.type] inContext:DBefaultContext] lastObject];
                    friendRequest.isOver = @NO;
                    DBSave;
                    LMBShow(NONetTip);
                    [self refreshData];
                };
                
                RequestCheckBefore(
                       [timerM DF_pause];
                       [net updateFriendship:self.userInfo.access
                                   friend_id:mmd.uerid
                                 ship_status:@"1"];,
                       [self dataSuccessBack_updateFriendship:dic];,
                       blockFail();)
            }
            else if (mmd.type == 3)     // 知道了  对方提示知道了
            {
                NSArray *arrFriengRequest = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", mmd.fr.access, mmd.fr.friend_id, @(mmd.type)] inContext:DBefaultContext];
                FriendRequest *fr;
                for (int i = 0; i < arrFriengRequest.count; i++)
                {
                    fr = arrFriengRequest[i];             // 先刷新界面  再 发起请求
                    fr.isOver = @YES;
                }
                DBSave;
                
                NSString *content = [NSString stringWithFormat:@"%@%@", self.userInfo.user_nick_name, kString(@"已经看到了你的提示信息")];
                DDDWeak(self)
                
                // 失败的回调
                void (^blockFail)() = ^{
                    DDDStrong(self)
                    FriendRequest *friendRequest = [[FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", mmd.fr.access, mmd.fr.friend_id, @(mmd.type)] inContext:DBefaultContext] lastObject];
                    friendRequest.isOver = @NO;
                    DBSave;
                    LMBShow(NONetTip);
                    [self refreshData];
                };
                
                RequestCheckBefore(
                      [timerM DF_pause];
                      [net pushHintInfo:self.userInfo.access
                                   type:@"4"
                              friend_id:fr.friend_id
                           hint_content:content];,
                      [self dataSuccessBack_pushDrinkHint:dic];,
                       blockFail();
                );
            }
            DBSave;
            [self refreshData];
            break;
        }
    }
}

////滚动到第一行
//-(void)goToFirstIndex
//{
//    if (_arrData.count > 0)
//    {
//        NSUInteger sectionCount = [_tabView numberOfSections];
//        if (sectionCount)
//        {
//            NSUInteger rowCount = [_tabView numberOfRowsInSection:0];
//            if (rowCount)
//            {
//                NSUInteger ii[2] = {0, 0};
//                NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
//                _tabView.delegate = nil;
//                [_tabView scrollToRowAtIndexPath:indexPath
//                                    atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//                _tabView.delegate = self;
//            }
//        }
//    }
//}

-(void)dataSuccessBack_getUserToken:(NSDictionary *)dic
{
    if(CheckIsOK && [self.userInfo.token isEqualToString:dic[@"token"]])
    {
        SetUserDefault(IsLogined, @YES);
        if (!isGetApply) [self getPushInfoList];
    }
    else    // 这里 说明 2：账号不存在；3：密码不正确 4 token 发生变化
    {
        NSLog(@"本地的密码不正确，跳转到登录页面  ———— 原始token: %@ 新的token：%@", self.userInfo.token, dic[@"token"]);
        [self clearLocalData];
        [self gotoLoginStoryBoard:nil];
    }
}

-(void)dataSuccessBack_updateFriendship:(NSDictionary *)dic
{
    //[timerF time_continue];
    [timerM DF_continue];
    if (CheckIsOK)
    {
//        FriendRequest *fr = mmd.fr;
//        fr.isOver = @(YES);
//        DBSave;
        [self refreshData];
    }
    
}

-(void)dataSuccessBack_getPushInfoList:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        isListChange = YES;
        NSArray *arrData_sub = dic[@"push_info_list"];
        if (!arrData_sub) return;
        
        // 删除本地今天的推送信息
        [FriendRequest MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@", self.userInfo.access, @(DDYear), @(DDMonth), @(DDDay)]  inContext:DBefaultContext];
        
        DBSave;
        for(int i = 0; i < arrData_sub.count; i++)
        {
            NSDictionary *dic_sub = arrData_sub[i];
            NSString *userid = dic_sub[@"friend_id"];
            NSTimeInterval interval = [dic_sub[@"time"] longLongValue] / 1000.0;
            NSDate *dataFrom = [NSDate dateWithTimeIntervalSince1970:interval];
            
            FriendRequest *fr;
            int type = [dic_sub[@"type"] intValue];
            
            if (type < 100)
            {
                switch (type) { // 1:申请我  2:接受我  3:提醒我  4:回复提醒
                    case 1:
                    case 2:
                    {
                        // 服务器已经过滤点掉了 同一个人的多次请求
                        fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@ and dateTime == %@", self.userInfo.access, userid, @(type), dataFrom] inContext:DBefaultContext];
                        
                        if (!fr)
                        {
                            fr = [FriendRequest MR_createEntityInContext:DBefaultContext];
                        }
                        
                        fr.isOver = @([dic_sub[@"push_status"] boolValue]);
                        if (type == 2) fr.isOver = @YES ;
                        
                        fr.dateTime = dataFrom;
                    }
                        break;
                    case 3:
                    {
                        fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@ and dateTime == %@", self.userInfo.access, userid, @(type), dataFrom] inContext:DBefaultContext];
                        if (!fr)
                        {
                            fr = [FriendRequest MR_createEntityInContext:DBefaultContext];
                            fr.isOver = @([dic_sub[@"push_status"] boolValue]);
                            fr.dateTime = dataFrom;
                        }
                    }
                        break;
                    case 4:
                    {
                        fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@ and dateTime == %@", self.userInfo.access, userid, @(type), dataFrom] inContext:DBefaultContext];
                        if (!fr)
                        {
                            fr = [FriendRequest MR_createEntityInContext:DBefaultContext];
                            fr.isOver = @YES;
                            fr.dateTime = dataFrom;
                        }
                    }
                        break;
                    case 5:
                    {
                        fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@ and dateTime == %@", self.userInfo.access, userid, @(type), dataFrom] inContext:DBefaultContext];
                        if (!fr)
                        {
                            fr = [FriendRequest MR_createEntityInContext:DBefaultContext];
                            fr.isOver = @YES;
                            fr.dateTime = dataFrom;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                
                fr.access = self.userInfo.access;
                fr.friend_id = userid;
                fr.friend_name = dic_sub[@"friend_name"];
                fr.friend_msg = dic_sub[@"push_content"];
                fr.type = @(type);
                [fr perfect];
                DBSave;
            }
            
            
        }
        [self refreshData];
    }
}


-(void)dataSuccessBack_pushDrinkHint:(NSDictionary *)dic
{
    [timerM DF_continue];
    if (CheckIsOK)
    {
        NSLog(@"提示喝水，已经知道了");
    }
}

-(void)dataSuccessBack_getFriendApplyList:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        SetUserDefault(ExitUserOnce, @1);
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
            NSArray *arr_sub = dic[@"friend_apply_list"];
            if(arr_sub.count > 0)
            {
                for (int i = 0; i < arr_sub.count; i++)
                {
                    NSDictionary *dic_sub = arr_sub[i];
                    NSString *userid = dic_sub[@"userid"];
                    FriendRequest *fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@", self.userInfo.access, userid] inContext:DBefaultContext];
                    if (!fr)
                    {
                        fr = [FriendRequest MR_createEntityInContext:DBefaultContext];
                        fr.dateTime = DNow;
                    }
                    
                    fr.isOver = @NO;
                    fr.access = self.userInfo.access;
                    fr.friend_id = userid;
                    fr.friend_name = dic_sub[@"user_nick_name"];
                    fr.user_pic_url = dic_sub[@"user_pic_url"];
                    fr.type = @1;
                    [fr perfect];
                }
            }
            DLSave
            DBSave
        }];
    }
}


-(void)scrollToTop:(BOOL)isTop
{
    [self.table.tableView setContentOffset:CGPointMake(0,0) animated:YES];
    self.table.tableView.bouncesZoom = NO;
}

//  这里拉去token值  用来判断如果和当前用户的token值不一样，就是登陆过期了
-(void)nextLogin
{
    RequestCheckNoWaring(
          [net getUserToken:self.userInfo.access];,
          [self dataSuccessBack_getUserToken:dic];);
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"index_to_chart"])
    {
        vcChart *vc = (vcChart *)segue.destinationViewController;
        vc.numberInScrollView = numberInHeaderView;
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (alertView.cancelButtonIndex == buttonIndex)
        {
            NSLog(@"使用默认");
            self.userInfo.isNeedUpdate = @NO;
            DBSave;
        }
        else if (alertView.firstOtherButtonIndex == buttonIndex)
        {
            [self gotoLoginStoryBoard:@"vcNewPerfectInfo"];
        }
    }
    else if (alertView.tag == 2)
    {
        if(alertView.firstOtherButtonIndex == buttonIndex)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", APPID]]];
        }
    }
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scvHeadContent] ) {
        self.pageControl.currentPage = scrollView.contentOffset.x / ScreenWidth;
    }
    else{
        [self changeFrame];
    }
}



-(void)changeFrame
{
    //NSLog(@"insert:%.1f, headerHegith:%.1f alpha:%.1f", inset, self.headerHeight, lpLeft.alpha);
    if (lpLeft.alpha != 1 && lpLeft.alpha != 0) { //  && inset <= self.headerHeight)
        [self change:YES];
    }
    
}

-(void)change:(BOOL)isAnimate{
    CGFloat duration = isAnimate? 0.2:0;
    inset = inset > self.headerHeight ? self.headerHeight : inset;
    [UIView transitionWithView:self.view duration:duration options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.pageControl.center = CGPointMake(ScreenWidth / 2, inset - 10);
        lpLeft.center = CGPointMake(ScreenWidth / 2, inset * centerYCirle);
        cirleLeft.center = lpLeft.center;
        self.lblTypeTitleLeft.center = CGPointMake(ScreenWidth / 2, inset * centerYTypeTitle);
        self.lblNumberLeft.center = CGPointMake(ScreenWidth / 2, inset * centerYNumber + 15 * (1-alpha));
        self.imvTypeLeft.center = CGPointMake(ScreenWidth / 2, inset * centerYImv);
        self.lblOtherNumberLeft.center = CGPointMake(ScreenWidth / 2, inset * centerYOtherNumber);
        self.lblNumberUnitLeft.center = CGPointMake(ScreenWidth / 2 + 48, inset * centerYNumber + 20 * (1-alpha));
        lpLeft.alpha = cirleLeft.alpha = self.lblTypeTitleLeft.alpha = self.imvTypeLeft.alpha = self.lblOtherNumberLeft.alpha = self.pageControl.alpha = alpha;
        self.lblNumberUnitLeft.alpha = 0.95 - alpha;
        
        lpMiddle.center = CGPointMake(ScreenWidth / 2, inset * centerYCirle);
        cirleMiddle.center = lpMiddle.center;
        self.lblTypeTitleMiddle.center = CGPointMake(ScreenWidth / 2, inset * centerYTypeTitle);
        self.lblNumberMiddle.center = CGPointMake(ScreenWidth / 2, inset * centerYNumber + 15 * (1-alpha));
        self.imvTypeMiddle.center = CGPointMake(ScreenWidth / 2, inset * centerYImv);
        self.lblOtherNumberMiddle.center = CGPointMake(ScreenWidth / 2, inset * centerYOtherNumber);
        self.lblNumberUnitMiddle.center = CGPointMake(ScreenWidth / 2 + 65, inset * centerYNumber + 20 * (1-alpha));
        lpMiddle.alpha = cirleMiddle.alpha = self.lblTypeTitleMiddle.alpha = self.imvTypeMiddle.alpha = self.lblOtherNumberMiddle.alpha = alpha;
        self.lblNumberUnitMiddle.alpha = 0.95 - alpha;
        
        if (lpRight) {
            lpRight.center = CGPointMake(ScreenWidth / 2, inset * centerYCirle);
            cirleRight.center = lpRight.center;
            self.lblTypeTitleRight.center = CGPointMake(ScreenWidth / 2, inset * centerYTypeTitle);
            self.lblNumberRight.center = CGPointMake(ScreenWidth / 2, inset * centerYNumber + 15 * (1-alpha));
            self.imvTypeRight.center = CGPointMake(ScreenWidth / 2, inset * centerYImv);
            self.lblOtherNumberRight.center = CGPointMake(ScreenWidth / 2, inset * centerYOtherNumber);
            self.lblNumberUnitRight.center = CGPointMake(ScreenWidth / 2 + 65, inset * centerYNumber + 20 * (1-alpha));
            lpRight.alpha = cirleRight.alpha = self.lblTypeTitleRight.alpha = self.imvTypeRight.alpha = self.lblOtherNumberRight.alpha = alpha;
            self.lblNumberUnitRight.alpha = 0.95 - alpha;
        }
    } completion:^(BOOL finished) {}];
}


// 通过 年 月 日 获取 深睡 中睡 浅睡 小时数   other:额外的操作   1：操作日 2：
-(NSArray *)getDeepNormalShallowHours
{
    int left = [[self.userInfo.user_sleep_start_time substringToIndex:2] intValue];
    int right = [[self.userInfo.user_sleep_end_time substringToIndex:2] intValue];
    int number = left < right ? (right - left) : (24 - (left - right));
    
    int year  = [DNow getFromDate:1];
    int month = [DNow getFromDate:2];
    int day   = [DNow getFromDate:3];
    
    int numberDeep = 0;
    int numberModerate = 0;
    int numberShallow = 0;
    if (left < right)  // 只拿今天的数据
    {
        NSMutableArray *arrDate = [@[ @(year), @(month), @(day) ] mutableCopy];
        NSDate *dateSelected = [DFD getDateFromArr:arrDate];
        
        //NSLog(@"%@,%@", self.userInfo.access, dateSelected);
        DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelected] inContext:DBefaultContext];
        if(dr && [dr.step_count intValue])
        {
            NSArray *arrHour = [dr.step_array componentsSeparatedByString:@","];
            for (int i = 0; i < number; i++)
            {
                NSNumber *num = [self getNumberFromStep:arrHour[left+i]];
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }else
        {
            NSLog(@"没有今天的数据  ，，，， 擦擦擦");
        }
    }else                   // 拿一部分昨天的数据
    {
        NSMutableArray *arrDateToday = [@[ @(year), @(month), @(day) ] mutableCopy];
        NSDate *dateSelectedToday = [DFD getDateFromArr:arrDateToday];
        
        int yesterdayInt = [DFD HmF2KDateToInt:arrDateToday] - 1;
        NSDate *dateSelectedYesterday = [DFD getDateFromArr:[DFD HmF2KIntToDate:yesterdayInt]];
        
        DataRecord *drYesterday = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelectedYesterday] inContext:DBefaultContext];
        
        DataRecord *drToday = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelectedToday] inContext:DBefaultContext];
        
        if (drYesterday && [drYesterday.step_count intValue])
        {
            NSArray *arrHour = [drYesterday.step_array componentsSeparatedByString:@","];
            for (int i = 0; i < (24 - left); i++) {
                NSNumber *num = [self getNumberFromStep:arrHour[left+i]];
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }
        
        
        if (drToday && [drToday.step_count intValue]) {
            NSArray *arrHour = [drToday.step_array componentsSeparatedByString:@","];
            for (int i = 0; i < (number - (24 - left)); i++) {
                NSNumber *num = [self getNumberFromStep:arrHour[i]];
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }else{
           return @[@0,@0,@0,@0];
        }
        
        //  如果没有今天的数据，直接返回4个0
    }
    
    // 如果没有这天的数据，返回4个数量的数组， 否则返回3个
    if (!numberDeep && !numberModerate && !numberShallow) {
        return @[@(numberDeep),@(numberModerate),@(numberShallow),@0];
    }
    return @[@(numberDeep),@(numberModerate),@(numberShallow)];
}


-(void)setNewMdDate:(int)index
{
    NSString * todayDateValueString = [NSString stringWithFormat:@"%@%d", self.userInfo.access, [DFD HmF2KNSDateToInt:DNow]];
    
    NSDictionary *dicMdDates = (NSDictionary *)GetUserDefault(MdIndexData);
    NSMutableArray *arrValues = [dicMdDates[todayDateValueString] mutableCopy];
    if (arrValues.count != 6) {
        arrValues = [@[@0,@0,@0,@0,@0,@0] mutableCopy];
    }
    [arrValues replaceObjectAtIndex:index-1 withObject:DNow];
    SetUserDefault(MdIndexData, @{todayDateValueString:arrValues});
}









@end
