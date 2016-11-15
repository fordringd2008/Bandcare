//
//  vcBase.m
//  ListedDemo
//
//  Created by 丁付德 on 15/6/22.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

#define NavRightButtonFrame                         CGRectMake(0, 0, 30, 30)

@interface vcBase () <BLEManagerDelegate, aLiNetDelegate>
{
    CGFloat             fontSize;
    NSDate *            lastBeginLinkDate;
    NSTimer *           timerAutoLink;                   // 连接循环器
    NSDate*             lastBindDatetime;                // 上次去操作极光的时间
}


@end

@implementation vcBase

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isPop = YES;
    self.Bluetooth = [BLEManager sharedManager];
    //self.Bluetooth.delegate = self;                                     // 这里改动， 可能影响很多
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.windowView = self.appDelegate.window;
    self.userInfo = myUserInfo;                                          // 不能删
    
    if ([@[@"vcNewPerfectInfo", @"vcUser"] containsObject:NSStringFromClass([self class])]){
        self.alinet = [[aLiNet alloc] init];
        self.alinet.delegate = self;
    }
    if (SystemVersion >=8.0) self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.Bluetooth.delegate = self;
    self.userInfo = myUserInfo;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:DClear] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:DClear];
    if (self.userInfo && ![NSStringFromClass([self class]) isEqualToString:@"vcLeft"]) {
        DDWeak(self)
        timerAutoLink = [NSTimer DF_sheduledTimerWithTimeInterval:1 block:^
        {
            DDStrong(self)
            if (self)
            {
                if (!self.Bluetooth.isLink
                    && self.userInfo.pUUIDString
                    && [GetUserDefault(isNotRealNewBLE) boolValue]
                    && self.Bluetooth.isOn)    // 防止用户推出登录后仍会连接
                {
                    DDWeak(self)
                    NextWaitInGlobal(
                         DDStrong(self)
                         if(self) [self.Bluetooth retrievePeripheral:self.userInfo.pUUIDString];);
                }
            }
        } repeats:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [timerAutoLink DF_stop];
    timerAutoLink = nil;
    [super viewWillDisappear:animated];
}

-(void)setNavTitle:(UIViewController *)vc title:(NSString *)title
{
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.text = kString(title);
    lblTitle.font = [UIFont systemFontOfSize:20];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor whiteColor];
    vc.navigationItem.titleView = lblTitle;
}


-(void)resetBLEDelegate
{
    self.Bluetooth.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)initLeftButton:(NSString *)imgName text:(NSString *)text
{
    NSString *img = imgName ? imgName : @"back";
    if (!text && imgName)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 20, 20);
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@02",img]] forState:UIControlStateHighlighted];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else if(!imgName && text)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 80, 22);
        button.contentEdgeInsets = UIEdgeInsetsZero;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.titleLabel.textColor = DWhite;
        [button setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
        [button setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
        
        [button setTitle:kString(text) forState: UIControlStateNormal];
        [button setImageEdgeInsets: UIEdgeInsetsMake(0, -5, 0, 0)];
        [button setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -100)];   // 防止字太多， 无法显示
        [button setTitleColor:DWhite forState:UIControlStateNormal];
        [button setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
    }
}

-(void)initLeftButtonisInHead:(NSString *)imgName text:(NSString *)text
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(17, (NavBarHeight - 35 ) / 2 + 10, 80, 35)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.titleLabel.textColor = DWhite;
    [button setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
    [button setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
    
    [button setTitle:kString(text) forState: UIControlStateNormal];
    [button setImageEdgeInsets: UIEdgeInsetsMake(6, -5, 6, 0)];
    [button setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -70)];
    [button setTitleColor:DWhite forState:UIControlStateNormal];
    [button setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    for (UIView *vHead in self.view.subviews) {
        if (vHead.tag == 88) {
            [vHead addSubview:button];
            vHead.backgroundColor = DidConnectColor;
            break;
        }else if (vHead.tag == 89) {
            [vHead addSubview:button];
            vHead.backgroundColor = DClear;
            break;
        }
    }
}
-(void)initRightButtonisInHead:(NSString *)imgName text:(NSString *)text
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(ScreenWidth - (35 + 10), (NavBarHeight - 35 ) / 2 + 10, 35, 35);
    button.tag = 7699;
    if (imgName || text)
    {
        [button addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if (imgName){
            [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            [button setImage: [UIImage imageNamed:[NSString stringWithFormat:@"%@02",imgName]] forState: UIControlStateHighlighted];
            [button setImageEdgeInsets: UIEdgeInsetsMake(6, 6, 6, 6)];
        }
        else if (text)
        {
            button.frame = CGRectMake(ScreenWidth - 100 - 10, (NavBarHeight - 35 ) / 2 + 10 , 100, 35);
            [button setTitle:kString(text) forState:UIControlStateNormal];
            [button setTitleColor:DWhite forState:UIControlStateNormal];
            [button setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
            [button setBackgroundColor:DClear];
            [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        }
        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull vHead, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if (vHead.tag == 88) {
                 [vHead addSubview:button];
                 *stop = YES;
             }
         }];
    }else
    {
        [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull vHead, NSUInteger idx, BOOL * _Nonnull stop)
        {
            if (vHead.tag == 88)
            {
                [vHead.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj2.tag == 7699) {
                        [obj2 removeFromSuperview];
                        *stop = YES;
                    }
                }];
            }
        }];
    }
}

-(void)back
{
    self.isJumpLock = YES;
    if (self.isPop)
        [self.navigationController popViewControllerAnimated:YES];
    else
    {
        YRSideViewController *sideViewController = [self.appDelegate sideViewController];
        [sideViewController showLeftViewController:true];
    }
}

-(void)initRightButton:(NSString *)imgName text:(NSString *)text
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 22, 22);
    
    if (imgName || text) {
        [button addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }

    if (imgName)
    {
        [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@02",imgName]] forState:UIControlStateHighlighted];
    }
    else if (text)
    {
        button.frame = CGRectMake(0, 0, 80, 22);
        [button setTitle:kString(text) forState:UIControlStateNormal];
        
        if([DFD getLanguage] == 1)
        {
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 30 , 0, 0);
        }else
        {
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 20 , 0, -10);
        }
   
        [button setTitleColor:DWhite forState:UIControlStateNormal];
        [button setBackgroundColor:DClear];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
}

-(void)rightButtonClick
{
    // 用来重写
    NSLog(@"rightButtonClick");
}


-(void)clearLocalData
{
    [DFD returnUserNil];
    self.Bluetooth.isFailToConnectAgain = NO;
    SetUserDefault(isNotRealNewBLE, @(NO));
    [self.Bluetooth stopLink:nil];
    NSDictionary *dicData = [NSDictionary new];
    SetUserDefault(userInfoData, dicData);
    self.userInfo = nil;
}


-(void)gotoMainStoryBoard
{
    SetUserDefault(isNotRealNewBLE, @1);
    [timerAutoLink DF_stop];
    timerAutoLink = nil;
    [self bindJPush:YES];
    self.appDelegate.customTb.selectedIndex = 0;
    [self changeRootViewController:self.appDelegate.sideViewController];
}


-(void)gotoLoginStoryBoard:(NSString *)storyName
{
    SetUserDefault(isNotRealNewBLE, @0);
    SetUserDefault(ExitUserOnce, @0);
    [timerAutoLink DF_stop];
    timerAutoLink = nil;
    [self bindJPush:NO];
    if (storyName)
    {
        UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        vcBase *vc = [login instantiateViewControllerWithIdentifier:storyName];
        [self.appDelegate.loginNavigationController pushViewController:vc animated:NO];
    }
    [self changeRootViewController:self.appDelegate.loginNavigationController];
}


-(void)changeRootViewController:(UIViewController *)vc
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    self.windowView.rootViewController = vc;
    [self.windowView.layer addAnimation:transition forKey:@"animation"];
    [self.windowView makeKeyAndVisible];
}

-(void)setSideslip:(BOOL)isSlip
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.sideViewController.needSwipeShowMenu = isSlip;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

// BLEManagerDelegate
-(void)Found_CBPeripherals:(NSMutableDictionary *)recivedTxt
{
    NSMutableString *str = [NSMutableString string];
    for (NSString *key in recivedTxt.allKeys)
    {
        [str appendString:@"UUID:"];
        [str appendString:key];
        [str appendString:@"  name:"];
        [str appendString: ((CBPeripheral *)recivedTxt[key]).name];
        [str appendString:@"   "];
    }
    //NSLog(@"%@", str);
    
    self.dicBLEFound = recivedTxt;
    [self Found_Next:recivedTxt];
}

-(void)CallBack_ConnetedPeripheral:(NSString *)uuidString
{
    NSLog(@"已经连接 ---%@", uuidString);
    if (self.isFirstLink)
    {
        DDWeak(self)
        NextWaitInMain(
           DDStrong(self)
           if(self){
               self.isFirstLink = NO;
               self.userInfo.pUUIDString = uuidString;
               self.userInfo.pName = ((CBPeripheral *)self.dicBLEFound[uuidString]).name;
               DBSave
               MBHide
               LMBShow(@"绑定成功, 开始同步");
           }
        );
    }
    NSLog(@"----- > 同步开始 时间: %@", [NSDate date]);
//#warning TEST
//    
//    if (![DFD shareDFD].isForA5) {
//        [self.Bluetooth begin:uuidString];
//    }
    
    [self.Bluetooth begin:uuidString];
    
//    self.isLink = YES;
}



-(void)CallBack_DisconnetedPerpheral:(NSString *)uuidString
{
//    self.isLink = NO;
}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    if(!self.userInfo.access) return;
    switch (type) {
        case 307:                   // 闹钟读取完毕后的回调 // 检查是否好友一次性闹钟 并设置本地通知  // TODO  这里 因为误差太久 舍弃
            break;
        case 304:                   // 大数据读取完毕了    // 读取完相信数据后的回调
        {
            DDWeak(self)
            NextWaitInMain(
                   __block NSObject *blockObj = obj;
                   [weakself uploadData:^{
                        blockObj = @YES;
                    }];);
        }
            break;
        case 309:  // 实时的回调
        {
            NSArray *arrObj = (NSArray *)obj;
            int hour = [arrObj[0] intValue];
            int minute = [arrObj[1] intValue];
            int second = [arrObj[2] intValue];
            hour = hour;
            minute = minute;
            second = second;
            
            int walk,distance,calorie,situps,ropeSkipping,swim;
            walk = distance = calorie = situps = ropeSkipping = swim = 0;
            if (![DFD shareDFD].isForA5)
            {
                walk     = [arrObj[3] intValue];
                distance = [arrObj[4] intValue];
                calorie  = [arrObj[5] intValue];
                NSLog(@"步行:%d, 距离:%d, 热量:%d", walk,distance, calorie);
            }
            else
            {
                walk         = [arrObj[0] intValue];
                distance     = [arrObj[1] intValue];
                calorie      = [arrObj[2] intValue];
                situps       = [arrObj[3] intValue];
                ropeSkipping = [arrObj[4] intValue];
                swim         = [arrObj[5] intValue];
                NSLog(@"步行:%d, 距离:%d, 热量:%d, 仰卧起坐:%d, 跳绳%d, 游泳:%d", walk,distance, calorie, situps, ropeSkipping, swim);
            }
            
            self.isReadBLEChange = YES;
            NSDictionary *dicIndexDataOld = GetUserDefault(IndexData);
            if ([dicIndexDataOld.allKeys containsObject:myUserInfoAccess])
            {
                int dayOld = [((NSArray *)dicIndexDataOld[myUserInfoAccess])[0] intValue];
                if (dayOld == [DNow getFromDate:3])
                {
                    if (![DFD shareDFD].isForA5) {
                        int walkOld = [((NSArray *)dicIndexDataOld[myUserInfoAccess])[1] intValue];
                        if (walkOld == walk) {
                            self.isReadBLEChange = NO;
                        }
                    }else{
                        int walkOld  = [((NSArray *)dicIndexDataOld[myUserInfoAccess])[1] intValue];
                        int situpOld = [((NSArray *)dicIndexDataOld[myUserInfoAccess])[5] intValue];
                        
                        NSLog(@"步数：%d-%d, 仰卧起坐:%d-%d", walkOld, walk, situpOld, situps);
                        
                        if (walkOld == walk && situpOld == situps) {
                            self.isReadBLEChange = NO;
                        }
                    }
                }
            }
            
            BOOL isChange = NO;
            if(self.isReadBLEChange){
                NSLog(@"------- >  步数更新了");
                isChange = YES;
            }
            NSDictionary *dicIndexData = @{ self.userInfo.access : @[ @([DNow getFromDate:3]), @(walk), @(distance), (![DFD shareDFD].isForA5 ? @(calorie) : @(calorie / 10.0)), @(isChange), @0, @0, @0 ] };
            SetUserDefault(IndexData, dicIndexData);
        }
            break;
        case 250:  // 设置 抬手亮屏 日期菜单 断开震动 的回调
        {
            if (![DFD shareDFD].isForA5)
            {
                /*
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
                 */
                
                
                
                
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
                {
                    UserInfo *us = [UserInfo findFirstByAttribute:@"access" withValue:myUserInfoAccess inContext:localContext];
                    NSArray *arr = (NSArray *)obj;
                    self.userInfo.swithShowSreenWhenPut = us.swithShowSreenWhenPut = arr[14];
                    self.userInfo.swithShowMenu = us.swithShowMenu = arr[8];
                    self.userInfo.swithShockWhenDisconnect = us.swithShockWhenDisconnect = arr[24];
                    DLSave
                    DBSave
                }];
            }
            else
            {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
                {
                    NSArray *arr = (NSArray *)obj;
                    UserInfo *us = [UserInfo findFirstByAttribute:@"access" withValue:myUserInfoAccess inContext:localContext];
                    // NSArray *arr = @[ @(isShowDate),@(iS24),@(isShockWhenClock), @(isLightWhenClock), @(isShockWhenDisconnect), @(isShockWhenLowPower), @(isLightWhenCharging), @(isShockWhenButtonClick), @(isMetric), @(isChinese), @(isLightWhenPutUp) ];
                    
                    self.userInfo.swithShowSreenWhenPut = us.swithShowSreenWhenPut = [arr lastObject];
                    self.userInfo.swithShowMenu = us.swithShowMenu = [arr firstObject];
                    self.userInfo.swithShockWhenDisconnect = us.swithShockWhenDisconnect = arr[4];
                    DBSave;
                }];
            }
        }
            break;
    }
}


// 发现回调后的 接下来操作，
-(void)Found_Next:(NSMutableDictionary *)recivedTxt
{
}


-(void)getTokenAndUpload:(void (^)())failBlock                                           // 先获取权限， 然后上传
{
    self.isUpdataPhoto = NO;
    RequestCheckBefore(
          [net getToken_distribute_server:self.userInfo.access];,
          [self dataSuccessBack_getToken:dic];,
          if(failBlock) failBlock(););
}


#pragma mark aLiNetDelegate
-(void)upload:(BOOL)isOver url:(NSString *)url
{
    NSLog(@"上传结果： %@ url :%@", @(isOver), url);
    if (isOver) {
        self.image = nil;
        self.isUpdataPhoto = YES;
        if (self.upLoad_Next) {
            self.upLoad_Next(isOver ? url : @"");
        }else{
            NSLog(@"这里出错了");
        }
    }
}


-(void)dataSuccessBack_updateSportData:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        [DFD setLastUpLoadDateTime:[NSDate date] access:self.userInfo.access];                     // 设置最后的上传时间
        NSArray *arrDataRecord = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and isUpload == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
        for (int i = 0; i < arrDataRecord.count; i++)
        {
            DataRecord *dr = arrDataRecord[i];
            dr.isUpload = @YES;
        }
        self.isReadBLEChange = NO;
        DBSave;
    }
    else
    {
        NSLog(@"上传异常");
    }
}

-(void)dataSuccessBack_getToken:(NSDictionary *)dic
{
    [self.alinet initAndupload:self.image dic:dic];
}

-(void)bindJPush:(BOOL)isBind
{
    __block AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if ((delegate.isBind && !isBind) || (!delegate.isBind && isBind))
    {
        NSLog(@"------ > 去极光操作 : %@", @(isBind));
        [delegate repeatBind:YES];
    }
}

// 这里需要  加上延迟，  全局的延迟，  第一次 60s  第二次 80s  第三次 100  今天的以后都是 100 第二天重新 60 80 100
// 成功发送一次短信后，设置
-(void)setSMSInterval
{
    NSArray *arrSMS = GetUserDefault(dateLastPostSMS); // 1266
    int date = [DFD HmF2KNSDateToInt:DNow];
    int dateValue = 0;
    
    if ([arrSMS[0] intValue] == date)
    {
        dateValue = [arrSMS[2] intValue];
    }
    
    dateValue++;
    dateValue = dateValue > 3 ? 3 : dateValue;
//    NSLog(@"设置次数为: %d", dateValue);
    SetUserDefault(dateLastPostSMS, (@[@(date),DNow,@(dateValue)]));
}

// 返回当前的倒计时总秒数
-(int)getSMSInterval
{
    NSArray *arrSMS = GetUserDefault(dateLastPostSMS);
    int inter = (int)[(NSDate *)arrSMS[1] timeIntervalSinceNow] + 60 + ([arrSMS[2] intValue] - 1) * 20;
    return  inter;
}


// 从传入的步数，获取睡眠等级  3:深度 2：中度 1：浅度
-(NSNumber *)getNumberFromStep:(id)step
{
    int value = [step intValue];
    if (value < 10) {
        return @3;
    }else if (value < 30){
        return @2;
    }
    else{
        return @1;
    }
}

// 根据传入的 深睡，中睡， 浅睡 时长，返回睡眠等级，   3：良好   2：一般   1：较差
-(int)getSleepLevel:(NSArray*)arrValue{
    if (arrValue.count == 4) {
        return 0;
    }
    else if ([arrValue[0] intValue] >= 4) {
        return 3;
    }else if ([arrValue[0] intValue] >= 2){
        return 2;
    }else
        return 1;
}

-(NSString *)getSleepLevelStr:(NSArray*)arrValue{
    switch ([self getSleepLevel:arrValue]) {
        case 3:
            return kString(@"良好");
            break;
        case 2:
            return kString(@"一般");
            break;
        case 1:
            return kString(@"较差");
            break;
    }
    return @"未知";
}

// 通过 小时数 和 天数，获取平均后的 字符串，   例如，20小时， 15天， 返回 1小时25分钟
-(NSString*)getTimeStringByHours:(int)hours days:(int)days{
    if (!days) {
        return @"---";
    }
    int hour = hours / days;
    int minute = (hours % days) * 60 / days;
    NSString *str;
    if (minute) {
        str = [NSString stringWithFormat:@"%d%@%d%@", hour, kString(@"小时"), minute, kString(@"分钟")];
    }else
        str = [NSString stringWithFormat:@"%d%@", hour, kString(@"小时")];
    return str;
}

-(void)uploadData:(void(^)())block
{
    SetUserDefault(SynHistoryDataForLeftStep, @YES);
    // 判断是否有最新数据，  如果有， 上传  ，没有不上传
    NSArray *arrDataRecord = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and isUpload == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
    
    self.isReadBLEBack = YES;
    
    if (!arrDataRecord.count)
    {
        self.isReadBLEChange = NO;
        NSLog(@"没有需要上传的数据");
        block();
    }
    else
    {
        SetUserDefault(isSynDataOver, @YES);
        NSMutableArray *arrSub = [NSMutableArray new];
        NSDictionary *dicSub;
        
//#warning TEST  tianjia
//        int test[4] = { 8256, 8224, 7712, 7237 }; // @2016, @3, @1   @2016, @2, @1  @2015, @2, @1  2014, @3, @6
//        for (int i = 0; i < 4; i++) {
//            for (DataRecord *dr in arrDataRecord)
//            {
//                dicSub = [NSMutableDictionary new];
//                [dicSub setObject:@(test[i]) forKey:@"k_date"];
//                [dicSub setObject:dr.step_array forKey:@"sport_array"];
//                [dicSub setObject:dr.step_count forKey:@"sport_num"];
//                [dicSub setObject:dr.distance_count forKey:@"distance"];
//                [arrSub addObject:[dicSub mutableCopy]];
//            }
//        }
        
        for (DataRecord *dr in arrDataRecord)
        {
            dicSub = @{
                       @"type":@(isOnlyFirst ? 1:2),
                       @"k_date":dr.dateValue,
                       @"sport_array":dr.step_array,
                       @"sport_num":dr.step_count,
                       @"distance":dr.distance_count,
                       @"situps_num": dr.situps_count
                       };
            NSLog(@"没上传的 %@-%@-%@",dr.year, dr.month, dr.day);
            [arrSub addObject:[dicSub mutableCopy]];
        }
        NSString *jsonString = [DFD toJsonStringForUpload:arrSub];
        
        RequestCheckBefore(
               [net updateSportData:self.userInfo.access
                         sport_data:jsonString];,
               [self dataSuccessBack_updateSportData:dic];,
               DDStrong(self)
               if(self)self.isReadBLEChange = NO;)
    }
}

// 获取连续完成目标的天数
-(int)getContinuityDays
{
    int count = 0;
    int dateValue = [DFD HmF2KNSDateToInt:DNow];
    BOOL isBreak = NO;
    while (!isBreak)
    {
        DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", self.userInfo.access, @(dateValue)] inContext:DBefaultContext];
        if (dr && [dr.step_count intValue] >= [self.userInfo.user_sport_target intValue])
        {
            count++;
            dateValue = (int)[self getNextDayByThisDay:dateValue isPre:YES];
        }else
        {
            isBreak = YES;
        }
    }
    return count;
}

// 根据当天的 k_date 获取 前一天/后一天
-(int)getNextDayByThisDay:(int)thisDay isPre:(BOOL)isPre{
    
    NSDate *date;
    while (!date) {
        thisDay = thisDay + (isPre ? -1:1);
        date = [DFD HmF2KNSIntToDate:thisDay];
        if (thisDay < 0) {
            NSLog(@"这里报错了");
            break;
        }
    }
    int result = [DFD HmF2KNSDateToInt:date];
    return result;
}

-(int)getNextDayByThisDay:(int)thisDay isPre:(BOOL)isPre move:(int)move{
    
    int result = thisDay;
    for (int i = 0; i < move; i++)
    {
        result = [self getNextDayByThisDay:result isPre:isPre];
    }
    return result;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self toolCancelBtnClick];
}


-(void)initViewCover:(CGFloat)toolViewHeight toolBarColor:(UIColor *)toolBarColor
{
    _ViewCover = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
    _ViewCover.backgroundColor = DClear;
    
    if(SystemVersion >= 8)
    {
        _ViewEffectBody = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _ViewEffectBody.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _ViewEffectBody.alpha = 0;
        [self.view addSubview:_ViewEffectBody];
    }
    
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, _ViewCover.bounds.size.height - toolViewHeight + NavBarHeight, ScreenWidth, 44)];
    toolBarView.backgroundColor = toolBarColor ? toolBarColor: DidConnectColor;
    
    UIButton *CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [CancelButton setTitle:kString(@"取消") forState:UIControlStateNormal];
    [CancelButton addTarget:self action:@selector(toolCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    CancelButton.frame = CGRectMake(10, 0, 80, 44);
    [toolBarView addSubview:CancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:kString(@"确定") forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(ScreenWidth - 90, 0, 80, 44);
    [confirmButton addTarget:self action:@selector(toolOKBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:confirmButton];
    [_ViewCover addSubview:toolBarView];
    
    [self.view addSubview:_ViewCover];
}

// 显示覆盖图层
-(void)showViewCover
{
    [UIView animateWithDuration:0.5 animations:^{
        [_ViewCover setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
        _ViewEffectBody.alpha =  0.8;
    } completion:^(BOOL finished) {}];
}

-(void)toolCancelBtnClick
{
    [self toolCancelBtnClickAnimation];
    [UIView animateWithDuration:0.5 animations:^{
        if (_ViewCover) {
            [_ViewCover setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
            _ViewEffectBody.alpha =  0;
        }
    } completion:^(BOOL finished) {
        [self toolCancelBtnClickCompleted];
    }];
}
-(void)toolOKBtnClick
{
    [self toolOKBtnClickAnimation];
    [UIView animateWithDuration:0.5 animations:^{
        [_ViewCover setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
        _ViewEffectBody.alpha = 0;
    } completion:^(BOOL finished) {
        [self toolOKBtnClickCompleted];
        [self toolCancelBtnClickCompleted];
    }];
}

-(void)toolCancelBtnClickAnimation{}                 // 点击取消按钮后的操作，用于重写  和动画同步操作
-(void)toolOKBtnClickAnimation{}                     // 点击确定按钮后的操作，用于重写  和动画同步操作
-(void)toolCancelBtnClickCompleted{}                 // 点击取消按钮后的操作，用于重写  动画结束后
-(void)toolOKBtnClickCompleted{}                     // 点击确定按钮后的操作，用于重写  动画结束后




@end
