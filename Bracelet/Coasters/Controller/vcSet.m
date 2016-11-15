//
//  vcSet.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcSet.h"
#import "TAlertView.h"

@interface vcSet ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL            isShowSreenWhenPut;
    BOOL            isShowMenu;
    BOOL            isShockWhenDisconnect;
    BOOL            isUnit;
    
    NSInteger       selectedPickIndex;    // pick选中的索引
    NSInteger       currentIndex;         // 当前选中的索引  1 : 开始时间  2： 结束时间  3 ： 单位
}


@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;

@property (weak, nonatomic) IBOutlet UIView *viewFirst;
@property (weak, nonatomic) IBOutlet UIView *viewSecond;
@property (weak, nonatomic) IBOutlet UIView *viewThird;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblPName;
@property (weak, nonatomic) IBOutlet UIButton *btnBinding;
@property (weak, nonatomic) IBOutlet UILabel *lblBinding;
@property (weak, nonatomic) IBOutlet UIButton *btnMessageAlert;


@property (weak, nonatomic) IBOutlet UISwitch *swtShowSreenWhenPut;
@property (weak, nonatomic) IBOutlet UISwitch *swtShowMenu;
@property (weak, nonatomic) IBOutlet UISwitch *swtShockWhenDisconnect;


@property (weak, nonatomic) IBOutlet UIButton *btnUnit;
@property (weak, nonatomic) IBOutlet UIButton *btnAbout;
@property (weak, nonatomic) IBOutlet UILabel *lblPromt;
@property (weak, nonatomic) IBOutlet UILabel *lblUnit;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBindingWidth;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblPNameTitleTop;// 5
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblPNameTop; //5
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Top; //5
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBindTop; //15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblLightTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swt1Top; // 10
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Top; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSoundTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swt2Top; // 10
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swt3Top;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Top; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblNoTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFirstHeight; // 285
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblUnitTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line5Top; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblBarRemindTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSecondHeight; // 100
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewThirdHeight; // 50

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCorrectBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCorrectTop;



@property (nonatomic, strong) UIView                        *bgView;
@property (nonatomic, strong) UIPickerView                  *pickView;
@property (nonatomic, strong) NSArray                       *arrUnits;

- (IBAction)swtChange:(UISwitch *)sender;

@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet UIImageView *imvRightMessageAlert;
@property (weak, nonatomic) IBOutlet UIView *line4;



@end

@implementation vcSet

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"设置"];
    
    self.viewMainHeight.constant =  ScreenHeight - NavBarHeight;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData];
        [self initView];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self btnBackToWhite];
    _btnBinding.layer.borderWidth = 1;
    _btnBinding.layer.borderColor = DLightGray.CGColor;
    if(self.userInfo.pUUIDString)
    {
        [_btnBinding setTitle:kString(@"解绑") forState:UIControlStateNormal];
        [_btnBinding setTitleColor:DLightGray forState:UIControlStateNormal];
        [_btnBinding setTitleColor:DLightGray forState:UIControlStateHighlighted];
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:RGB(235, 235, 235)] forState:UIControlStateNormal];
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
        _btnBinding.tag = 10;
        _lblPName.text = self.userInfo.pName;
    }
    else
    {
        _lblBinding.text = kString(@"绑定");
        [_btnBinding setTitle:kString(@"绑定") forState:UIControlStateNormal];
        [_btnBinding setTitleColor:DWhite forState:UIControlStateNormal];
        [_btnBinding setTitleColor:DWhite forState:UIControlStateHighlighted];
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:RGB(50, 222, 248)] forState:UIControlStateNormal];
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:RGB(30, 202, 248)] forState:UIControlStateHighlighted];
        _btnBinding.tag = 11;
        _lblPName.text = kString(@"未绑定");
    }
    
}


-(void)dealloc
{
    NSLog(@"vcSet 被释放");
}


-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initData
{
     RequestCheckNoWaring(
           [net getUserSys:self.userInfo.access];,
           [self dataSuccessBack_getUserSys:dic];);
    [self refreshData];
}

-(void)refreshData
{
    _arrUnits = @[ kString(@"公制"), kString(@"英制") ];
    isShowSreenWhenPut = [self.userInfo.swithShowSreenWhenPut boolValue] && self.userInfo.pUUIDString;
    isShowMenu = [self.userInfo.swithShowMenu boolValue] && self.userInfo.pUUIDString;
    isShockWhenDisconnect = [self.userInfo.swithShockWhenDisconnect boolValue] && self.userInfo.pUUIDString;
    isUnit = [self.userInfo.unit boolValue];
}

-(void)refreshView
{
    [_swtShowSreenWhenPut setOn:isShowSreenWhenPut];
    [_swtShowMenu setOn:isShowMenu];
    [_swtShockWhenDisconnect setOn:isShockWhenDisconnect];
    _lblUnit.text = _arrUnits[isUnit ? 0 : 1];
}

-(void)initView
{
    CGFloat contentHeight;
    if (IPhone4) contentHeight = 470 + ([@(SystemVersion) intValue] == 8 ? 50:0);
    else if (IPhone5) contentHeight = 555-NavBarHeight+16;
    else if (IPhone6) contentHeight = 657-NavBarHeight+16;
    else if (IPhone6P) contentHeight = 726-NavBarHeight+16;
    self.viewMainHeight.constant = contentHeight;
    
//    Border(self.scrMain, DRed);
//    Border(self.viewMain, DBlue);
    
    _viewFirstHeight.constant = Bigger(RealHeight(420), 210);
    self.btnMessageAlert.hidden = self.lblMessage.hidden = self.imvRightMessageAlert.hidden = self.line4.hidden = YES;
//    if (![DFD shareDFD].isForA5 || 1)
//    {
//        _viewFirstHeight.constant = Bigger(RealHeight(420), 210);
//        self.btnMessageAlert.hidden = self.lblMessage.hidden = self.imvRightMessageAlert.hidden = self.line4.hidden = YES;
//    }else{
//        _viewFirstHeight.constant = Bigger(RealHeight(520), 260);
//    }
    
    _viewSecondHeight.constant = Bigger(RealHeight(200), 100);
    _viewThirdHeight.constant = Bigger(RealHeight(100), 50);
    
    _lblPNameTitleTop.constant = _lblPNameTop.constant = _line1Top.constant = (Bigger(RealHeight(120), 57) - 42 ) / 3.0;
    _btnBindTop.constant = (Bigger(RealHeight(120), 57) - 30) / 2.0;
    _swt1Top.constant = _swt2Top.constant = (Bigger(RealHeight(100), 51) - 30) / 2.0;
    _btnCorrectBottom.constant = _btnCorrectTop.constant =  _lblLightTop.constant = _lblSoundTop.constant = _lblNoTop.constant = _line2Top.constant = _line3Top.constant =  (Bigger(RealHeight(100), 51) - 21) / 2.0;
    
    
    _lblUnitTop.constant = _line5Top.constant = _lblBarRemindTop.constant = (Bigger(RealHeight(200), 100) - 43) / 4.0;

    _btnBindingWidth.constant = [DFD getLanguage] == 1 ? 60 : 100;
    
    
    NSString *notiText = [DFD isAllowedNotification] ? @"已开启":@"已关闭";
    NSArray *arr = @[@"设备名称",@"手环抬手亮屏",@"手环日期菜单",@"蓝牙断开震动",@"单位",@"通知栏提醒",@"关于",notiText];
    for (int i = 0; i < _arrLabel.count; i++)
    {
        UILabel *lbl = _arrLabel[i];
        lbl.text = kString(arr[i]);
    }
    _btnBinding.layer.cornerRadius = 10;
    _btnBinding.layer.masksToBounds = YES;
    [_btnBinding setTitleColor:DWhite forState:UIControlStateHighlighted];
    
    self.lblMessage.text = kString(@"消息提醒设置");
    
    _lblPromt.text = kString(@"如果要关闭或者开启接受消息通知,请在iPhone的'设置'—'通知'中,找到'红马手环'进行更改");
    
    [self.btnAbout setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
    [self.btnMessageAlert setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
    
    [_btnBinding setTitleColor:DWhite forState:UIControlStateHighlighted];
    
    [self refreshView];
    DDWeak(self)
    NextWaitInMain(
           DDStrong(self)
           [self initViewCover:300 toolBarColor:nil];
           [self initPickerView];);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


- (IBAction)btnClick:(UIButton *)sender
{
    [self btnBackToWhite];
    // 10 解绑  11 绑定  2 喝水提醒时间  4 单位 5 关于
    //NSLog(@"sender.tag = %d", sender.tag);
    
    switch (sender.tag)
    {
        case 10:        
        {
            TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定解除绑定吗?"];
            [alert showWithActionSure:^
             {
                 self.userInfo.pUUIDString = self.userInfo.pName = nil;
                 DBSave;
                 SetUserDefault(isNotRealNewBLE, @NO);
                 SetUserDefault(IndexTabelReload, @YES);
                 
                 [DFD setLastSysDateTime:[NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60] access:self.userInfo.access];// 设置最后的更新时间
                 [DFD setLastUpLoadDateTime:[NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60] access:self.userInfo.access];
                 
                 [self refreshData];    // 解除绑定后，  声音和灯光开关  关掉
                 [self refreshView];
                 
                 [DFD clearCBP];
                 
                 NSLog(@"禁用");
                 self.btnBinding.enabled = NO;
                 DDWeak(self)
                 NextWaitInMainAfter(
                          DDStrong(self)
                          NSLog(@"开启禁用");
                          if(self)self.btnBinding.enabled = YES;, 3);
                 DBSave;
                 
                 if (self.Bluetooth.isLink)
                 {
                     [self.Bluetooth stopLink:nil];
                     self.Bluetooth.isFailToConnectAgain = NO;
                     self.Bluetooth.isBeginOK = NO;
                     [self.Bluetooth begin:@""];
                 }
                 [self.Bluetooth stopScan];
                 
                 [self viewWillAppear:NO];
                 
             } cancel:^{}];
        }
            break;
        case 11:
        {
            if ([self isKindOfClass:[vcSet class]]) {
                [self performSegueWithIdentifier:@"set_to_search" sender:nil];
            }
        }
            break;
        case 2:
            if (self.Bluetooth.isLink) {
                [self performSegueWithIdentifier:@"set_to_remindTime" sender:nil];
            }else
            {
                LMBShow(NOConnect);
            }
            break;
        case 3:
        {
            if (self.Bluetooth.isLink) {
                [self performSegueWithIdentifier:@"set_to_messagealert" sender:nil];
            }else
            {
                LMBShow(NOConnect);
            }
        }
            break;
        case 4:
        {
            NSInteger ind = isUnit ? 0 : 1;
            [_pickView selectRow:ind inComponent:0 animated:NO];                selectedPickIndex = ind;
            currentIndex = 3;
            _pickView.delegate = self;
            _pickView.dataSource = self;
            [self showViewCover];
        }
            break;
        case 5:
            [self performSegueWithIdentifier:@"set_to_about" sender:nil];
            break;
    }
}

-(void)btnBackToWhite
{
    [self.btnAbout setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    [self.btnUnit setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    [self.btnMessageAlert setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
}

-(void)initPickerView
{
    _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256 + NavBarHeight, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickView.backgroundColor = DWhite;
    [self.ViewCover addSubview:_pickView];
}


#pragma mark UIPickerViewDataSource;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return  2;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return  _arrUnits[row];
}

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedPickIndex = row;
}

- (IBAction)swtChange:(UISwitch *)sender
{
    if (!self.userInfo.pUUIDString || !self.Bluetooth.isLink)
    {
        LMBShow(NOConnect);
        [sender setOn:!sender.isOn];
        return;
    }
    
    NSString *strPrompt = sender.isOn ? @"已开启" : @"已关闭";
    switch (sender.tag)
    {
        case 1:
            isShowSreenWhenPut = sender.isOn;
            self.userInfo.swithShowSreenWhenPut = @(isShowSreenWhenPut);
            break;
        case 2:
            isShowMenu = sender.isOn;
            self.userInfo.swithShowMenu = @(isShowMenu);
            break;
        case 3:
            isShockWhenDisconnect = sender.isOn;
            self.userInfo.swithShockWhenDisconnect = @(isShockWhenDisconnect);
            break;
    }
    DBSave;
    DDWeak(self)
    NextWaitInGlobal(
         DDStrong(self)
         [self.Bluetooth setUserinfoAndRead:self.userInfo.pUUIDString];
         DDWeak(self)
         NextWaitInMain(
                DDStrong(self)
                LMBShow(strPrompt);););
}

-(void)dataSuccessBack_getUserSys:(NSDictionary *)dic
{
    NSInteger status = [dic[@"status"] integerValue];
    if (status)
    {
        NSLog(@"用户没有上传， 使用默认的");
    }
    else
    {
        self.userInfo.unit = @([dic[@"sys_unit"] intValue] == 1);
        DBSave;
        [self refreshView];
    }
}


-(void)dataSuccessBack_updateSysSetting:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        self.userInfo.unit = @(isUnit);
        DBSave;
    }
}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    if (type == 250) {
        DDWeak(self)
        NextWaitInMain(
               DDStrong(self)
               [self refreshData];
               [self refreshView];);
    }
}


-(void)toolOKBtnClickAnimation
{
    if (currentIndex == 3)
    {
        isUnit = selectedPickIndex == 0;
        self.userInfo.unit = @(isUnit);
        DBSave;
        [self.Bluetooth setUserinfoAndRead:self.userInfo.pUUIDString];
        [self refreshView];
        
        RequestCheckAfter(
              [net updateSysSetting:self.userInfo.access
                           sys_unit:self->isUnit
                  sys_notify_status:[DFD isAllowedNotification]];,
              [self dataSuccessBack_updateSysSetting:dic];);
    }
}

-(void)toolCancelBtnClickCompleted
{
    _pickView.delegate = nil;
    _pickView.delegate = nil;
}






























@end
