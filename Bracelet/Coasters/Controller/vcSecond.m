//
//  vcSecond.m
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcSecond.h"
#import "UUChart.h"
#import "SRMonthPicker.h"
#import "PieChartView.h"

#define DDColorNumber1          RGB(91,41,164)
#define DDColorNumber2          RGB(54,136,248)
#define DDColorNumber3          RGB(250,102,20)


@interface vcSecond () <UUChartDataSource, SRMonthPickerDelegate, PieChartDelegate> //
{
    CGFloat                     viFirstHeight;        // 上部视图的高度
    CGFloat                     PIE_HEIGHT;           // 饼状图的宽度
    
    
    int                         k_dateSub1;           // 日期value  选中的日期值
    
    int                         beginInt, endInt;     // 起止时间value
    
    int                         yMax;                 //  计算得出 y轴的合理值
    
    int                         k_date_min;           //  有数据的最小日期
    int                         k_date_max;           //  有数据的最大日期
    NSDate *                    date_min;
    NSDate *                    date_max;
    
    NSString *                  k_date_min_str;       //  最小的时间   20150204；
    NSString *                  k_date_max_str;
    
    int                         indexInArrData;       //  选中的天， 在朋友的数据中 的索引
    int                         indexYesterdayInArrData;       //  选中的天的前一天， 在朋友的数据中 的索引
    
    
    UUChart *                   _uuchart;             // 柱状图
    PieChartView *              _piechart;            // 饼状图
    
    UIDatePicker*               _datePicker;
    SRMonthPicker *             _monthPicker;         // 只显示年月的日期选择器
    
    
    UIView *                    viewPrompt;           // 旁边注释的视图
    UIVisualEffectView *        effectView;
    
    int                         left;                 // 开始时间 22 点
    int                         right;                // 结束时间 22 点
    int                         number;               // 总个数
    
    int                         numberGood;             // 良好的天数
    int                         numberNormal;           // 一般的天数
    int                         numberBad;              // 较差的天数
    int                         numberUnknow;           // 未知的天数
    
    int                         perGood;                // 在这个圆中占的百分比   满分100分
    int                         perNormal;
    int                         perBad;
    int                         perUnknow;
    
    
    int                         numberInMonth;          // 在月查询中，当前月中的天数
    int                         numberInYear;           // 在年查询中，当前年中的天数
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
@property (weak, nonatomic) IBOutlet UIImageView *              imvLeft;
@property (weak, nonatomic) IBOutlet UIImageView *              imvRight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl2Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl8Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl5Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl11Top;

@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;


@property (nonatomic, strong) UIView                        *   bgView;
@property (nonatomic, strong) NSMutableArray *                  arrX;          // x轴 集合  （数组中嵌套数组）
@property (nonatomic, strong) NSMutableArray *                  arrDay;        //
@property (nonatomic, strong) NSMutableArray *                  arrMonth;      //
@property (nonatomic, strong) NSMutableArray *                  arrYear;       //

@property (strong, nonatomic) NSMutableArray * arrData;                        // 数据源

@property (nonatomic,strong) NSMutableArray *valueArray;                       //
@property (nonatomic,strong) NSArray *colorArray;
@property (nonatomic,strong) PieChartView *pieChartView;
@property (nonatomic,strong) UIView *pieContainer;              // 父容器
@property (nonatomic,strong) UILabel *selLabel;                 // 下面显示的介绍
@property (nonatomic,strong) UIImageView *selView;              // 图片

@end

@implementation vcSecond

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
    
    if (self.model) {
        left = [[self.model.user_sleep_start_time substringToIndex:2] intValue];
        right = [[self.model.user_sleep_end_time substringToIndex:2] intValue];
    }else{
        left = [[self.userInfo.user_sleep_start_time substringToIndex:2] intValue];
        right = [[self.userInfo.user_sleep_end_time substringToIndex:2] intValue];
    }
    
    number = left < right ? (right - left) : (24 - (left - right));
    for (int i = 0; i < number; i++) {
        [_arrDay addObject:@0];
    }
    
    self.colorArray = @[ DDColorNumber1, DDColorNumber2, DDColorNumber3, DWhite ];
}



-(void)loadData
{
    _lbl4.text = _lbl5.text = _lbl6.text = _lbl10.text = @"---";
    BOOL isTag = NO;
    if (!_model)
    {
        switch (_indexSub)
        {
            case 1:
            {
                [_arrDay enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    _arrDay[idx] = @0;
                }];
                
                
                NSArray *arrValue = [self getDeepNormalShallowHoursByYear:_yearSub1 month:_monthSub1 day:_daySub1 other:1];
                if (arrValue.count == 3) {
                    self.lbl4.text = [NSString stringWithFormat:@"%@%@", arrValue[0],kString(@"小时")];
                    self.lbl5.text = [NSString stringWithFormat:@"%@%@", arrValue[1],kString(@"小时")];
                    self.lbl6.text = [NSString stringWithFormat:@"%@%@", arrValue[2],kString(@"小时")];
                    self.lbl10.text = [self getSleepLevelStr:arrValue];
                }
            }
                break;
            case 2:
            {
                numberGood = numberNormal = numberBad = numberUnknow = 0;
                numberInMonth = (int)[DFD getDaysByYearAndMonth:_yearSub2 month:_monthSub2];
                
                // 如果选中的是这个月，排除掉明天以后的未知
                
                if (DDYear == _yearSub2 && DDMonth == _monthSub2) {
                    numberInMonth = DDDay;
                }
                NSLog(@"这个月有%d天", numberInMonth);
                
                int hourGood = 0;
                int hourNormal = 0;
                int hourBad = 0;
                
                for (int i = 1; i <= numberInMonth; i++)
                {
                    NSArray *arrValue = [self getDeepNormalShallowHoursByYear:_yearSub2 month:_monthSub2 day:(NSInteger)i other:0];
                    if (arrValue.count==4) {
                        numberUnknow++;
                    }else{
                        int level = [self getSleepLevel:arrValue];
                        numberGood += (level == 3?1:0);
                        numberNormal += (level == 2?1:0);
                        numberBad += (level == 1?1:0);
                        
                        hourGood += [arrValue[0] intValue];
                        hourNormal += [arrValue[1] intValue];
                        hourBad += [arrValue[2] intValue];
                    }
                }
                
//                良好 31, 一般 0, 较差 7, 未知 99
//                
//                numberGood   = 31;
//                numberNormal = 0;
//                numberBad    = 7;
//                numberUnknow = 32;
//                
//                numberInMonth = numberGood + numberNormal + numberBad + numberUnknow;
                
                
                NSLog(@"良好 %d, 一般 %d, 较差 %d, 未知 %d", numberGood, numberNormal, numberBad, numberUnknow);
                perGood = (int)((numberGood / (double)numberInMonth) * 100);
                perNormal = (int)((numberNormal / (double)numberInMonth) * 100);
                perBad = (int)((numberBad / (double)numberInMonth) * 100);
                perUnknow = (int)((numberUnknow / (double)numberInMonth) * 100);
                
                
                
                self.valueArray = [self getValueData];
                [self refreshColorArry];
                
                self.lbl4.text = [self getTimeStringByHours:hourGood days:(numberInMonth - numberUnknow)];
                self.lbl5.text = [self getTimeStringByHours:hourNormal days:(numberInMonth - numberUnknow)];
                self.lbl6.text = [self getTimeStringByHours:hourBad days:(numberInMonth - numberUnknow)];
                self.lbl10.text = [NSString stringWithFormat:@"%d%@", numberGood, kString(@"天")];
            }
                break;
            case 3:
            {
                isTag = YES;
                numberGood = numberNormal = numberBad = numberUnknow = 0;
                MBShowAll;
                DDWeak(self)
                NextWaitInGlobal(
                        [weakself getDataForYearInBackground];
                );
            }
                break;
        }
    }
    else
    {
        [_arrDay enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            _arrDay[idx] = @0;
        }];
        
        if (self.arrDataForFriend)
        {
            [self getIndexFromFirendData];
            if (indexInArrData >= 0)
            {
                [_arrDay enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    _arrDay[idx] = @0;
                }];
                
                
                NSArray *arrValue = [self getDeepNormalShallowHoursInFriend];
                
                self.lbl4.text = [NSString stringWithFormat:@"%@%@", arrValue[0],kString(@"小时")];
                self.lbl5.text = [NSString stringWithFormat:@"%@%@", arrValue[1],kString(@"小时")];
                self.lbl6.text = [NSString stringWithFormat:@"%@%@", arrValue[2],kString(@"小时")];
                
                switch ([self getSleepLevel:arrValue]) {
                    case 3:
                        self.lbl10.text = kString(@"良好");
                        break;
                    case 2:
                        self.lbl10.text = kString(@"一般");
                        break;
                    case 1:
                        self.lbl10.text = kString(@"较差");
                        break;
                }
            }
        }
    }
    
    if (isTag) return;
    [self refreshYMax];
    [self updatlblTime];
    [self checkData];
    [self changeUUChart];
}

-(void)getDataForYearInBackground
{
    int beginDay = [DFD HmF2KDateToInt:[@[@(_yearSub3),@1,@1] mutableCopy]];
    int endDay;
    if (DDYear != _yearSub3) {           // 选中的不是今年
        numberInYear = [DFD yearDay:(int)_yearSub3];
        endDay = [DFD HmF2KDateToInt:[@[@(_yearSub3),@12,@31] mutableCopy]];
    }else{
        endDay = [DFD HmF2KNSDateToInt:DNow];
        NSDate *dayFirstInThisYear = [DFD getDateFromArr:[@[@(_yearSub3),@1,@1] mutableCopy]];
        numberInYear = [DNow timeIntervalSinceDate:dayFirstInThisYear] / (60 * 60 * 24) + 1;
    }
    
    NSLog(@"这一年有%d天", numberInYear);
    int hourGood = 0;
    int hourNormal = 0;
    int hourBad = 0;
    
    int countFor = endDay - beginDay + 1;   // 循环的时候，使用 8321 这种叠加
    
    for (int i = 0; i < countFor; i++)
    {
        if ([DFD HmF2KNSIntToDate:(int)(beginDay+i)]) // 然后过滤
        {
            NSMutableArray *arrDatetime = [DFD HmF2KIntToDate:(int)(beginDay+i)];
            NSArray *arrValue           = [self getDeepNormalShallowHoursByYear:[arrDatetime[0] integerValue] month:[arrDatetime[1] integerValue] day:[arrDatetime[2] integerValue] other:0];
            if (arrValue.count==4)
            {
                numberUnknow++;
            }
            else
            {
                int level                   = [self getSleepLevel:arrValue];
                numberGood                  += (level == 3?1:0);
                numberNormal                += (level == 2?1:0);
                numberBad                   += (level == 1?1:0);
                hourGood                    += [arrValue[0] intValue];
                hourNormal                  += [arrValue[1] intValue];
                hourBad                     += [arrValue[2] intValue];
            }
        }
    }
    
    // 实际中数总天数
    numberInYear = numberGood + numberNormal + numberBad + numberUnknow;
    NSLog(@"良好 %d, 一般 %d, 较差 %d, 未知 %d", numberGood, numberNormal, numberBad, numberUnknow);
    perGood   = (int)((numberGood   / (double)numberInYear) * 100);
    perNormal = (int)((numberNormal / (double)numberInYear) * 100);
    perBad    = (int)((numberBad    / (double)numberInYear) * 100);
    perUnknow = (int)((numberUnknow / (double)numberInYear) * 100);
    
    
    self.valueArray = [self getValueData];
    [self refreshColorArry];
    
    DDWeak(self)
    NSArray *arr = @[@(hourGood),@(hourNormal),@(hourBad)];
    NextWaitInMain(
           DDStrong(self)
           [self getDataForYearInMain:arr];);
}

-(void)getDataForYearInMain:(NSArray *)arr
{
    self.lbl4.text = [self getTimeStringByHours:[arr[0] intValue] days:(numberInYear - numberUnknow)];
    self.lbl5.text = [self getTimeStringByHours:[arr[1] intValue] days:(numberInYear - numberUnknow)];
    self.lbl6.text = [self getTimeStringByHours:[arr[2] intValue] days:(numberInYear - numberUnknow)];
    self.lbl10.text = [NSString stringWithFormat:@"%d%@", numberGood, kString(@"天")];
    [self refreshYMax];
    [self updatlblTime];
    [self checkData];
    [self changeUUChart];
    MBHide;
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
                strResult = [NSString stringWithFormat:@"%d-%d-%d", (int)_monthSub1, (int)_daySub1, (int)_yearSub1];
            }
        }
            break;
        case 2:
        {
            if ([self.userInfo.unit boolValue] == 1) {
                strResult = [NSString stringWithFormat:@"%d-%d", (int)_yearSub2, (int)_monthSub2];
            }else{
                strResult = [NSString stringWithFormat:@"%d-%d", (int)_monthSub2, (int)_yearSub2];
            }
        }
            break;
        case 3:
            strResult = [NSString stringWithFormat:@"%d", (int)_yearSub3];
            break;
            
        default:
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
}

-(void)changeUUChart
{
    if (_uuchart) [_uuchart removeFromSuperview];
    if (_pieContainer)
    {
        self.pieChartView.delegate = nil;
        [self.pieChartView removeFromSuperview];
        self.pieContainer.hidden = self.pieChartView.hidden = self.selLabel.hidden = self.selView.hidden = YES;
    }
    
    if (_indexSub == 1)
    {
        CGRect rect = CGRectMake(5, 0, ScreenWidth - 10, viFirstHeight);
        _uuchart = [[UUChart alloc] initwithUUChartDataFrame:rect withSource:self withStyle:UUChartBarStyle isSpecial:YES arrColor:@[RGB(116, 42, 202), RGB(54, 136, 248), RGB(250, 102, 20)]];
        _uuchart.backgroundColor = DClear;
        _uuchart.Interval = 1;
        _uuchart.xLblIsAlighLeft = YES;
        [_uuchart showInView:_viewFirst];
    }else
    {
        if (self.pieContainer)
        {
            self.pieContainer.hidden = self.pieChartView.hidden = self.selLabel.hidden = self.selView.hidden = NO;
            self.pieChartView = [[PieChartView alloc]initWithFrame:self.pieContainer.bounds withValue:self.valueArray withColor:[self.colorArray mutableCopy]];
            self.pieChartView.delegate = self;
            [self.pieContainer addSubview:self.pieChartView];
        }else
        {
            CGRect pieFrame = CGRectMake((ScreenWidth - PIE_HEIGHT) / 2, (viFirstHeight - PIE_HEIGHT) / 2 - 15, PIE_HEIGHT, PIE_HEIGHT);
            self.pieContainer = [[UIView alloc] initWithFrame:pieFrame];
            self.pieChartView = [[PieChartView alloc]initWithFrame:CGRectMake(0, 0, PIE_HEIGHT, PIE_HEIGHT) withValue:self.valueArray withColor:[self.colorArray mutableCopy]];
            
            self.pieChartView.delegate = self;
            [self.pieContainer addSubview:self.pieChartView];
            [self.viewFirst addSubview:self.pieContainer];
            
            self.selView = [[UIImageView alloc]init];
            self.selView.image = [UIImage imageNamed:@"select_pie"];
            CGFloat width = IPhone4 ? 30 : 50;
            self.selView.frame = CGRectMake((ScreenWidth - width)/2, viFirstHeight - width - 30 - (IPhone4 ? 0 : 15), width, width);
            [self.viewFirst insertSubview:self.selView aboveSubview:self.pieContainer];
            
            self.selLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, viFirstHeight - 30 - (IPhone4 ? 0 : 10), ScreenWidth, 21)];
            self.selLabel.backgroundColor = [UIColor clearColor];
            self.selLabel.textAlignment = NSTextAlignmentCenter;
            int tagFont = 12;
            if (IPhone5) tagFont = 13;
            if (IPhone6) tagFont = 15;
            if (IPhone6P) tagFont = 17;
            self.selLabel.font = [UIFont systemFontOfSize:tagFont];
            self.selLabel.textColor = [UIColor whiteColor];
            
            [_viewFirst addSubview:self.selLabel];
        }
        
        [self.pieChartView reloadChart];
    }
}


-(void)initView
{
    if (IPhone4)        viFirstHeight = RealHeight(480);
    else if (IPhone5)   viFirstHeight = RealHeight(520);
    else                viFirstHeight = RealHeight(595);
    
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    _viewMain.backgroundColor = _viewHead.backgroundColor = DidSleepColor;
    _viewHeadHeight.constant = NavBarHeight+3;  // 防止点击
    _viewFirstHeight.constant = viFirstHeight;
    _btnMonthHeight.constant =  Bigger(RealHeight(50), 30);
    _lblTimeTop.constant = Bigger(RealHeight(50), 30) + NavBarHeight + 1;
    //Border(_lblScore, DRed);
    [_imvCalendar setHidden:NO];
    
    [_btnDay setTitle:kString(@"日") forState:UIControlStateNormal];
    [_btnMonth setTitle:kString(@"月") forState:UIControlStateNormal];
    [_btnYear setTitle:kString(@"年") forState:UIControlStateNormal];
    
    _lblTime.text = [DFD dateToString:DNow stringType:@"YYYY-MM-dd"];;
    
    _lbl8.hidden = _lbl9.hidden = _lbl11.hidden = _lbl12.hidden = _lineLast.hidden = _lineSecondLast.hidden = YES;
    _lbl2Top.constant = _lbl5Top.constant = _lbl11Top.constant = 10;
    if (IPhone4) {
        _lbl8Top.constant = 20;
    }
    
    
    if (IPhone4)        PIE_HEIGHT = RealWidth(310);
    else if (IPhone5)   PIE_HEIGHT = RealHeight(350);
    else if (IPhone6)   PIE_HEIGHT = RealHeight(451);
    else if (IPhone6P)   PIE_HEIGHT = RealHeight(461);
    
    
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
    [self initPrompt];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self selectTabIndex:1];
        [self initViewCover:300 toolBarColor:DidSleepColor];
        [self initDatePickerView];
    });
}

-(void)initPrompt
{
    CGFloat width = IPhone4 ? 12 : 16;
    
    viewPrompt = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - width * 4 - ([DFD getLanguage] == 1 ? -10 : 10), 0, width * 4, width * 4)];
    [_viewFirst addSubview:viewPrompt];
    for (int i = 0; i < 4; i++)
    {
        UIView *viewColor = [[UIView alloc] initWithFrame:CGRectMake(0, i * width + 2, width - 4, width - 4)];
        UILabel *lblPrompt = [[UILabel alloc] initWithFrame:CGRectMake(width, i * width, 45, width)];
        switch (i) {
            case 0:
                viewColor.backgroundColor = DDColorNumber1;
                lblPrompt.text = kString(@"良好");
                break;
            case 1:
                viewColor.backgroundColor = DDColorNumber2;
                lblPrompt.text = kString(@"一般");
                break;
            case 2:
                viewColor.backgroundColor = DDColorNumber3;
                lblPrompt.text = kString(@"较差");
                break;
            case 3:
                viewColor.backgroundColor = DWhite;
                lblPrompt.text = kString(@"未知");
                break;
        }
        viewColor.layer.cornerRadius = 5;
        viewColor.layer.masksToBounds = YES;
        [viewPrompt addSubview:viewColor];
        lblPrompt.textColor = DWhite;
        lblPrompt.font = [UIFont systemFontOfSize:10];
        [viewPrompt addSubview:lblPrompt];
    }
}

-(void)selectTabIndex:(NSInteger)ind
{
    _btnDay.backgroundColor = _btnMonth.backgroundColor = _btnYear.backgroundColor = DClear;
    [_imvCalendar setHidden:YES];
    viewPrompt.hidden = NO;
    _indexSub = ind;
    switch (ind) {
        case 1:
        {
            viewPrompt.hidden = YES;
            _btnDay.backgroundColor = DWhite3;
            _lbl1.text = kString(@"深度睡眠");
            _lbl2.text = kString(@"中度睡眠");
            _lbl3.text = kString(@"浅度睡眠");
            _lbl7.text = kString(@"睡眠质量");
            _imvCalendarRight.constant = 0;
            if(!_model) [_imvCalendar setHidden:NO];
            
        }
            break;
        case 2:
        {
            _btnMonth.backgroundColor = DWhite3;
            _lbl1.text = kString(@"日均深度睡眠");
            _lbl2.text = kString(@"日均中度睡眠");
            _lbl3.text = kString(@"日均浅度睡眠");
            _lbl7.text = kString(@"睡眠良好天数");
            _imvCalendarRight.constant = -10;
            if(!_model) [_imvCalendar setHidden:NO];
        }
            break;
        case 3:
        {
            _btnYear.backgroundColor = DWhite3;
            _lbl1.text = kString(@"日均深度睡眠");
            _lbl2.text = kString(@"日均中度睡眠");
            _lbl3.text = kString(@"日均浅度睡眠");
            _lbl7.text = kString(@"睡眠良好天数");
        }
            break;
            
        default:
            break;
    }
    
    [self loadData];
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
            
            if (_indexSub != 1) _monthPicker.monthPickerDelegate = self;
            
            self.btnTime.enabled = self.btnDay.enabled = self.btnMonth.enabled = self.btnYear.enabled = NO;
            DDWeak(self)
            NextWaitInMainAfter(
                    DDStrong(self)
                    if(self) self.btnTime.enabled = self.btnDay.enabled = self.btnMonth.enabled = self.btnYear.enabled = YES;, 1);
            
            [self showViewCover];
        }
            break;
            
            
        default:
            break;
    }
}


#pragma mark UUChartDataSource
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    NSMutableArray *arrHour = [NSMutableArray new];

    if (left < right) {
        for (int i = 0; i < number + 1; i++) {
            [arrHour addObject:@(left + i)];
        }
    }else
    {
        for (int i = 0; i < (24 - left); i++) {
            [arrHour addObject:@(left+i)];
        }
        
        for (int i = 0; i < (number - (24 - left)) + 1; i++) {
            [arrHour addObject:@(i)];
        }
    }
    
    
    for (int i = 0; i < arrHour.count; i++) {
        if (![DFD isSysTime24]) {
            arrHour[i] = [arrHour[i] description];
            if ([arrHour[i] intValue] == 0) {
                arrHour[i] = @"AM";
            }else if ([arrHour[i] intValue] == 12) {
                arrHour[i] = @"PM";
            }else if ([arrHour[i] intValue] > 12){
                arrHour[i] = [NSString stringWithFormat:@"%d", [arrHour[i] intValue] - 12];
            }
        }else
            arrHour[i] = [arrHour[i] description];
    }
    
    return arrHour;
}

- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index{
    return NO;
}

//数值多重数组 (数组中嵌套数组)
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    return  @[_arrDay];
}

//
//显示数值范围  (Y轴区间)
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    return CGRangeMake(3, 0);
}

-(void)getIndexFromFirendData
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

-(void)getYesterdayIndexFromFirendData
{
    indexYesterdayInArrData = -1;
    
    int dateValue = [DFD HmF2KDateToInt:[@[@(_yearSub1), @(_monthSub1), @(_daySub1)] mutableCopy]];
    NSDate *yesterday = [DFD HmF2KNSIntToDate:dateValue - 1];
   
    int dayYesterday = [yesterday getFromDate:3];
    
    for (int i = 0; i < self.arrDataForFriend.count; i++)
    {
        NSDictionary *dic_Sub = self.arrDataForFriend[i];
        if ([dic_Sub[@"day"] integerValue] == dayYesterday ) {
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
    
    _monthPicker = [[SRMonthPicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256 + NavBarHeight, ScreenWidth, 256)];
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
    if(_indexSub == 1)
    {
        NSLog(@"选择的日期  %@", _datePicker.date);
        
        NSInteger yearTag  = [_datePicker.date getFromDate:1];
        NSInteger monthTag = [_datePicker.date getFromDate:2];
        NSInteger dayTag   = [_datePicker.date getFromDate:3];
        
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

- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker
{
    NSInteger min = [[k_date_min_str substringToIndex:6] integerValue];
    NSInteger max = [[k_date_max_str substringToIndex:6] integerValue];
    NSInteger select = [[monthPicker.date toString:@"YYYYMM"] integerValue];
    //NSLog(@"---- %@, k_date_min_str: %d, k_date_max_str:%d",  [self formatDate:monthPicker.date],min, max);
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}



// 通过 年 月 日 获取 深睡 中睡 浅睡 小时数   other:额外的操作   1：操作日 2：
-(NSArray *)getDeepNormalShallowHoursByYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day other:(int)other{
    
    NSLog(@"%d-%d-%d", (int)year, (int)month, (int)day);
    int numberDeep = 0;
    int numberModerate = 0;
    int numberShallow = 0;
    if (left < right)  // 只拿今天的数据
    {
        NSMutableArray *arrDate = [@[ @(year), @(month), @(day) ] mutableCopy];
        NSDate *dateSelected = [DFD getDateFromArr:arrDate];
        
        NSLog(@"%@,%@", self.userInfo.access, dateSelected);
        DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelected] inContext:DBefaultContext];
        if(dr && [dr.step_count intValue])
        {
            NSArray *arrHour = [dr.step_array componentsSeparatedByString:@","];
            for (int i = 0; i < number; i++)
            {
                NSNumber *num = [self getNumberFromStep:arrHour[left+i]];
                if (other == 1) _arrDay[i] = num;
                numberShallow  += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep     += ([num intValue] == 3 ? 1:0);
            }
        }else
        {
            NSLog(@"没有今天的数据  ，，，， 擦擦擦");
        }
    }else                   // 拿一部分昨天的数据
    {
        NSMutableArray *arrDateToday = [@[ @(year), @(month), @(day) ] mutableCopy];
        NSDate *dateSelectedToday = [DFD getDateFromArr:arrDateToday];
        
        int yesterdayInt = [self getNextDayByThisDay:[DFD HmF2KDateToInt:arrDateToday] isPre:YES];
        NSDate *dateSelectedYesterday = [DFD getDateFromArr:[DFD HmF2KIntToDate:yesterdayInt]];
        
        DataRecord *drYesterday = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelectedYesterday] inContext:DBefaultContext];
        
        DataRecord *drToday = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelectedToday] inContext:DBefaultContext];
        
        if (drYesterday && [drYesterday.step_count intValue])
        {
            NSArray *arrHour = [drYesterday.step_array componentsSeparatedByString:@","];
            for (int i = 0; i < (24 - left); i++) {
                NSNumber *num = [self getNumberFromStep:arrHour[left+i]];
                if (other == 1) _arrDay[i] = num;
                numberShallow  += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep     += ([num intValue] == 3 ? 1:0);
            }
            
        }else{
            //NSLog(@"------------------------没有昨天的数据");
        }
        
        if (drToday && [drToday.step_count intValue])
        {
            NSArray *arrHour = [drToday.step_array componentsSeparatedByString:@","];
            for (int i = 0; i < (number - (24 - left)); i++) {
                NSNumber *num = [self getNumberFromStep:arrHour[i]];
                if (other == 1) _arrDay[(24 - left) + i] = num;
                numberShallow  += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep     += ([num intValue] == 3 ? 1:0);
            }
        }else{
            //NSLog(@"------------------------没有今天的的数据");
        }
    }
    
    // 如果没有这天的数据，返回4个数量的数组， 否则返回3个
    if (!numberDeep && !numberModerate && !numberShallow) {
        NSLog(@"这有一天未知的");
        return @[@(numberDeep),@(numberModerate),@(numberShallow),@0];
    }
    return @[@(numberDeep),@(numberModerate),@(numberShallow)];
}

-(NSArray *)getDeepNormalShallowHoursInFriend{
    
    int numberDeep = 0;
    int numberModerate = 0;
    int numberShallow = 0;
    
    NSDictionary *dicToday; //= self.arrDataForFriend[indexInArrData];
    NSString *sport_today;// = dicToday[@"sport_data"];
    int       stepNumber_today = 0;
    
    if (indexInArrData >=0) {
        dicToday = self.arrDataForFriend[indexInArrData];
        sport_today = dicToday[@"sport_array"];
        stepNumber_today = [dicToday[@"sport_num"] intValue];
    }
    
    if (left < right)  // 只拿今天的数据
    {
        NSArray *arrHour = [sport_today componentsSeparatedByString:@","];
        if (arrHour.count == 24 && stepNumber_today) {
            for (int i = 0; i < number; i++)
            {
                NSNumber *num = [self getNumberFromStep:arrHour[left+i]];
                _arrDay[i] = num;
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }
    }else                   // 拿一部分昨天的数据
    {
        NSDictionary *dicYesterday;// = self.arrDataForFriend[indexYesterdayInArrData];
        NSString *sport_yeaterday;// = dicToday[@"sport_data"];
        int       stepNumber_yesterday = 0;
        if (indexYesterdayInArrData >= 0) {
            dicYesterday = self.arrDataForFriend[indexYesterdayInArrData];
            sport_yeaterday = dicYesterday[@"sport_array"];
            stepNumber_yesterday = [dicYesterday[@"sport_num"] intValue];
        }
        
        
        NSArray *arrHour = [sport_yeaterday componentsSeparatedByString:@","];
        if (arrHour.count == 24 && stepNumber_yesterday) {
            for (int i = 0; i < (24 - left); i++)
            {
                NSNumber *num = [self getNumberFromStep:arrHour[left+i]];
                _arrDay[i] = num;
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }
        
        
        arrHour = [sport_today componentsSeparatedByString:@","];
        if (arrHour.count == 24 && stepNumber_today) {
            for (int i = 0; i < (number - (24 - left)); i++)
            {
                NSNumber *num = [self getNumberFromStep:arrHour[i]];
                _arrDay[(24 - left) + i] = num;
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }
    }
    
    // 如果没有这天的数据，返回4个数量的数组， 否则返回3个
    if (!numberDeep && !numberModerate && !numberShallow) {
        return @[@(numberDeep),@(numberModerate),@(numberShallow),@0];
    }
    return @[@(numberDeep),@(numberModerate),@(numberShallow)];
}


#pragma mark - PieChartDelegate
- (void)selectedFinish:(PieChartView *)pieChartView index:(NSInteger)index percent:(float)per
{
    NSInteger indexForChange = [self getSelectIndexForChange:index];
    
    //NSLog(@"%d, %d", index, indexForChange);
    // 坑爹的第三方，有时候会有问题
    int value = (int)(per * 100);
    if (indexForChange == 0 && value != perGood) {
        indexForChange = 3;
    }else if (indexForChange == 3 && value != perUnknow && perUnknow != perGood) {
        indexForChange = 0;
    }
    
    // NSLog(@"%d", index);
    
    switch (indexForChange) {
        case 0:
            self.selLabel.text = [NSString stringWithFormat:@"%@:%d %@",kString(@"良好睡眠"), numberGood,kString(@"天")];
            break;
        case 1:
            self.selLabel.text = [NSString stringWithFormat:@"%@:%d %@",kString(@"一般睡眠"), numberNormal,kString(@"天")];
            break;
        case 2:
            self.selLabel.text = [NSString stringWithFormat:@"%@:%d %@",kString(@"较差睡眠"), numberBad,kString(@"天")];
            break;
        case 3:
        case -1:
            self.selLabel.text = [NSString stringWithFormat:@"%@:%d %@",kString(@"未知"), numberUnknow,kString(@"天")];
            break;
    }
}

-(int)getSelectIndexForChange:(NSInteger)index{
    NSArray *arr = @[ @(numberGood), @(numberNormal), @(numberBad), @(numberUnknow) ];
    for (int i = 0; i < 4; i++) {
        
        if ([arr[i] intValue] != 0) {
            index--;
        }
        
        if (index < 0) {
            return i;
        }
        
    }
    return -1;
}

-(NSMutableArray *)getValueData
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
    if (numberGood) [arr addObject:@(numberGood)];
    if (numberNormal) [arr addObject:@(numberNormal)];
    if (numberBad) [arr addObject:@(numberBad)];
    if (numberUnknow) [arr addObject:@(numberUnknow)];
    //NSLog(@"arr %@", arr);
    return arr;
}

-(void)refreshColorArry
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
    if (numberGood) [arr addObject:DDColorNumber1];
    if (numberNormal) [arr addObject:DDColorNumber2];
    if (numberBad) [arr addObject:DDColorNumber3];
    if (numberUnknow) [arr addObject:DWhite];
    self.colorArray = [arr mutableCopy];
}


@end
