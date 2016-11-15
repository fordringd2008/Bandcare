//
//  vcEditClock.m
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcEditClock.h"
#import "tvcEditClock.h"
#import "vcEditRepeat.h"

@interface vcEditClock () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, vcEditRepeatDelegate>
{
    NSDate *        dateSelected;                   // 暂存的数据，  保存时 赋值
    NSMutableArray *arrRepeat;
    int             typeSelect;                     // 选中的 1 2 4
    
    NSString *      dateString;
    NSString *      repeatSttring;
    
    int             typeFromPick;                   // 下拉产生的  点击确定按钮，才会赋值给暂存
    
    NSString *      typeString;
    BOOL            isEditTime;                     // 是否要修改时间
}


@property (weak, nonatomic) IBOutlet UIView *                 viewMain;
@property (weak, nonatomic) IBOutlet UITableView *             tabView;
@property (nonatomic, strong) NSArray *                         arrTitle;
@property (nonatomic, strong) NSArray *                         arrValue;
@property (nonatomic, strong) NSArray *                         arrPicker;
@property (nonatomic, strong) UIDatePicker *                    datePicker;
@property (nonatomic, strong) UIPickerView *                    pickerView;
@property (weak, nonatomic) IBOutlet UIView *viewHead;



@end

@implementation vcEditClock

- (void)viewDidLoad
{
    NSLog(@"加载时间");
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:(_isAdd ? @"新增闹钟":@"修改闹钟")];
    [self initRightButtonisInHead:@"save" text:nil];
    
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshData];
    [self.tabView reloadData];
}

-(void)dealloc
{
    NSLog(@"vcEditClock 销毁了");
}


-(void)initData
{
    if(!self.clock)
    {
        self.clock = [[Clock findAllSortedBy:@"iD" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"type == %@", @0]] firstObject];
        NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@", self.clock.isOn, self.clock.strRepeat, self.clock.strTime, self.clock.type);
    }
    
    self.arrTitle = @[ kString(@"时间"), kString(@"重复"), kString(@"类型") ];
    self.arrPicker = @[ kString(@"普通闹钟"), kString(@"吃药提醒"), kString(@"要事提醒") ];
    
    NSInteger hour_ = [self.clock.hour intValue];
    NSInteger minute_ = [self.clock.minute intValue];
    
    if (hour_ == 0 && minute_ == 0 && [self.clock.type intValue] == 0) {
        dateSelected = DNow;
    }else
    {
        dateSelected = [[DFD getDateFromArr:@[ @(hour_), @(minute_), @0, @0]] clearTimeZone];
    }
    
    arrRepeat = [[self.clock.repeat componentsSeparatedByString:@"-"] mutableCopy];
    typeSelect = [self.clock.type intValue];
}

-(void)refreshData
{
    dateString = [DFD getTimeStringFromDate:[dateSelected getNowDateFromatAnDate]];
    NSMutableString *strRepeat = [NSMutableString new];
    if ([arrRepeat[0] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周日")]];
    if ([arrRepeat[1] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周一")]];
    if ([arrRepeat[2] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周二")]];
    if ([arrRepeat[3] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周三")]];
    if ([arrRepeat[4] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周四")]];
    if ([arrRepeat[5] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周五")]];
    if ([arrRepeat[6] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周六")]];
    if (!strRepeat.length)
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"不重复")]];
    else if(![arrRepeat containsObject:@"0"])
        strRepeat = [NSMutableString stringWithFormat:kString(@"每天")];
    repeatSttring = [NSString stringWithFormat:@"%@", strRepeat];
    
    switch (typeSelect) {
        case 0:
        case 1:
            typeString = self.arrPicker[0];
            break;
        case 2:
            typeString = self.arrPicker[1];
            break;
        case 4:
            typeString = self.arrPicker[2];
            break;
    }
    self.arrValue = @[ dateString, repeatSttring, typeString ];
}

-(void)initView
{
    self.tabView.rowHeight = Bigger(RealHeight(120), 70);
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcEditClock" bundle:nil] forCellReuseIdentifier:@"tvcEditClock"];
    
    DDWeak(self)
    NextWaitInMain(
           DDStrong(self)
           [self initViewCover:300 toolBarColor:nil];
           [self initDatePickerView];
           [self initPickerView];);
}

- (void)initDatePickerView
{
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256 + NavBarHeight, ScreenWidth, 256 - NavBarHeight)];
    [self.datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:([DFD getLanguage] == 1 ? @"zh_Hans_CN":@"en_US")]];
    _datePicker.backgroundColor = DWhite;
    _datePicker.tintColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
    [self.datePicker setDatePickerMode:[DFD isSysTime24] ? UIDatePickerModeCountDownTimer : UIDatePickerModeTime];
    _datePicker.date = dateSelected;
    [self.ViewCover addSubview:_datePicker];
}

- (void)initPickerView
{
    _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256 + NavBarHeight, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickerView.backgroundColor = DWhite;
    _pickerView.tintColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
    [self.ViewCover addSubview:_pickerView];
}


-(void)rightButtonClick
{
    if (!self.Bluetooth.isLink) {
        LMBShow(NOConnect);
        return;
    }
    
    if (!self.isChange && !self.isAdd) {
        return;
    }
    
    self.clock.hour   = @([dateSelected getFromDate:4]);
    self.clock.minute = @([dateSelected getFromDate:5]);
    
    self.clock.repeat = [arrRepeat componentsJoinedByString:@"-"];
    self.clock.type = @(typeSelect == 0 ? 1 : typeSelect);
    self.clock.isOn = @YES;
    [self.clock perfect];
    
    DBSave;
    [self.Bluetooth setClock:self.userInfo.pUUIDString];
    
    LMBShow(@"保存成功");
    
    DDWeak(self);
    NextWaitInMainAfter(
        DDStrong(self)
        [self back];, 1);
}



//#pragma mark PickerView取消按钮事件
//- (void)pickerViewCancelButtonClick
//{
//    [self pickerViewDisappear];
//}
//
//#pragma mark PickerView确定按钮事件
//- (void)pickerViewConfirmButton
//{
//    self.isChange = YES;
//    if (isEditTime)
//        dateSelected = self.datePicker.date;
//    else
//        typeSelect = typeFromPick;
//    
//    
//    [self refreshData];
//    [self.tabView reloadData];
//    [self pickerViewDisappear];
//}

//pickView弹出动画
//-(void)pickerViewPopAnimationsRelod:(BOOL)isPicker
//{
//    [UIView transitionWithView:self.bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        [self.bgView setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
//        [effectView setAlpha:0.8];
//    } completion:^(BOOL finished) {}];
//}
//
//- (void)pickerViewDisappear
//{
//    [UIView transitionWithView:self.bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        [self.bgView setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
//        [effectView setAlpha:0];
//    } completion:^(BOOL finished) {
//        [self.datePicker removeFromSuperview];
//        [self.picker removeFromSuperview];
//    }];
//    
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self pickerViewDisappear];
//}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrTitle.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcEditClock *cell = [tvcEditClock cellWithTableView:tableView];
    cell.lblTitle.text = self.arrTitle[indexPath.row];
    cell.lblValue.text = self.arrValue[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row)
    {
        case 0:
            isEditTime = YES;
            _pickerView.hidden = YES;
            _datePicker.hidden = NO;
            [self showViewCover];
            break;
        case 1:
            self.isChange = YES;
            [self performSegueWithIdentifier:@"editClock_to_editRepeat" sender:nil];
            break;
        case 2:
            isEditTime = NO;
            _pickerView.hidden = NO;
            _datePicker.hidden = YES;
            _pickerView.delegate   = self;
            _pickerView.dataSource = self;
            
            int getIndex = 0;
            getIndex = typeSelect - 1;
            if (getIndex >2)
                getIndex--;
            typeSelect = typeSelect < 0 ? 0 : typeSelect;
            [_pickerView selectRow:getIndex inComponent:0 animated:NO];
            [self showViewCover];
            break;
    }
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrPicker.count;
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return  self.arrPicker[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    typeFromPick = (int)(row == 2 ? 4 : row + 1);
}



#pragma mark vcEditRepeatDelegate
-(void)changeRepeat:(NSMutableArray *)arr
{
    self.isChange = YES;
    arrRepeat = [arr mutableCopy];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editClock_to_editRepeat"])
    {
        vcEditRepeat *vc = (vcEditRepeat *)segue.destinationViewController;
        vc.delegate = self;
        vc.clock = self.clock;
    }
}


-(void)toolOKBtnClickAnimation
{
    self.isChange = YES;
    if (isEditTime)
        dateSelected = self.datePicker.date;
    else
        typeSelect = typeFromPick;
    
    [self refreshData];
    [self.tabView reloadData];
}

-(void)toolCancelBtnClickCompleted
{
    _pickerView.delegate = nil;
    _pickerView.delegate = nil;
}

@end
