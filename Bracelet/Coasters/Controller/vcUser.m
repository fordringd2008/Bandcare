//
//  vcUser.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcUser.h"
#import "tvcUser.h"
#import "UIViewController+GetAccess.h"
#import "vcBase+Share.h"
#import "TAlertView.h"
#import "HJCActionSheet.h"

@interface vcUser () <UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate, HJCActionSheetDelegate>
{
    NSString *      newNickName;
    BOOL            newGender;
    NSDate *        newBirthDay;
    NSDate *        dateLeft;
    NSDate *        dateRight;
    
    CGFloat         newHeight;
    CGFloat         newWeight;
    NSInteger       newTarget;
    NSInteger       newSitupTarget;
    
    
    NSString *      sexShow;              // 用于显示
    NSString *      heightShow;           // 用于显示
    NSString *      weightSHow;           // 用于显示
    NSString *      targetShow;           // 用于显示
    NSString *      situpShow;            // 用于显示
    
    NSString *      birthShow;            // 19890908                   用于上传
    NSString *      sleepShow;            // 09:30-18:30; 或者 AM        用于显示
    
    NSInteger       selectedIndex;        // 当前选择的table 索引
    NSInteger       selectedPickIndex;    // pick选中的索引
    
    NSInteger       selectedPickLeftIndex;
    NSInteger       selectedPickRightIndex;
    
    
    
    NSString *      unit;                 // 当前用户的体重单位
    
    BOOL            isChangeTarget;       // 是否修改目标值
    BOOL            isChangeOther;        // 是否修改了目标以外的
    BOOL            isAutoUpdate;         // 是否自动更新的
    
    
    
    UIView *        toolBarView;          //  确定 取消按钮栏
    UILabel *       lblEndTitle;          // 结束时间
    UILabel *       lblStartTitle;        // 开始时间
    
    BOOL            isLock;               // 延迟锁
    
}

@property (weak, nonatomic) IBOutlet UIView *viewHead;

@property (strong, nonatomic) UITableView                   *tabView;
@property (nonatomic, strong) UIDatePicker                  *datePicker;
@property (nonatomic, strong) UIPickerView                  *pickView;
@property (nonatomic, strong) NSMutableArray                *arrHeight;   //50 - 250           ！！！ 数组中带有单位
@property (nonatomic, strong) NSMutableArray                *arrWeigth;   //20 - 150
@property (nonatomic, strong) NSArray                       *arrSex;      //
@property (nonatomic, strong) NSMutableArray                *arrTarget;   //5000 - 20000 100递增
@property (nonatomic, strong) NSMutableArray                *arrSitUpsTarget;   //20 - 500 10递增
@property (nonatomic, strong) NSArray                       *arrPickSleepTimeData;

@property (nonatomic, copy)   NSString*                      photoUrl;
@property (nonatomic, strong) UIPickerView                  *pickerSleepTime;


@end

@implementation vcUser

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"个人信息"];
    
    [self refreshData_user];
    [self initView];
    
    RequestCheckNoWaring(
          [net getUserInfo:self.userInfo.access];,
          [self dataSuccessBack_getUserInfo:dic];);
    NextWaitInMain(
           DDStrong(self)
           [self initOtherView];);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    DDWeak(self)
    self.upLoad_Next = ^(NSString *url)
    {
        DDStrong(self)
        if(self)
        {
            NSLog(@"回调回来 ----- > url:%@", url);
            if(!url.length)
            {
                NSLog(@"图片上传失败");
                DDWeak(self)
                NextWaitInMain(
                       DDStrong(self)
                       [self waitBack];);
            }else
            {
                self.photoUrl = url;
                [self saveToServer];
            }
        }
    };
}

-(void)back
{
    [self rightButtonClick];
    // [super back];
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.upLoad_Next = nil;
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    NSLog(@"vcUser 销毁了");
}

-(void)refreshData_user
{
    newNickName = self.userInfo.user_nick_name;
    newGender = [self.userInfo.user_gender boolValue];
    newBirthDay = self.userInfo.user_birthday ? self.userInfo.user_birthday : DNow;
    birthShow = [DFD dateToString:newBirthDay stringType:@"YYYYMMdd"];
    newHeight = [self.userInfo.user_height doubleValue];
    newWeight = [self.userInfo.user_weight doubleValue];
    newTarget = [self.userInfo.user_sport_target integerValue];
    
    dateLeft = [DFD getDateFromString:self.userInfo.user_sleep_start_time];
    dateRight = [DFD getDateFromString:self.userInfo.user_sleep_end_time];
    selectedPickLeftIndex  = [dateLeft getFromDate:4];
    selectedPickRightIndex = [dateRight getFromDate:4];
    
    if (!dateLeft && !dateRight) {
        dateLeft = [DFD getDateFromString:@"2200"];
        dateRight = [DFD getDateFromString:@"0800"];
    }
    newSitupTarget = [self.userInfo.user_situps_target integerValue];
    
    self.photoUrl = self.userInfo.user_pic_url;
    unit = [self.userInfo.unit boolValue] ? @"Kg" : @"Lb";
    
    if ([self.userInfo.unit boolValue])
    {
        heightShow = [NSString stringWithFormat:@"%.0fcm", newHeight];
        weightSHow = [NSString stringWithFormat:@"%.0fKg", newWeight];
    }
    else
    {
        NSInteger ft = [self.userInfo.user_height doubleValue] * CmToFt;
        NSInteger iN =  round(([self.userInfo.user_height doubleValue] * CmToFt - ft) * 12.0);
        heightShow = [NSString stringWithFormat:@"%ld'%ld''", (long)ft, (long)iN];
        
        NSInteger wei = round([self.userInfo.user_weight floatValue] / KgToLb);
        weightSHow = [NSString stringWithFormat:@"%ld%@", (long)wei, unit];
    }
    
    targetShow = [NSString stringWithFormat:@"%@%@", self.userInfo.user_sport_target, kString(@"步")];
    sleepShow = [NSString stringWithFormat:@"%@-%@", [DFD getTimeStringFromDate:[dateLeft getNowDateFromatAnDate]], [DFD getTimeStringFromDate:[dateRight getNowDateFromatAnDate]]];
    
    situpShow = [NSString stringWithFormat:@"%@%@", self.userInfo.user_situps_target, kString(@"个")];
    
    _arrHeight = [NSMutableArray new];
    _arrWeigth = [NSMutableArray new];
    _arrTarget = [NSMutableArray new];
    _arrSitUpsTarget = [NSMutableArray new];
    
    
    int begigWeight = 20;
    int endWeight = 150;
    if (![unit isEqualToString:@"Kg"]) {
        begigWeight = 44;
        endWeight = 331;
    }
    for (int i = begigWeight; i <= endWeight; i++)
        [_arrWeigth addObject:[NSString stringWithFormat:@"%d%@", i, unit]];
    
    //   1.7  8.2
    if ([self.userInfo.unit boolValue])
        for (int i = 50; i <= 250; i++)
            [_arrHeight addObject:[NSString stringWithFormat:@"%dcm", i]];
    else
        for (int i = 1; i <= 8; i++)
            for (int j = 1; j < 12; j++)
                if ((i == 1 && j >= 7) || (i == 8 && j <= 2) || (i != 1 && i != 8))
                    [_arrHeight addObject:[NSString stringWithFormat:@"%d'%d''", i, j]];
    
    for (int i = 5000; i <= 20000; i+=100)
        [_arrTarget addObject:[NSString stringWithFormat:@"%d%@", i, kString(@"步")]];
    
    _arrSex = @[kString(@"男"), kString(@"女")];
    
    for (int i = 20; i <= 500; i+=10)
        [_arrSitUpsTarget addObject:[NSString stringWithFormat:@"%d%@", i, kString(@"个")]];
    
    
    
    if ([DFD isSysTime24]) {
        _arrPickSleepTimeData = @[@[ @"00:00",@"01:00",@"02:00",@"03:00",@"04:00",@"05:00",@"06:00",@"07:00",@"08:00",@"09:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00" ], @[ @"00:00",@"01:00",@"02:00",@"03:00",@"04:00",@"05:00",@"06:00",@"07:00",@"08:00",@"09:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00",@"16:00",@"17:00",@"18:00",@"19:00",@"20:00",@"21:00",@"22:00",@"23:00" ]];
    }
    else{
        _arrPickSleepTimeData = @[@[ @"12:00AM",@"1:00AM",@"2:00AM",@"3:00AM",@"4:00AM",@"5:00AM",@"6:00AM",@"7:00AM",@"8:00AM",@"9:00AM",@"10:00AM",@"11:00AM",@"12:00PM",@"1:00PM",@"2:00PM",@"3:00PM",@"4:00PM",@"5:00PM",@"6:00PM",@"7:00PM",@"8:00PM",@"9:00PM",@"10:00PM",@"11:00PM"],@[ @"12:00AM",@"1:00AM",@"2:00AM",@"3:00AM",@"4:00AM",@"5:00AM",@"6:00AM",@"7:00AM",@"8:00AM",@"9:00AM",@"10:00AM",@"11:00AM",@"12:00PM",@"1:00PM",@"2:00PM",@"3:00PM",@"4:00PM",@"5:00PM",@"6:00PM",@"7:00PM",@"8:00PM",@"9:00PM",@"10:00PM",@"11:00PM"]];
    }
}

-(void)initView
{
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    [self initTable];
}

-(void)initTable
{
    _tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStyleGrouped];
    _tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    _tabView.dataSource = self;
    _tabView.delegate = self;
    _tabView.showsVerticalScrollIndicator = NO;
    _tabView.backgroundColor = DLightGrayBlackGroundColor;
    [_tabView registerNib:[UINib nibWithNibName:@"tvcUser" bundle:nil] forCellReuseIdentifier:@"tvcUser"];
    [self.view addSubview:_tabView];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, NavBarHeight+10)];
    _tabView.tableFooterView = footView;
    
    UIButton *btnSignOut = [[UIButton alloc] initWithFrame:CGRectMake(RealWidth(160), 0, RealWidth(400), Bigger(RealHeight(70), 40))];
    [btnSignOut setBackgroundImage:[UIImage imageFromColor:DWhite] forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageFromColor:DLightGrayBlackGroundColor] forState:UIControlStateHighlighted];
    btnSignOut.layer.borderWidth = 1;
    [btnSignOut setTitleColor:DRed forState:UIControlStateNormal];
    btnSignOut.titleLabel.font = [UIFont fontWithName : @"Helvetica-Bold Oblique" size : 20 ];
    btnSignOut.layer.borderColor = DLightGray.CGColor;
    btnSignOut.layer.cornerRadius = 20;
    [btnSignOut.layer setMasksToBounds:YES];
    
    [btnSignOut setTitle:kString(@"退出登录") forState:UIControlStateNormal];
    [btnSignOut addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btnSignOut];
}

-(void)showMyORCode
{
    [self performSegueWithIdentifier:@"user_to_orcode" sender:nil];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return section ? (5+([DFD shareDFD].isForA5 ? 2:1)) : 4;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcUser *cell = [tvcUser cellWithTableView:tableView];
    [cell.imvBig setHidden:YES];
    [cell.lblValue setHidden: NO];
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                cell.lblTitle.text = kString(@"头像");
                [cell.lblValue setHidden: YES];
                [cell.imvBig setHidden: NO];
                
                if (self.image)
                    cell.imvBig.image = self.image;
                else
                    [cell.imvBig sd_setImageWithURL:[NSURL URLWithString:self.userInfo.user_pic_url] placeholderImage: DefaultLogoImage];
                cell.imvBig.layer.borderWidth = 1;
                cell.imvBig.layer.borderColor = DLightGray.CGColor;
                cell.imvBigHeight.constant = Bigger(RealHeight(120), 70) * 0.8;
                cell.imvBig.layer.cornerRadius = cell.imvBigHeight.constant / 2;
                [cell.imvBig.layer setMasksToBounds:YES];
                break;
            case 1:
                cell.lblTitle.text = kString(@"昵称");
                cell.lblValue.text = newNickName;
                break;
            case 2:
            {
                if(indexPath.row == 2 && [self.userInfo.loginType intValue] > 1)
                {
//                    cell.lblTitle.
                }else
                {
                    cell.lblTitle.text = kString(@"账号和密码");
                    cell.lblValue.text = self.userInfo.account;
                }
            }
                break;
            case 3:
                [cell.lblValue setHidden: YES];
                cell.lblTitle.text = kString(@"二维码名片");
                [cell.imvBig setHidden: NO];
                cell.imvBig.image = [UIImage imageNamed:@"qrCode"];
                cell.imvBigHeight.constant = Bigger(RealHeight(120), 70) * 0.5;
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
                cell.lblTitle.text = kString(@"性别");
                cell.lblValue.text = newGender ? kString(@"女") :kString(@"男");
                break;
            case 1:
                cell.lblTitle.text = kString(@"出生日期");
                cell.lblValue.text = [DFD dateToString:newBirthDay stringType:@"YYYY / MM / dd"];
                break;
            case 2:
                cell.lblTitle.text = kString(@"身高");
                cell.lblValue.text = heightShow;
                break;
            case 3:
                cell.lblTitle.text = kString(@"体重");
                cell.lblValue.text = weightSHow;
                break;
            case 4:
                cell.lblTitle.text = kString(@"运动目标步数");
                cell.lblValue.text = [NSString stringWithFormat:@"%d%@", (int)newTarget, kString(@"步")];
                break;
            case 5:
                cell.lblTitle.text = kString(@"睡觉时间");
                cell.lblValue.text = sleepShow;
                break;
            case 6:
                cell.lblTitle.text = kString(@"仰卧起坐目标数");
                cell.lblValue.text = situpShow;
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                HJCActionSheet *sheet = [[HJCActionSheet alloc] initWithDelegate:self CancelTitle:kString(@"取消") OtherTitles:kString(@"拍照"), kString(@"从手机相册中选择"), nil];
                [sheet show];
            }
                break;
            case 1:
            {
                TAlertView *alterAccount =[[TAlertView alloc] initWithTitle:@"请输入新昵称" message:@""];
                alterAccount.strOriginal = newNickName;
                [alterAccount showWithTXFActionSure:^(id str) {
                    newNickName = str;
                    newNickName = newNickName.length > 20 ? [newNickName substringToIndex:20] : newNickName;
                    isChangeOther = YES;
                    [_tabView reloadData];
                } cancel:^{}];
            }
                break;
            case 2:
                [self performSegueWithIdentifier:@"user_to_editPassword" sender:nil];
                break;
            case 3:
                [self performSegueWithIdentifier:@"user_to_orcode" sender:nil];
                break;
        }
    }
    else
    {
        [self isTwoDatePick:NO];
        
        selectedIndex               = indexPath.row;
        _pickView.delegate          = self;
        _pickView.dataSource        = self;
        _pickerSleepTime.delegate   = self;
        _pickerSleepTime.dataSource = self;

        switch (indexPath.row) {
            case 0:
            {
                _datePicker.hidden = YES;
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:0];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
                [_pickView reloadAllComponents];
            }
                break;
            case 1:
            {
                _datePicker.hidden = NO;
                _pickView.hidden = YES;
            }
                break;
            case 2:
            {
                _datePicker.hidden = YES;
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:2];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
                [_pickView reloadAllComponents];
            }
                break;
            case 3:
            {
                _datePicker.hidden = YES;
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:3];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
                [_pickView reloadAllComponents];
            }
                break;
            case 4:
            {
                _datePicker.hidden = YES;
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:4];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
                [_pickView reloadAllComponents];
            }
                break;
            case 5:
            {
                _datePicker.hidden = YES;
                _pickView.hidden = YES;
                NSInteger ind0 = [self getPickViewIndex:50];
                NSInteger ind1 = [self getPickViewIndex:51];
                [_pickerSleepTime selectRow:ind0 inComponent:0 animated:NO];
                [_pickerSleepTime selectRow:ind1 inComponent:1 animated:NO];
                [self isTwoDatePick:YES];
            }
                break;
            case 6:
            {
                _datePicker.hidden = YES;
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:6];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
                [_pickView reloadAllComponents];
            }
                break;
        }
        [self pickerViewPopAnimationsRelod];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            return Bigger(RealHeight(120), 70);
        }else if(indexPath.row == 2 && [self.userInfo.loginType intValue] > 1) {
            return 0;
        }
        else if(indexPath.row == 6 && ![DFD shareDFD].isForA5) {
            return 0;
        }
    }
    
    return Bigger(RealHeight(90), 60);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(void)btnClick
{
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定退出?"];
    [alert showWithActionSure:^
    {
        [DFD setLastSysDateTime:[NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60] access:self.userInfo.access];// 设置最后的更新时间
        [DFD setLastUpLoadDateTime:[NSDate dateWithTimeIntervalSinceNow:-24 * 60 * 60] access:self.userInfo.access];
        
        SetUserDefault(PushAlias, myUserInfoAccess);
        RemoveUserDefault(userInfoAccess);
        RemoveUserDefault(userInfoData);
        [self clearDataFrom3Class];
        
        // 断开所有连接
        SetUserDefault(isNotRealNewBLE, @NO);
        [self.Bluetooth stopLink:nil];
        self.Bluetooth.delegate = nil;
        self.upLoad_Next = nil;
        [BLEManager resetBLE];
        self.Bluetooth.isFailToConnectAgain = NO;
        [DFD returnUserNil];
        
        [self.navigationController popViewControllerAnimated:NO];
        __block vcUser *blockSelf = self;
        NextWaitInMainAfter(
                [blockSelf gotoLoginStoryBoard:nil];, 0.3);
     } cancel:^{}];
}

#pragma mark UIPickerViewDataSource;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (selectedIndex)
    {
        case 0:
            return 2;
            break;
        case 2:
            return  _arrHeight.count;
            break;
        case 3:
            return  _arrWeigth.count;
            break;
        case 4:
            return  _arrTarget.count;
            break;
        case 5:
            return 24;
            break;
        case 6:
            return  _arrSitUpsTarget.count;
            break;
            
        default:
            break;
    }
    return  2;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:_pickerSleepTime]) {
        return 2;
    }
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (selectedIndex) {
        case 0:
            return  _arrSex[row];
            break;
        case 2:
            return  _arrHeight[row];
            break;
        case 3:
            return [NSString stringWithFormat:@"%d", [_arrWeigth[row] intValue]];
            break;
        case 4:
            
            return [NSString stringWithFormat:@"%d", [_arrTarget[row] intValue]];
            break;
        case 5:
        {
            return  self.arrPickSleepTimeData[component][row];
        }
            break;
        case 6:
            return  [NSString stringWithFormat:@"%d", [_arrSitUpsTarget[row] intValue]];
            break;
            
        default:
            break;
    }
    return  @"111";
}

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:_pickerSleepTime]) {
        if (!component) {
            selectedPickLeftIndex = row;
        }else{
            selectedPickRightIndex = row;
        }
    }else{
        selectedPickIndex = row;
    }
}

#pragma mark HJCActionSheetDelegate
- (void)actionSheet:(HJCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [DFD getPictureFormPhotosOrCamera:buttonIndex != 1
                                   vc:self
                    checekBeforeBlock:^{[self getAccessNext:(buttonIndex == 1 ? CameraAccess:PhotosAccess ) block:^{}];}];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    for (UINavigationItem *item in navigationController.navigationBar.subviews)
    {
        if ([item isKindOfClass:[UIButton class]]&&([item.title isEqualToString:@"取消"]||[item.title isEqualToString:@"Cancel"]))
        {
            UIButton *button = (UIButton *)item;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
    }
}


#pragma mark -- 选中图片后的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    isChangeOther = YES;
    self.image = image;
    [_tabView reloadData];
    [self dismissViewControllerAnimated:YES completion:^{}];
}
//
//#pragma mark - imagepicker delegate  使用相册
//-(void)pickImageFromAlbum
//{
//    [self getAccessNext:PhotosAccess block:^{}];
//    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
//        
//    }
//    pickerImage.delegate = self;
//    pickerImage.allowsEditing = YES;
//    pickerImage.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self.navigationController presentViewController:pickerImage animated:YES completion:^{}];
//}
//
//
//#pragma mark - imagepicker delegate  使用相机
//-(void)pickImageFromCamera
//{
//    [self getAccessNext:CameraAccess block:^{}];
//    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
//        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    picker.sourceType = sourceType;
//    [self.navigationController presentViewController:picker animated:YES completion:^{ }];
//}


-(void)initBigView
{
    self.ViewCover = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
    self.ViewCover.backgroundColor = DClear;
    if(SystemVersion >= 8)
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.ViewEffectBody = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.ViewEffectBody.frame = self.ViewCover.bounds;
        self.ViewEffectBody.alpha = 0;
        [self.view addSubview:self.ViewEffectBody];
    }
    
    toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.ViewCover.bounds.size.height - 300 + NavBarHeight, self.ViewCover.bounds.size.width, 44)];
    
    toolBarView.backgroundColor = DidConnectColor;
    
    lblStartTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, self.ViewCover.bounds.size.height - 280 + NavBarHeight, ScreenWidth / 2, 40)];
    lblStartTitle.textAlignment = NSTextAlignmentCenter;
    lblStartTitle.textColor = DidConnectColor;
    lblStartTitle.backgroundColor = DWhite;
    lblStartTitle.font = [UIFont systemFontOfSize:14];
    lblStartTitle.text = kString(@"开始时间");
    [self.ViewCover addSubview:lblStartTitle];
    
    lblEndTitle = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2, self.ViewCover.bounds.size.height - 280 + NavBarHeight, ScreenWidth / 2, 40)];
    lblEndTitle.textAlignment = NSTextAlignmentCenter;
    lblEndTitle.textColor = DidConnectColor;
    lblEndTitle.backgroundColor = DWhite;
    lblEndTitle.font = [UIFont systemFontOfSize:14];
    lblEndTitle.text = kString(@"结束时间");
    [self.ViewCover addSubview:lblEndTitle];
    
    [self isTwoDatePick:NO];

    
    UIButton *CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [CancelButton setTitle:kString(@"取消") forState:UIControlStateNormal];
    [CancelButton addTarget:self action:@selector(pickerViewCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    CancelButton.frame = CGRectMake(10, 0, 80, 44);
    [toolBarView addSubview:CancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:kString(@"确定") forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(ScreenWidth - 90, 0, 80, 44);
    [confirmButton addTarget:self action:@selector(pickerViewConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:confirmButton];
    [self.ViewCover addSubview:toolBarView];
    [self.view addSubview:self.ViewCover];
}

// 是否还有2个日期选择器
-(void)isTwoDatePick:(BOOL)isTwo
{
    if (!isTwo) {
        toolBarView.frame = CGRectMake(0, self.ViewCover.bounds.size.height - 300  + NavBarHeight, self.ViewCover.bounds.size.width, 44);
        lblEndTitle.hidden = YES;
        lblStartTitle.hidden = YES;
        _pickerSleepTime.hidden = YES;
    }else
    {
        toolBarView.frame = CGRectMake(0, self.ViewCover.bounds.size.height - 324 + NavBarHeight, self.ViewCover.bounds.size.width, 44);
        lblEndTitle.hidden = NO;
        lblStartTitle.hidden = NO;
        _pickerSleepTime.hidden = NO;
    }
}

-(void)initPickerView
{
    _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256  + NavBarHeight, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickView.backgroundColor = DWhite;// RGB(239, 239, 239);
    [self.ViewCover addSubview:_pickView];
}

//初始化DatePickerView
- (void)initDatePickerView
{
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256 + NavBarHeight, ScreenWidth, 256 - NavBarHeight)];
    [_datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:[DFD getLanguage] == 1 ? @"zh_CN" :@"en_US"]];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.date = newBirthDay;
    _datePicker.backgroundColor = DWhite;
    _datePicker.maximumDate = DNow;
    [self.ViewCover addSubview:_datePicker];
    
    
    _pickerSleepTime = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256  + NavBarHeight, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickerSleepTime.backgroundColor = DWhite;
    [self.ViewCover insertSubview:_pickerSleepTime atIndex:0];
}

// 获取当前的选中的内容在pickView中的索引
-(NSInteger)getPickViewIndex:(NSInteger)ind
{
    NSInteger inde = 0;
    switch (ind) {
        case 0:
        {
            inde = (int)newGender;
        }
            break;
        case 2:
        {
            for (int i = 0; i < _arrHeight.count; i++)
            {
                if ([_arrHeight[i] isEqualToString:heightShow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 3:
        {
            for (int i = 0; i < _arrWeigth.count; i++)
            {
                if ([_arrWeigth[i] isEqualToString:weightSHow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 4:
        {
            for (int i = 0; i < _arrTarget.count; i++)
            {
                if ([_arrTarget[i] isEqualToString:targetShow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 50:
        {
            for (int i = 0; i < 24; i++)
            {
                NSString *str = [DFD getTimeStringFromDate:[dateLeft getNowDateFromatAnDate]];
                if ([_arrPickSleepTimeData[0][i] isEqualToString:str])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 51:
        {
            for (int i = 0; i < 24; i++)
            {
                NSString *str = [DFD getTimeStringFromDate:[dateRight getNowDateFromatAnDate]];
                if ([_arrPickSleepTimeData[1][i] isEqualToString:str])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 6:
        {
            for (int i = 0; i < _arrSitUpsTarget.count; i++)
            {
                if ([_arrSitUpsTarget[i] isEqualToString:situpShow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
            
        default:
            break;
    }
    return  inde;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pickerViewDisappear];
}

#pragma mark PickerView取消按钮事件
- (void)pickerViewCancelButtonClick
{
    [self pickerViewDisappear];
}

#pragma mark PickerView确定按钮事件
- (void)pickerViewConfirmButton
{
    if (selectedIndex == 5)
    {
        if (selectedPickLeftIndex == selectedPickRightIndex) {
            LMBShow(@"请选择正确的睡眠时间");
            return;
        }else{
            isChangeOther = YES;
            dateLeft = [[DFD getDateFromArr:@[@(selectedPickLeftIndex),@0,@0,@0]] clearTimeZone];
            dateRight = [[DFD getDateFromArr:@[@(selectedPickRightIndex),@0,@0,@0]] clearTimeZone];
            sleepShow = [NSString stringWithFormat:@"%@-%@", [DFD getTimeStringFromDate:[dateLeft getNowDateFromatAnDate]], [DFD getTimeStringFromDate:[dateRight getNowDateFromatAnDate]]];
        }
    }
    
    [self pickerViewDisappear];
    switch (selectedIndex) {
        case 0:
        {
            isChangeOther = YES;
            newGender = (BOOL)selectedPickIndex;
        }
            break;
        case 1:
        {
            isChangeOther = YES;
            newBirthDay = [_datePicker date] ;
            birthShow = [DFD dateToString:newBirthDay stringType:@"YYYYMMdd"];
        }
            break;
        case 2:
        {
            isChangeOther = YES;
            NSString *height = _arrHeight[selectedPickIndex];
            if ([self.userInfo.unit boolValue])
            {
                heightShow = [NSString stringWithFormat:@"%@", height];
                newHeight = [height doubleValue];
            }
            else
            {
                heightShow = [NSString stringWithFormat:@"%@", height];
                NSArray *arr = [height componentsSeparatedByString:@"'"];
                NSInteger ft = [arr[0] integerValue];
                NSInteger iN = [arr[1] integerValue];
                newHeight = (ft +  (double)iN / 12.0) / CmToFt;
            }
        }
            break;
        case 3:
        {
            isChangeOther = YES;
            NSString *weight = _arrWeigth[selectedPickIndex];
            if ([self.userInfo.unit boolValue])
            {
                weightSHow = [NSString stringWithFormat:@"%@", weight];
                newWeight = [weight doubleValue];
            }
            else
            {
                weightSHow = [NSString stringWithFormat:@"%@", weight];
                newWeight =  [weight doubleValue] * KgToLb;
            }
        }
            break;
        case 4:
        {
            isChangeTarget = YES;
            targetShow = _arrTarget[selectedPickIndex];
            newTarget = [targetShow integerValue];
            isChangeTarget = newTarget != [self.userInfo.user_sport_target intValue];
        }
            break;
        case 6:
        {
            isChangeOther = YES;
            situpShow = _arrSitUpsTarget[selectedPickIndex];
            newSitupTarget = [situpShow integerValue];
        }
            break;
            
        default:
            break;
    }
    [_tabView reloadData];
}

//pickView弹出动画
-(void)pickerViewPopAnimationsRelod
{
    [UIView transitionWithView:self.ViewCover duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         [self.ViewCover setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
         [self.ViewEffectBody setAlpha:0.8];
     } completion:^(BOOL finished) {}];
}

- (void)pickerViewDisappear
{
    [UIView transitionWithView:self.ViewCover duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ViewCover setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
        [self.ViewEffectBody setAlpha:0];
    } completion:^(BOOL finished) {
        _pickView.delegate = nil;
        _pickView.dataSource = nil;
        _pickerSleepTime.delegate = nil;
        _pickerSleepTime.dataSource = nil;
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)rightButtonClick
{
    if(isLock) return;
    if (!isChangeOther && !isChangeTarget)
    {
        [super back];
        return;
    }
    if (newNickName.length == 0) {
        LMBShow(@"昵称未填写");
        [super back];
        return;
    }
    if ([newNickName rangeOfString:@"null"].length || [newNickName rangeOfString:@"nil"].length || [newNickName rangeOfString:@"NULL"].length || [NSString isHaveEmoji:newNickName]) {
        LMBShow(@"昵称中包含了不能识别的字符");
        [super back];
        return;
    }
    //  这里要发送指令                 //  是先 上传 还是 先发送指令
    //  情况1: 无网，  用户只修改了目标值  提示修改成功， 发送指令  更新本地个人目标信息，
    //  情况2: 无网，  用户修改了目标值， 并修改了其他需要网络的， 提示网络异常， 但是也要发送指令 更新本地喝水目标信息
    //  以上  拉去个人信息的时候， 要判断，时间戳， 比较本地上次修改时间戳，从而选择 最新的， 本地最新，覆盖服务器， 服务器最新，覆盖本地

    isLock = YES;
    DDWeak(self)
    NextWaitInMainAfter(
            DDStrong(self)
            if(self)self->isLock = NO;
            , 3);
    if (self.image)                               // 如果用户更改了图片
    {
        [self getTokenAndUpload:^{
            DDStrong(self)
            DDWeak(self)
            NextWaitInMain(
                   DDStrong(self)
                   [self waitBack];);
        }];

    }else [self saveToServer];
}

-(void)waitBack
{
    LMBShow(NONetTip);
    NextWaitInMainAfter([super back];, 1);
}


-(void)saveToServer
{
    if (newTarget != [self.userInfo.user_sport_target intValue]) {
        [self setTarget_:NO];
        NSDictionary *dicIndexData = GetUserDefault(IndexData);
        NSMutableArray *subArr = [(NSArray *)dicIndexData[self.userInfo.access] mutableCopy];
        subArr[4] = @YES;
        SetUserDefault(IndexData, (@{ self.userInfo.access : [subArr mutableCopy] }));
    }
    
    self.userInfo.user_nick_name        = newNickName;
    self.userInfo.user_gender           = @(newGender);
    self.userInfo.user_height           = @(newHeight);
    self.userInfo.user_weight           = @(newWeight);
    self.userInfo.user_birthday         = newBirthDay;
    self.userInfo.user_sport_target     = @(newTarget);
    self.userInfo.user_pic_url          = self.photoUrl;
    self.userInfo.user_sleep_start_time = [DFD dateToString:dateLeft stringType:@"HH:mm"];
    self.userInfo.user_sleep_end_time   = [DFD dateToString:dateRight stringType:@"HH:mm"];
    self.userInfo.user_situps_target    = @(newSitupTarget);
    self.userInfo.update_time           = @([DNow timeIntervalSince1970] * 1000);
    [self.userInfo perfect];
    DBSave;
    
    NSMutableDictionary *dicUp = [NSMutableDictionary dictionary];
    [dicUp setObject:self.userInfo.access forKey:@"access"];
    [dicUp setObject:(self.photoUrl ? self.photoUrl : @"" )forKey:@"user_pic_url"];
    [dicUp setObject:newNickName forKey:@"user_nick_name"];;
    [dicUp setObject:@(newGender ? 1 : 0) forKey:@"user_gender"];
    [dicUp setObject:@(newHeight ? newHeight : 170) forKey:@"user_height"];
    [dicUp setObject:@(newWeight ? newWeight : 70) forKey:@"user_weight"];
    [dicUp setObject:birthShow forKey:@"user_birthday"];
    [dicUp setObject:@(newTarget ? newTarget : 2000) forKey:@"user_sport_target"];
    [dicUp setValue:[DFD dateToString:dateLeft stringType:@"HHmm"] forKey:@"user_sleep_start_time"];
    [dicUp setValue:[DFD dateToString:dateRight stringType:@"HHmm"] forKey:@"user_sleep_end_time"];
    [dicUp setValue:@(newSitupTarget) forKey:@"user_situps_target"];
    
    DDDWeak(self)
    if (!isAutoUpdate)
    {
        NextWaitInMain(
               DDDStrong(self)
               if(self) LMBShow(@"个人信息更新成功"););
    }
    
    RequestCheckBefore(
         self.photoUrl = self.photoUrl;  // 防止报错
         [net updateUserInfo:dicUp];,
         [self dataSuccessBack_updateUserInfo:dic];,
         [super back];)
}


// 设置目标， 是否提示
-(void)setTarget_:(BOOL)isPrompt
{
    if (isChangeTarget)    // 先发送指令
    {
        if(self.Bluetooth.isLink)
        {
            self.userInfo = [UserInfo MR_findFirstByAttribute:@"access" withValue:myUserInfoAccess inContext:DBefaultContext];
            self.userInfo.user_sport_target = @(newTarget);
            NSTimeInterval inter = [DNow timeIntervalSince1970] * 1000;
            self.userInfo.update_time = @(inter);
            DBSave;
            [self.Bluetooth setUserInfo:self.userInfo.pUUIDString arr:nil];
            
            //if (isPrompt) LMBShow(@"喝水目标设置成功");
            isChangeTarget = NO;
        }
        else
        {
            if (isPrompt) LMBShow(NOConnect);
        }
    }
}

-(void)dataSuccessBack_getUserInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
//        self.userInfo = [[UserInfo findByAttribute:@"access" withValue:myUserInfoAccess inContext:DBefaultContext] firstObject];
//        self.userInfo.account               = myUserInfo.account;
//        self.userInfo.user_pic_url          = dic[@"user_pic_url"];
//        self.userInfo.user_nick_name        = dic[@"user_nick_name"];
//        self.userInfo.user_gender           = @([(NSString *)dic[@"user_gender"] intValue]);
//        self.userInfo.user_weight           = @([(NSString *)dic[@"user_weight"] doubleValue]);
//        self.userInfo.user_height           = @([(NSString *)dic[@"user_height"] doubleValue]);
//        self.userInfo.user_birthday         = [DFD toDateByString:dic[@"user_birthday"]];
//        self.userInfo.user_situps_target    = @([(NSString *)dic[@"user_situps_target"] intValue]);
//        self.userInfo.user_sleep_start_time = dic[@"user_sleep_start_time"];
//        self.userInfo.user_sleep_end_time   = dic[@"user_sleep_end_time"];
//        self.userInfo.user_language_code    = dic[@"user_language_code"];
        
        // 拉去个人信息的时候， 要判断服务器时间戳是否大于本地
        long long interServer = [dic[@"update_time"] longLongValue];
        long long interLocal =  [self.userInfo.update_time longLongValue];
        
        NSLog(@"%@", interServer >= interLocal ? @"服务器大于等于本地 " : @"服务器小于本地");
        
        if (interServer >= interLocal)
        {
            self.userInfo = [UserInfo objectByDictionary:dic
                                                 context:DBefaultContext
                                            perfectBlock:^(id model) {
                                                UserInfo * user = model;
                                                user.account = myUserInfo.account;
                                            }];
        }else{
            __block NSNumber *update_time  = @([(NSString *)dic[@"update_time"] longLongValue]);
            self.userInfo = [UserInfo objectByDictionary:dic
                                                 context:DBefaultContext
                                            perfectBlock:^(id model) {
                                                UserInfo * user = model;
                                                user.account     = myUserInfo.account;
                                                user.update_time = update_time;
                                            }];
            newTarget = [self.userInfo.user_sport_target integerValue];
            isAutoUpdate = YES;
            isChangeTarget = NO;
            isChangeOther = YES;
            [self saveToServer];
        }

        
        
        [self refreshData_user];
        [self.tabView reloadData];
    }
}

-(void)dataSuccessBack_updateUserInfo:(NSDictionary *)dic
{
    MBHide;
    if (!isAutoUpdate) [super back];
    
    if (CheckIsOK)
    {
        NSLog(@"---------- > 这里回来了");
        isAutoUpdate = NO;
        self.userInfo.update_time = @([dic[@"update_time"] longLongValue]);
        DBSave;
    }
    else
    {
        NSLog(@"--------------- 保存失败");
    }
}

-(void)initOtherView
{
    [self initBigView];
    [self initPickerView];
    [self initDatePickerView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}



@end
