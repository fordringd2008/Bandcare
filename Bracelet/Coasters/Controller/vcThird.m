//
//  vcThird.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/4.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcThird.h"
#import "UUChart.h"
#import "SRMonthPicker.h"

@interface vcThird () <UUChartDataSource, SRMonthPickerDelegate>
{
    CGFloat  viFirstHeight;
    
    NSInteger k_dateSub1;           // 日期value  选中的日期值
    
    int beginInt, endInt;           // 起止时间value
    
    NSInteger yMax;                 //  计算得出 y轴的合理值
    
    int k_date_min;           //  有数据的最小日期
    int k_date_max;           //  有数据的最大日期
    NSDate *  date_min;
    NSDate *  date_max;
    
    NSString *k_date_min_str;       //  最小的时间   20150204；
    NSString *k_date_max_str;
    
    NSInteger indexInArrData;       //  选中的天， 在朋友的数据中 的索引
    
    UUChart *                     _uuchart;
    
    SRMonthPicker                 *   _monthPicker;            // 只显示年月的日期选择器
    UIVisualEffectView *effectView;
}

@property (weak, nonatomic) IBOutlet UIView *                   viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewMainHeight;
@property (weak, nonatomic) IBOutlet UIButton *                 btnMonth;
@property (weak, nonatomic) IBOutlet UIButton *                 btnYear;
@property (weak, nonatomic) IBOutlet UILabel *                  lblTime;
@property (weak, nonatomic) IBOutlet UIView *                   viewFirst;
@property (weak, nonatomic) IBOutlet UIButton *                 btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *                 btnRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       lblTimeTop;
@property (weak, nonatomic) IBOutlet UIView *                   line2;
@property (weak, nonatomic) IBOutlet UIView *                   line3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewFirstHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewFirstTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       btnMonthHeight;
@property (weak, nonatomic) IBOutlet UIImageView *              imvCalendar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       imvCalendarRight;
@property (weak, nonatomic) IBOutlet UIButton *                 btnTime;

@property (nonatomic, strong) UIView                        *   bgView;


@property (nonatomic, strong) NSMutableArray *                  arrX;          // x轴 集合  （数组中嵌套数组）
@property (nonatomic, strong) NSMutableArray *                  arrDay;        // 这个只有好友详情跳转过来使用
@property (nonatomic, strong) NSMutableArray *                  arrMonth;      //
@property (nonatomic, strong) NSMutableArray *                  arrYear;       //
@property (weak, nonatomic) IBOutlet UIImageView *              imvLeft;
@property (weak, nonatomic) IBOutlet UIImageView *              imvRight;
@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl2Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl5Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl7Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl10Top;




@end

@implementation vcThird

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self initData];
//        [self initView];
//    });
    
    [self initData];
    [self initView];
}


-(void)initData
{
    _indexSub = 2;
    _yearSub2  = _yearSub3 = DDYear;
    _monthSub2 = DDMonth;
    k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub2), @(_monthSub2), @(1)] mutableCopy]];
    
    if(_model)
    {
        int todayValue = [DFD HmF2KNSDateToInt:DNow];
        k_date_max = todayValue;
        k_date_min = [self getNextDayByThisDay:k_date_max isPre:YES move:6];
        k_date_max_str = [DFD toStringFromDateValue:k_date_max];
        k_date_min_str = [DFD toStringFromDateValue:k_date_min];
    }
    else
    {
        NSArray *arrAll = [DataRecord findAllSortedBy:@"date" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
        k_date_max = [DFD HmF2KNSDateToInt:DNow];
        k_date_min = arrAll.count > 0 ? [((DataRecord *)arrAll[arrAll.count - 1]).dateValue intValue] : [DFD HmF2KNSDateToInt:DNow];
        
        k_date_max_str = [DFD toStringFromDateValue:k_date_max];
        k_date_min_str = [DFD toStringFromDateValue:k_date_min];
    }
    
    
    
    date_min = [DFD HmF2KNSIntToDate:k_date_min];
    date_max = [DFD HmF2KNSIntToDate:k_date_max];
    
    _arrDay   = [NSMutableArray new];
    _arrMonth = [NSMutableArray new];
    _arrYear  = [NSMutableArray new];
}

-(void)loadData
{
    _lbl4.text = _lbl5.text = _lbl6.text = @"---";
    _percent = 0;
    if (!_model)
    {
        switch (_indexSub)
        {
            case 2:
            {
                _lbl4.text = _lbl5.text = _lbl6.text = @"---";
                NSArray *arrDays = [DataRecord findAllSortedBy:@"dateValue" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and  year == %@ and month == %@ and situps_count != %@", self.userInfo.access, @(_yearSub2), @(_monthSub2), @0] inContext:DBefaultContext];
                [self initMonth];
                if (arrDays.count > 0)
                {
                    int sumSitUpsCount = 0;
                    int sumHeatCount = 0;
                    int sumReachTargetDays = 0;              // 达到目标的天数总和
                    for (int i = 0; i < arrDays.count; i++)
                    {
                        DataRecord *dr = arrDays[i];
                        if ([dr.step_count integerValue])
                        {
                            sumSitUpsCount += [dr.situps_count intValue];
                            sumHeatCount += [dr.heat_situps intValue];
                            sumReachTargetDays += ([dr.situps_count intValue] >= [self.userInfo.user_situps_target intValue] ? 1 : 0);
                        }
                        _arrMonth[[dr.day intValue] - 1] = [dr.situps_count description];
                    }
                    
                    _lbl4.text = [NSString stringWithFormat:@"%.0f", sumSitUpsCount / (double)arrDays.count];
                    _lbl5.text = [NSString stringWithFormat:@"%.0f", sumHeatCount / (double)arrDays.count];
#warning 这里不确定 需要看仰卧起坐的消耗是否是小数单位
                    _lbl6.text = [NSString stringWithFormat:@"%.1f%@", sumHeatCount / (double)arrDays.count / 10.0, kString(@"千卡")];
                    _lbl10.text = [@(sumSitUpsCount) description];
                }
                else
                {
                    NSLog(@"没有这个月的数据  ，，，， 擦擦擦");
                }
            }
                break;
            case 3:
            {
                NSArray *arrMonths = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and situps_count != %@", self.userInfo.access, @(_yearSub3), @0] inContext:DBefaultContext];
                _arrYear = [@[ @"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0" ] mutableCopy];
                if (arrMonths.count > 0)
                {
                    int sumSitUpsCount = 0;
                    int sumHeatCount = 0;
                    int sumReachTargetDays = 0;              // 达到目标的天数总和
                    for (int i = 0; i < arrMonths.count; i++)
                    {
                        DataRecord *dr = arrMonths[i];
                        if ([dr.step_count integerValue])
                        {
                            sumSitUpsCount += [dr.situps_count intValue];
                            sumHeatCount += [dr.heat_situps intValue];
                            sumReachTargetDays += ([dr.situps_count intValue] >= [self.userInfo.user_situps_target intValue] ? 1 : 0);
                        }
                        _arrMonth[[dr.day intValue] - 1] = [dr.situps_count description];
                    }
                    _lbl4.text = [NSString stringWithFormat:@"%.0f", sumSitUpsCount / (double)arrMonths.count];
                    _lbl5.text = [NSString stringWithFormat:@"%.0f", sumHeatCount / (double)arrMonths.count];
#warning 这里不确定 需要看仰卧起坐的消耗是否是小数单位
                    _lbl6.text = [NSString stringWithFormat:@"%.1f%@", sumHeatCount / (double)arrMonths.count / 10.0, kString(@"千卡")];
                    _lbl10.text = [@(sumSitUpsCount) description];
                }
                else
                {
                    NSLog(@"没有这一年的数据  ，，，， 擦擦擦");
                }
            }
                break;
        }
    }
    else
    {
        [self initMonth];
#warning TEST
//        if (_arrDataForFriend)
//        {
//            [self getIndexFromFirendData];
//            if (indexInArrData >= 0)
//            {
//                NSDictionary *dic_Sub = _arrDataForFriend[indexInArrData];
//                NSArray *arrHour = [dic_Sub[@"water_array_Hours"] componentsSeparatedByString:@","];
//                
//                _arrDay = [arrHour mutableCopy];
//                _lbl4.text = [DFD getMaxWaterOnTime:dic_Sub[@"water_array"] time_array:dic_Sub[@"time_array"]];
//                _lbl5.text = [NSString stringWithFormat:@"%@ml", dic_Sub[@"waterCount"]];
//                _percent = [dic_Sub[@"_percent"] integerValue];
//                _lbl6.text = [NSString stringWithFormat:@"%ld%%", (long)_percent];
//            }
//        }
    }
    
    [self refreshYMax];
    [self updatlblTime];
    [self checkData];
}

-(void)updatlblTime
{
    NSString *strResult;
    switch (_indexSub)
    {
        case 2:
            strResult = [NSString stringWithFormat:@"%ld-%02ld", (long)_yearSub2, (long)_monthSub2];
            break;
        case 3:
            strResult = [NSString stringWithFormat:@"%ld", (long)_yearSub3];
            break;
    }
    _lblTime.text = strResult;
}

// 检查预备数据有没有， 没有的话隐藏左边 或者右边的按钮
-(void)checkData
{
    switch (_indexSub)
    {
        case 2:
        {
            NSInteger min = [[k_date_min_str substringToIndex:6] integerValue];
            NSInteger max = [[k_date_max_str substringToIndex:6] integerValue];
            
            NSInteger monthLeft = _monthSub2 == 1 ? 12 : _monthSub2 - 1;
            NSInteger yearLeft = _monthSub2 == 1 ? _yearSub2 - 1 : _yearSub2;
            NSString *strMonthLeft = monthLeft < 10 ? [NSString stringWithFormat:@"0%ld", (long)monthLeft]: [NSString stringWithFormat:@"%ld", (long)monthLeft];
            NSInteger intLeft = [[NSString stringWithFormat:@"%ld%@", (long)yearLeft, strMonthLeft] integerValue];
            if (intLeft < min)
            {
                [_btnLeft setHidden:YES];
                [_imvLeft setHidden:YES];
            }
            else
            {
                [_btnLeft setHidden:NO];
                [_imvLeft setHidden:NO];
            }
            
            NSInteger monthRight = _monthSub2 == 12 ? 1 : _monthSub2 + 1;
            NSInteger yearRight = _monthSub2 == 12 ? _yearSub2 + 1 : _yearSub2;
            NSString *strMonth = monthRight < 10 ? [NSString stringWithFormat:@"0%ld", (long)monthRight]: [NSString stringWithFormat:@"%ld", (long)monthRight];
            NSInteger intRight = [[NSString stringWithFormat:@"%ld%@", (long)yearRight, strMonth] integerValue];
            if (intRight > max)
            {
                [_btnRight setHidden:YES];
                [_imvRight setHidden:YES];
            }
            else
            {
                [_btnRight setHidden:NO];
                [_imvRight setHidden:NO];
            }
        }
            break;
        case 3:
        {
            NSInteger min = [[k_date_min_str substringToIndex:4] integerValue];
            NSInteger max = [[k_date_max_str substringToIndex:4] integerValue];
            
            NSInteger intLeft = _yearSub3 - 1;
            if (intLeft < min)
            {
                [_btnLeft setHidden:YES];
                [_imvLeft setHidden:YES];
            }
            else
            {
                [_btnLeft setHidden:NO];
                [_imvLeft setHidden:NO];
            }
            
            
            NSInteger intRight = _yearSub3 + 1;
            if (intRight > max)
            {
                [_btnRight setHidden:YES];
                [_imvRight setHidden:YES];
            }
            else
            {
                [_btnRight setHidden:NO];
                [_imvRight setHidden:NO];
            }
        }
            break;
            
        default:
            break;
    }
}

//  左右点击
-(void)refreshTime:(BOOL)isBefore
{
    if (isBefore)
    {
        switch (_indexSub)
        {
            case 2:
            {
                _monthSub2 = _monthSub2 == 1 ? 12 : _monthSub2 - 1;
                _yearSub2 = _monthSub2 == 12 ? _yearSub2 - 1 : _yearSub2;
            }
                break;
            case 3:
            {
                _yearSub3--;
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (_indexSub)
        {
            case 2:
            {
                _monthSub2 = _monthSub2 == 12 ? 1 : _monthSub2 + 1;
                _yearSub2 = _monthSub2 == 1 ? _yearSub2 + 1 : _yearSub2;
            }
                break;
            case 3:
            {
                _yearSub3++;
            }
                break;
        }
    }
    
    [self loadData];
    [self changeUUChart];
}

-(void)changeUUChart
{
    if (_uuchart) [_uuchart removeFromSuperview];
    CGRect rect = CGRectMake(5, 0, ScreenWidth - 10, viFirstHeight); // 12  TODO   未解决
    _uuchart = [[UUChart alloc] initwithUUChartDataFrame:rect withSource:self withStyle:UUChartBarStyle];
    _uuchart.backgroundColor = DClear;
    _uuchart.Interval = _indexSub == 3 ? 1 : 3;
    [_uuchart showInView:_viewFirst];
}


-(void)initView
{
    if (IPhone4)        viFirstHeight = RealHeight(480);
    else if (IPhone5)   viFirstHeight = RealHeight(520);
    else                viFirstHeight = RealHeight(595);
    
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    _viewMain.backgroundColor = _viewHead.backgroundColor = DidSitupColor;
    _viewHeadHeight.constant = NavBarHeight+3;  // 防止点击
    _viewFirstHeight.constant = viFirstHeight;
    _btnMonthHeight.constant =  Bigger(RealHeight(50), 30);
    _lblTimeTop.constant = Bigger(RealHeight(50), 30) + NavBarHeight + 1;
    [_imvCalendar setHidden:NO];
    
    [_btnMonth setTitle:kString(@"月") forState:UIControlStateNormal];
    [_btnYear setTitle:kString(@"年") forState:UIControlStateNormal];
    _lblTime.text = [DFD dateToString:DNow  stringType:@"YYYY-MM-dd"];
    
    _lbl2Top.constant = _lbl5Top.constant = _lbl10Top.constant = 10;
    if (IPhone4) {
        _lbl7Top.constant = 20;
    }
    
    
    if(_model)
    {
        [_line2 setHidden:YES];
        [_line3 setHidden:YES];
        [_btnMonth setHidden:YES];
        [_btnYear setHidden:YES];
        _lblTimeTop.constant = Bigger(RealHeight(50), 30) / 2 + NavBarHeight;
        _viewFirstTop.constant = Bigger(RealHeight(50), 30) / 2 + 1;
    }
    
    _lbl1.text = kString(@"日均个数");
    _lbl2.text = kString(@"日均消耗");
    _lbl3.text = kString(@"完成目标天数");
    _lbl7.text = kString(@"总计个数");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self selectTabIndex:2];
        [self initViewCover:300 toolBarColor:DidSitupColor];
        [self initDatePickerView];
    });
}

-(void)selectTabIndex:(NSInteger)ind
{
    [self resetTopButton];
    [_imvCalendar setHidden:YES];

    switch (ind) {
        case 2:
        {
            _indexSub = 2;
            _btnMonth.backgroundColor = DWhite3;
            _imvCalendarRight.constant = -10;
            if(!_model) [_imvCalendar setHidden:NO];
        }
            break;
        case 3:
        {
            _indexSub = 3;
            _btnYear.backgroundColor = DWhite3;
        }
            break;
    }
    
    [self loadData];
    [self changeUUChart];
}

-(void)resetTopButton
{
    _btnMonth.backgroundColor = _btnYear.backgroundColor = DClear;
}


// 刷新Y轴合理值
-(void)refreshYMax
{
    NSMutableArray *arrThis;
    switch (_indexSub)
    {
        case 1:
            arrThis = _arrDay;
            break;
        case 2:
            arrThis = _arrMonth;
            break;
        case 3:
            arrThis = _arrYear;
            break;
            
        default:
            break;
    }
    
    NSInteger biggest = arrThis.count ? [arrThis[0] integerValue] : 100;
    for (int i = 0; i < arrThis.count; i++)
    {
        NSInteger intThis = [arrThis[i] integerValue];
        if (biggest < intThis) {
            biggest = intThis;
        }
    }
    
    yMax = biggest;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)btnClick:(UIButton *)sender
{
    if (sender.tag == _indexSub) return;
    static BOOL isSoQuick = NO;
    if (isSoQuick) return;
    isSoQuick = YES;
    NextWaitInMainAfter(isSoQuick = NO;, 0.5);
    
    switch (sender.tag) {
        case 1:
        case 2:
        case 3:
            [self selectTabIndex:sender.tag];
            break;
        case 4:
            [self refreshTime:YES];
            break;
        case 5:
            [self refreshTime:NO];
            break;
        case 6: // 单击日历
        {
            if (_model || _indexSub == 3) return;
            if (_indexSub == 1)
            {
                [_monthPicker setHidden:YES];
            }
            else
            {
                [_monthPicker setHidden:NO];
            }
            
            self.btnTime.enabled = self.btnMonth.enabled = self.btnYear.enabled = NO;
            DDWeak(self)
            NextWaitInMainAfter(
                    DDStrong(self)
                    if(self)self.btnTime.enabled =  self.btnMonth.enabled = self.btnYear.enabled = YES;, 1);
            [self showViewCover];
        }
            break;
    }
}


#pragma mark UUChartDataSource
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    switch (_indexSub)
    {
        case 1:
        {
            if([DFD isSysTime24])
                return [@[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24"] mutableCopy];
            else
                return [@[@"AM", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"PM", @"1", @"2", @"3", @"4", @"17", @"5", @"6", @"7", @"8", @"9", @"10", @"11"] mutableCopy];
        }
            break;
        case 2:
            return [DFD getXarrList:_yearSub2 month:_monthSub2];
            break;
        case 3:
            return @[ @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12" ];
            break;
    }
    return nil;
}

//数值多重数组 (数组中嵌套数组)
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    switch (_indexSub)
    {
        case 2:
            return  @[_arrMonth];
            break;
        case 3:
            return  @[_arrYear];
            break;
    }
    return nil;
}


//@optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[ DWhiteA(0.7)];
}

//
//显示数值范围  (Y轴区间)
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    //NSLog(@"yMax : %d", yMax);          // 这里是最大值，要算出合理值
    double radio;
    switch (_indexSub) {
        case 1:
            radio = 50.0;
            break;
        case 2:
            radio = 100.0;
            break;
        case 3:
            radio = 150.0;
            break;
            
        default:
            break;
    }
    yMax = yMax == 0 ? 1 : yMax;                  // 防止没有数据时  Y轴坐标 为 12345
    yMax = ceil((double)yMax / radio) * radio;
    return CGRangeMake(yMax, 0);
}


-(void)initMonth
{
    NSInteger days = [DFD getDaysByYearAndMonth:_yearSub2 month:_monthSub2];
    NSMutableArray *arr = [NSMutableArray new];
    for (int i = 0; i < days; i++)
        [arr addObject:[NSString stringWithFormat:@"%d", 0]];
    _arrMonth = arr;
}

-(void)getIndexFromFirendData
{
//    indexInArrData = -1;
//    for (int i = 0; i < _arrDataForFriend.count; i++)
//    {
//        NSDictionary *dic_Sub = _arrDataForFriend[i];
//        if ([dic_Sub[@"day"] integerValue] == _daySub1 ) {
//            indexInArrData = i;
//            break;
//        }
//    }
}

- (void)initDatePickerView
{
    _monthPicker = [[SRMonthPicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256 + NavBarHeight, ScreenWidth, 256)];
    _monthPicker.monthPickerDelegate = self;
    _monthPicker.backgroundColor = DWhite;
    
    _monthPicker.maximumYear = [date_max getFromDate:1];
    _monthPicker.minimumYear = [date_min getFromDate:1];
    
    _monthPicker.date = DNow;
    _monthPicker.yearFirst = YES;
    [self.ViewCover addSubview:_monthPicker];
}


-(void)showViewCover
{
    if (self.delegate)
        [self.delegate pageControlHidden:YES];
    [super showViewCover];
}

-(void)toolCancelBtnClickCompleted
{
    self.btnTime.enabled = YES;
    _monthPicker.monthPickerDelegate = nil;
    if (self.delegate)
        [self.delegate pageControlHidden:NO];
}

-(void)pickerViewDisappear
{
    self.btnTime.enabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        if (self.ViewCover) {
            [self.ViewCover setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
            self.ViewEffectBody.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (self.delegate)
            [self.delegate pageControlHidden:NO];
    }];
}

-(void)toolOKBtnClickAnimation
{
    _yearSub2  = [_monthPicker.date getFromDate:1];
    _monthSub2 = [_monthPicker.date getFromDate:2];
    k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub2), @(_monthSub2), @1] mutableCopy]];
    [self selectTabIndex:_indexSub];
}


- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker
{
    NSInteger min = [[k_date_min_str substringToIndex:6] integerValue];
    NSInteger max = [[k_date_max_str substringToIndex:6] integerValue];
    NSInteger select = [[monthPicker.date toString:@"YYYYMM"] integerValue];
    if (select < min)
    {
        NSDateComponents* dateParts = [[NSDateComponents alloc] init];
        dateParts.month = [[k_date_min_str substringWithRange:NSMakeRange(4, 2)] integerValue];
        dateParts.year = [[k_date_min_str substringWithRange:NSMakeRange(0, 4)] integerValue];;
        _monthPicker.date = [[NSCalendar currentCalendar] dateFromComponents:dateParts];
    }
    else if(select > max)
    {
        NSDateComponents* dateParts = [[NSDateComponents alloc] init];
        dateParts.month = [[k_date_max_str substringWithRange:NSMakeRange(4, 2)] integerValue];
        dateParts.year = [[k_date_max_str substringWithRange:NSMakeRange(0, 4)] integerValue];;
        _monthPicker.date = [[NSCalendar currentCalendar] dateFromComponents:dateParts];
    }
}


@end
