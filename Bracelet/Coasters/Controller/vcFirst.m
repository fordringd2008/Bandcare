//
//  vcFirst.m
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcFirst.h"
#import "UUChart.h"
#import "SRMonthPicker.h"

@interface vcFirst () <UUChartDataSource, SRMonthPickerDelegate>
{
    CGFloat  viFirstHeight;
    
    int k_dateSub1;           // 日期value  选中的日期值
    
    int beginInt, endInt;           // 起止时间value

    int yMax;                 //  计算得出 y轴的合理值
    
    int k_date_min;                 //  有数据的最小日期
    int k_date_max;                 //  有数据的最大日期
    NSDate *  date_min;
    NSDate *  date_max;
    
    NSString *k_date_min_str;       //  最小的时间   20150204；
    NSString *k_date_max_str;

    int indexInArrData;       //  选中的天， 在朋友的数据中 的索引
    
    UUChart *                     _uuchart;
    
    UIDatePicker                  *   _datePicker;
    SRMonthPicker                 *   _monthPicker;            // 只显示年月的日期选择器
}

@property (weak, nonatomic) IBOutlet UIView *                   viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewMainHeight;
@property (weak, nonatomic) IBOutlet UIButton *                 btnDay;
@property (weak, nonatomic) IBOutlet UIButton *                 btnMonth;
@property (weak, nonatomic) IBOutlet UIButton *                 btnYear;
@property (weak, nonatomic) IBOutlet UILabel *                  lblTime;
@property (weak, nonatomic) IBOutlet UIView *                   viewFirst;
@property (weak, nonatomic) IBOutlet UIButton *                 btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *                 btnRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       lblTimeTop;
@property (weak, nonatomic) IBOutlet UIView *                   line2;
@property (weak, nonatomic) IBOutlet UIView *                   line1;
@property (weak, nonatomic) IBOutlet UIView *                   line3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewFirstHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewFirstTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       btnMonthHeight;
@property (weak, nonatomic) IBOutlet UIImageView *              imvCalendar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       imvCalendarRight;
@property (weak, nonatomic) IBOutlet UIButton *                 btnTime;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl2Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl8Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl5Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl11Top;

@property (weak, nonatomic) IBOutlet UIView             *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;


@property (nonatomic, strong) NSMutableArray *                  arrX;          // x轴 集合  （数组中嵌套数组）
@property (nonatomic, strong) NSMutableArray *                  arrDay;        //
@property (nonatomic, strong) NSMutableArray *                  arrMonth;      //
@property (nonatomic, strong) NSMutableArray *                  arrYear;       //
@property (weak, nonatomic) IBOutlet UIImageView *              imvLeft;
@property (weak, nonatomic) IBOutlet UIImageView *              imvRight;


@end

@implementation vcFirst

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initView];
}


-(void)initData
{
    _indexSub = 1;
    _yearSub1  = _yearSub2 = _yearSub3 = DDYear;
    _monthSub1 = _monthSub2 = DDMonth;
    _daySub1   = DDDay;
    k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub1), @(_monthSub1), @(_daySub1)] mutableCopy]];
    
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
    
    date_min = [DFD getDateFromArr:[DFD HmF2KIntToDate:k_date_min]];
    date_max = [DFD getDateFromArr:[DFD HmF2KIntToDate:k_date_max]];
    
    _arrDay = [NSMutableArray new];
    _arrMonth = [NSMutableArray new];
    _arrYear = [NSMutableArray new];
    
}

-(void)loadData
{
    _lbl4.text = _lbl5.text = _lbl6.text = _lbl10.text = _lbl11.text = _lbl12.text =@"---";
    _percent = 0;
    if (!_model)
    {
        switch (_indexSub)
        {
            case 1:
            {
                [_arrDay removeAllObjects];
                NSMutableArray *arrDate = [@[ @(_yearSub1), @(_monthSub1), @(_daySub1) ] mutableCopy];
                NSDate *dateSelected = [DFD getDateFromArr:arrDate];
                
                DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelected] inContext:DBefaultContext];
                if (dr && [dr.step_count intValue])
                {
                    NSArray *arrHour = [dr.step_array componentsSeparatedByString:@","];
                    _arrDay = arrHour ? [arrHour mutableCopy] : _arrDay;
                    
                    _lbl4.text = [NSString stringWithFormat:@"%@",dr.step_count];
                    
                    _lbl5.text = [DFD toStringFromDist:[dr.distance_count intValue] isMetric:[self.userInfo.unit boolValue]];
                    if (![DFD shareDFD].isForA5) {
                        _lbl6.text = [NSString stringWithFormat:@"%@%@", dr.heat_count, kString(@"千卡")];
                    }else{
                        
                        _lbl6.text = [NSString stringWithFormat:@"%.1f%@", [dr.heat_count intValue] / 10.0 , kString(@"千卡")];
                    }
                    
                    CGFloat percent = [dr.step_count intValue] / [self.userInfo.user_sport_target doubleValue] * 100.0;
                    percent = percent > 100 ? 100:percent;
                    _lbl10.text = [NSString stringWithFormat:@"%.0f%%",percent];
                    _lbl11.text = [NSString stringWithFormat:@"%d%@", [self getContinuityDays], kString(@"天")];
                    _lbl12.text = [NSString stringWithFormat:@"%d", ([self.userInfo.user_sport_target intValue] < [dr.step_count intValue]) ? 0 : ([self.userInfo.user_sport_target intValue] - [dr.step_count intValue])];
                }
                else
                {
                    NSLog(@"没有今天的数据  ，，，， 擦擦擦");
                }
                
//#warning TEST
//                [_arrDay removeAllObjects];
//                for (int i = 0 ; i < 24; i++) {
//                    [_arrDay addObject:[NSString stringWithFormat:@"%d", i * 20 + 30]];
//                }
//                NSLog(@"--- %@",_arrDay);
            }
                break;
            case 2:
            {
                _lbl4.text = _lbl5.text = _lbl6.text = @"---";
                NSArray *arrDays = [DataRecord findAllSortedBy:@"dateValue" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and  year == %@ and month == %@ and step_count != %@", self.userInfo.access, @(_yearSub2), @(_monthSub2), @0] inContext:DBefaultContext];
                [self initMonth];
                if (arrDays.count > 0)
                {
                    int sumStepCount = 0;
                    int sumDistCount = 0;
                    int sumHeatCount = 0;
                    
                    int sumReachTargetDays = 0;              // 达到目标的天数总和
                    for (int i = 0; i < arrDays.count; i++)
                    {
                        DataRecord *dr = arrDays[i];
                        if ([dr.step_count integerValue])
                        {
                            sumStepCount += [dr.step_count intValue];
                            sumDistCount += [dr.distance_count intValue];
                            sumHeatCount += [dr.heat_count intValue];
                            sumReachTargetDays += ([dr.step_count intValue] >= [self.userInfo.user_sport_target intValue] ? 1 : 0);
                        }
                        //NSLog(@"day:%@, step_count:%@", dr.day, dr.step_count);
                        _arrMonth[[dr.day intValue] - 1] = [dr.step_count description];
                    }
                    
                    //NSLog(@"_arrMonth:%@", _arrMonth);
                    
                    _lbl4.text = [NSString stringWithFormat:@"%.0f", sumStepCount / (double)arrDays.count];
                    
                    _lbl5.text = [DFD toStringFromDist:(sumDistCount / (double)arrDays.count) isMetric:[self.userInfo.unit boolValue]];
                    
                    if (![DFD shareDFD].isForA5) {
                        _lbl6.text = [NSString stringWithFormat:@"%.0f%@", sumHeatCount / (double)arrDays.count, kString(@"千卡")];
                    }else{
                        _lbl6.text = [NSString stringWithFormat:@"%.1f%@", sumHeatCount / (double)arrDays.count / 10.0, kString(@"千卡")];
                    }
                    
                    
                    
                    _lbl10.text = [NSString stringWithFormat:@"%d", sumStepCount];
                    _lbl11.text = [NSString stringWithFormat:@"%d%@", sumReachTargetDays, kString(@"天")];
                }
                else
                {
                    NSLog(@"没有这个月的数据  ，，，， 擦擦擦");
                }
                
                
//#warning  TEST
//                [_arrMonth removeAllObjects];
//                for (int i = 0 ; i < 31; i++) {
////                    if (i < 10) {
////                        _arrMonth[i] = [NSString stringWithFormat:@"%.0f", i * (1000/30.0)];
////                    }else
//                        _arrMonth[i] = [NSString stringWithFormat:@"%d", i * (6000/30)];
//                    
//                }
//                NSLog(@"--- %@",_arrMonth);
            }
                break;
            case 3:
            {
                NSArray *arrMonths = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@  and step_count != %@", self.userInfo.access, @(_yearSub3), @0] inContext:DBefaultContext];
                _arrYear = [@[ @"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0" ] mutableCopy];
                if (arrMonths.count > 0)
                {
                    int sumStepCount = 0;
                    int sumDistCount = 0;
                    int sumHeatCount = 0;
                    int sumWaterCount[12] = {0,0,0,0,0,0,0,0,0,0,0,0};                    // 每个月的喝水量
                    int sumReachTargetDays = 0;               // 达到的天数
                    
                    for (int i = 0; i < arrMonths.count; i++)
                    {
                        DataRecord *dr = arrMonths[i];
                        sumStepCount += [dr.step_count intValue];
                        sumDistCount += [dr.distance_count intValue];
                        sumHeatCount += [dr.heat_count intValue];
                        sumWaterCount[[dr.month intValue] - 1] += [dr.step_count intValue];
                        sumReachTargetDays += ([dr.step_count intValue] >= [self.userInfo.user_sport_target intValue] ? 1 : 0);
                    }
                    
                    for (int i = 0; i < 12 ; i++)
                    {
                        _arrYear[i] = [NSString stringWithFormat:@"%d", (int)sumWaterCount[i]];
                    }
                    
                    
                    _lbl4.text = [NSString stringWithFormat:@"%.0f", sumStepCount / (double)arrMonths.count];
                    
                    _lbl5.text = [DFD toStringFromDist:(sumDistCount / (double)arrMonths.count) isMetric:[self.userInfo.unit boolValue]];
                    
                    if (![DFD shareDFD].isForA5) {
                        _lbl6.text = [NSString stringWithFormat:@"%.0f%@", sumHeatCount / (double)arrMonths.count, kString(@"千卡")];
                    }else{
                        _lbl6.text = [NSString stringWithFormat:@"%.1f%@", sumHeatCount / (double)arrMonths.count / 10.0, kString(@"千卡")];
                    }
                    
                    _lbl10.text = [NSString stringWithFormat:@"%d", sumStepCount];
                    _lbl11.text = [NSString stringWithFormat:@"%d%@", sumReachTargetDays, kString(@"天")];
                    
                }
                else
                {
                    NSLog(@"没有这一年的数据  ，，，， 擦擦擦");
                }
                
//                
//#warning TEST
//                [_arrYear removeAllObjects];
//                for (int i = 0 ; i < 12; i++) {
//                    [_arrYear addObject:[NSString stringWithFormat:@"%d", (i+1) * 2000]];
//                }
//                NSLog(@"--- %@",_arrYear);
            }
                break;
        }
    }
    else
    {
        _lbl12.text =@"";
        _arrDay = [@[ @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0" ] mutableCopy];
        
        if (self.arrDataForFriend)
        {
            [self getIndexFromFriendData];
            if (indexInArrData >= 0)
            {
                NSDictionary *dic_Sub = self.arrDataForFriend[indexInArrData];
                if ([dic_Sub[@"sport_num"] intValue])
                {
                    NSArray *arrHour = [dic_Sub[@"sport_array"] componentsSeparatedByString:@","];
                    
                    _arrDay = [arrHour mutableCopy];
                    
                    _lbl4.text = [NSString stringWithFormat:@"%@",dic_Sub[@"sport_num"]];
                    
                    _lbl5.text = [DFD toStringFromDist:[dic_Sub[@"distance"] intValue] isMetric:[self.userInfo.unit boolValue]];
                    _lbl6.text = [NSString stringWithFormat:@"%.0f%@", [self.model.user_weight doubleValue] * [dic_Sub[@"distance"] intValue] / 8000, kString(@"千卡")];
                    
                    CGFloat percent = [dic_Sub[@"sport_num"] intValue] / [self.model.user_sport_target doubleValue] * 100.0;
                    percent = percent > 100 ? 100:percent;
                    _lbl10.text = [NSString stringWithFormat:@"%.0f%%",percent];
                    //_lbl11.text = [NSString stringWithFormat:@"%d%@", [self getContinuityDaysForFriend], kString(@"天")];
                    _lbl11.text = [NSString stringWithFormat:@"%d", ([self.model.user_sport_target intValue] < [dic_Sub[@"sport_num"] intValue]) ? 0 : ([self.model.user_sport_target intValue] - [dic_Sub[@"sport_num"] intValue])];
                }
            }
        }
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
        case 1:
        {
            if ([self.userInfo.unit boolValue] == 1) {
                strResult = [NSString stringWithFormat:@"%d-%d-%d", (int)_yearSub1, (int)_monthSub1, (int)_daySub1];
            }else{
                strResult = [NSString stringWithFormat:@"%d/%d/%d", (int)_monthSub1, (int)_daySub1, (int)_yearSub1];
            }
        }
            break;
        case 2:
        {
            if ([self.userInfo.unit boolValue] == 1) {
                strResult = [NSString stringWithFormat:@"%d-%d", (int)_yearSub2, (int)_monthSub2];
            }else{
                strResult = [NSString stringWithFormat:@"%d/%d", (int)_monthSub2, (int)_yearSub2];
            }
        }
            break;
        case 3:
            strResult = [NSString stringWithFormat:@"%d", (int)_yearSub3];
            break;
    }
    _lblTime.text = strResult;
}

// 检查预备数据有没有， 没有的话隐藏左边 或者右边的按钮
-(void)checkData
{
    switch (_indexSub)
    {
        case 1:
        {
            int dayBefore = [self getNextDayByThisDay:k_dateSub1 isPre:YES];
            int dayAfter = [self getNextDayByThisDay:k_dateSub1 isPre:NO];
            if (dayBefore < k_date_min)
            {
                [_btnLeft setHidden:YES];
                [_imvLeft setHidden:YES];
            }
            else
            {
                [_btnLeft setHidden:NO];
                [_imvLeft setHidden:NO];
            }
            if (dayAfter > k_date_max)
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
            case 1:
            {
                k_dateSub1 = [self getNextDayByThisDay:k_dateSub1 isPre:YES];
                NSMutableArray *arr = [DFD HmF2KIntToDate:k_dateSub1];
                _yearSub1 = [arr[0] integerValue];
                _monthSub1 = [arr[1] integerValue];
                _daySub1 = [arr[2] integerValue];
            }
                break;
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
            case 1:
            {
                k_dateSub1 = [self getNextDayByThisDay:k_dateSub1 isPre:NO];
                NSMutableArray *arr = [DFD HmF2KIntToDate:k_dateSub1];
                _yearSub1 = [arr[0] integerValue];
                _monthSub1 = [arr[1] integerValue];
                _daySub1 = [arr[2] integerValue];
            }
                break;
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
                
            default:
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
    _uuchart.xLblIsAlighLeft = _indexSub == 1;
    [_uuchart showInView:_viewFirst];
}


-(void)initView
{
    if (IPhone4)        viFirstHeight = RealHeight(480);
    else if (IPhone5)   viFirstHeight = RealHeight(520);
    else                viFirstHeight = RealHeight(595);
    
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    _viewMain.backgroundColor = _viewHead.backgroundColor = DidConnectColor;
    _viewHeadHeight.constant = NavBarHeight+3;  // 防止点击
    
    _viewFirstHeight.constant = viFirstHeight;
    _btnMonthHeight.constant =  Bigger(RealHeight(50), 30);
    _lblTimeTop.constant = Bigger(RealHeight(50), 30) + NavBarHeight + 1;
    //Border(_lblScore, DRed);
    [_imvCalendar setHidden:NO];
    
    [_btnDay setTitle:kString(@"日") forState:UIControlStateNormal];
    [_btnMonth setTitle:kString(@"月") forState:UIControlStateNormal];
    [_btnYear setTitle:kString(@"年") forState:UIControlStateNormal];
    _lblTime.text = [DFD dateToString:DNow stringType:@"YYYY-MM-dd"];
    
    _lbl2Top.constant = _lbl5Top.constant = _lbl11Top.constant = 10;
    if (IPhone4) {
        _lbl8Top.constant = 20;
    }
    
    
    if(_model)
    {
        [_line1 setHidden:YES];
        [_line2 setHidden:YES];
        [_line3 setHidden:YES];
        [_btnDay setHidden:YES];
        [_btnMonth setHidden:YES];
        [_btnYear setHidden:YES];
        _lblTimeTop.constant = Bigger(RealHeight(50), 30) / 2 + NavBarHeight;
        _viewFirstTop.constant = Bigger(RealHeight(50), 30) / 2 + 1;
    }
    
    _btnDay.backgroundColor = DWhite3;
    [_btnLeft setHidden:YES];
    [_imvLeft setHidden:YES];
    [_btnRight setHidden:YES];
    [_imvRight setHidden:YES];
    
    // 延迟加载
    dispatch_async(dispatch_get_main_queue(), ^{
        [self selectTabIndex:1];
        [self initViewCover:300 toolBarColor:nil];
        [self initDatePickerView];
    });
}

-(void)selectTabIndex:(NSInteger)ind
{
    [self resetTopButton];
    [_imvCalendar setHidden:YES];
    _indexSub = ind;
    switch (ind) {
        case 1:
        {
            _btnDay.backgroundColor = DWhite3;
            _lbl1.text = kString(@"全天步数");
            _lbl2.text = kString(@"全天里程");
            _lbl3.text = kString(@"全天消耗");
            _lbl7.text = kString(@"完成度");
            
            _lineLast.hidden = _lbl9.hidden = _lbl12.hidden = NO;
            _imvCalendarRight.constant = 0;
            
            if (!_model) {
                [_imvCalendar setHidden:NO];
                _lbl8.text = kString(@"连续完成天数");
                _lbl9.text = kString(@"剩余步数");
                _lineLast.hidden = NO;
            }else{
                _lbl8.text = kString(@"剩余步数");
                _lbl9.text = _lbl12.text = @"";
                _lineLast.hidden = YES;
            }
        }
            break;
        case 2:
        {
            _btnMonth.backgroundColor = DWhite3;
            _lbl1.text = kString(@"日均步数");
            _lbl2.text = kString(@"日均里程");
            _lbl3.text = kString(@"日均消耗");
            _lbl7.text = kString(@"总计步数");
            _lbl8.text = kString(@"完成目标天数");
            _lineLast.hidden = _lbl9.hidden = _lbl12.hidden = YES;
            _imvCalendarRight.constant = -10;
            if(!_model) [_imvCalendar setHidden:NO];
        }
            break;
        case 3:
        {
            _btnYear.backgroundColor = DWhite3;
            _lbl1.text = kString(@"日均步数");
            _lbl2.text = kString(@"日均里程");
            _lbl3.text = kString(@"日均消耗");
            _lbl7.text = kString(@"总计步数");
            _lbl8.text = kString(@"完成目标天数");
            _lineLast.hidden = _lbl9.hidden = _lbl12.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    
    
    [self loadData];
    [self changeUUChart];
}

-(void)resetTopButton
{
    _btnDay.backgroundColor = _btnMonth.backgroundColor = _btnYear.backgroundColor = DClear;
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
    
    //NSInteger biggest = 100;
    int biggest = arrThis.count ? [arrThis[0] intValue] : 100;
    for (int i = 0; i < arrThis.count; i++)
    {
        int intThis = [arrThis[i] intValue];
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
            
            _monthPicker.hidden = _indexSub == 1 ? YES:NO;
            _datePicker.hidden  = _indexSub == 1 ? NO:YES;
            
            self.btnTime.enabled = self.btnDay.enabled = self.btnMonth.enabled = self.btnYear.enabled = NO;
            DDWeak(self)
            NextWaitInMainAfter(
                    DDStrong(self)
                    if(self) self.btnTime.enabled = self.btnDay.enabled = self.btnMonth.enabled = self.btnYear.enabled = YES;, 1);
            self.btnTime.enabled = NO;
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
                return @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"];
            else
                return @[@"AM", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"PM", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11"];
        }
            break;
        case 2:
            return [DFD getXarrList:_yearSub2 month:_monthSub2];
            break;
        case 3:
            return @[ @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12" ];
            break;
            
        default:
            break;
    }
    return nil;
}

//数值多重数组 (数组中嵌套数组)
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    switch (_indexSub)
    {
        case 1:
            return  @[_arrDay];
            break;
        case 2:
            //NSLog(@"%@", _arrMonth);
            return  @[_arrMonth];
            break;
        case 3:
            return  @[_arrYear];
            break;
            
        default:
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
            radio = 400.0;
            break;
        case 2:
            radio = 2000.0;
            break;
        case 3:
            radio = 8000.0;
            break;
            
        default:
            break;
    }
    yMax = yMax == 0 ? 1 : yMax;                  // 防止没有数据时  Y轴坐标 为 12345
    yMax = ceil((double)yMax / radio) * radio;
//    NSLog(@"------- yMax : %d", yMax);          // 这里是最大值，要算出合理值
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




-(void)getIndexFromFriendData
{
    indexInArrData = -1;
    for (int i = 0; i < self.arrDataForFriend.count; i++)
    {
        NSDictionary *dic_Sub = self.arrDataForFriend[i];
        if ([dic_Sub[@"day"] integerValue] == _daySub1 ) {
            indexInArrData = i;
            break;
        }
    }
}


//初始化DatePickerView
- (void)initDatePickerView
{
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256 + NavBarHeight, ScreenWidth, 256 - NavBarHeight)];
    _datePicker.locale = [[NSLocale alloc]initWithLocaleIdentifier:[DFD getLanguage] == 1 ? @"zh_CN" :@"en_US"];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    _datePicker.date = DNow;
    _datePicker.backgroundColor = DWhite;
    _datePicker.tintColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
    _datePicker.minimumDate = date_min;
    _datePicker.maximumDate = date_max;
    [self.ViewCover addSubview:_datePicker];
    
    _monthPicker = [[SRMonthPicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256 + NavBarHeight, ScreenWidth, 256-NavBarHeight)];///2
    _monthPicker.monthPickerDelegate = self;
    _monthPicker.backgroundColor = DWhite;
    _monthPicker.maximumYear = [date_max getFromDate:1];
    _monthPicker.minimumYear = [date_min getFromDate:1];
    
    _monthPicker.date = DNow;
    _monthPicker.yearFirst = YES;
    [self.ViewCover addSubview:_monthPicker];
}

-(void)toolOKBtnClickAnimation
{
    if(_indexSub == 1)
    {
        NSLog(@"选择的日期  %@", _datePicker.date);
        int yearTag  = [_datePicker.date getFromDate:1];
        int monthTag = [_datePicker.date getFromDate:2];
        int dayTag   = [_datePicker.date getFromDate:3];
        
        _yearSub1 = yearTag;
        _monthSub1 = monthTag;
        _daySub1 = dayTag;
        k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub1), @(_monthSub1), @(_daySub1)] mutableCopy]];
    }
    else
    {
        _yearSub2  = [_monthPicker.date getFromDate:1];
        _monthSub2 = [_monthPicker.date getFromDate:2];
        k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub2), @(_monthSub2), @(1)] mutableCopy]];
    }
    
    [self selectTabIndex:_indexSub];
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

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker
{
    NSInteger min = [[k_date_min_str substringToIndex:6] integerValue];
    NSInteger max = [[k_date_max_str substringToIndex:6] integerValue];
    NSInteger select = [[self formatDate:monthPicker.date] integerValue];
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

- (NSString*)formatDate:(NSDate *)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYYMM";// @"MMMM y";
    return [formatter stringFromDate:date];
}



-(int)getContinuityDaysForFriend{
    
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







@end
