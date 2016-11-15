//
//  vcClock.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcClock.h"
#import "vcEditClock.h"
#import "tvcClock.h"

#define bigTimeInterval                        5 * 60  //   大循环间隔时间

@interface vcClock () <tvcClockDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL isLeft;                                         // 是否已经离开了页面
    NSTimer * timeF;                                     // 循环 读取 硬件
    NSTimer * timeBig;                                   // 大循环
    BOOL isRefresh;                                      // 是否已经刷新
    BOOL isAdd;                                          // 是否是去添加
    UILabel *lblNone;                                    // 没有闹钟
//    NSTimer * timer;
    
    BOOL isReadOK;                                       // 读取是否，已经OK, 是否已经可以跳转
}

@property (nonatomic, strong) NSMutableArray *              arrData;
@property (nonatomic, strong) IBOutlet UITableView *                 tabView;
@property (weak, nonatomic) IBOutlet UIView *               viewBottom;
@property (weak, nonatomic) IBOutlet UILabel *              lblWarn;
@property (weak, nonatomic) IBOutlet UIView *viewHead;



@end

@implementation vcClock

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"闹钟"];
    self.lblWarn.text = kString(@"请先连接手环，再进行闹钟设置");
    self.view.backgroundColor = self.tabView.backgroundColor = DLightGrayBlackGroundColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    isLeft = NO;
    
    [self refreshData];

    [self.Bluetooth addObserver:self forKeyPath:@"isLink" options:NSKeyValueObservingOptionNew context:nil];
    
    [self changeViewByIsLink:self.Bluetooth.isLink];
    
    [self obserToClock];
    timeBig = [NSTimer scheduledTimerWithTimeInterval:bigTimeInterval target:self selector:@selector(obserToClock) userInfo:nil repeats:YES];
    
    if (self.Bluetooth.isLink){
        isReadOK = NO;
        [self.Bluetooth readClock:self.userInfo.pUUIDString];
        DDWeak(self)
        NextWaitInMainAfter([weakself refreshData];, 0.5);
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    isLeft = YES;
    [timeF DF_stop];
    [timeBig DF_stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.Bluetooth name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    @try {
        [self.Bluetooth removeObserver:self forKeyPath:@"isLink"];
    } @catch (NSException *exception) {}
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    NSLog(@"vcClock 被销毁");
}


-(void)back{
    if (!self.Bluetooth.isLink || (self.Bluetooth.isLink && isReadOK)) {
        [super back];
    }
}

-(void)refreshData
{
    if(isRefresh) return;
    [self.arrData removeAllObjects];
    // 这里要兼容旧的APP 
    self.arrData = [[Clock findAllSortedBy:@"iD" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"type != %@ ", @0] inContext:DBefaultContext] mutableCopy];
    NSMutableArray *arrIndex = [NSMutableArray new];
    for(int i = 0; i < self.arrData.count; i++)
    {
        Clock *cl = self.arrData[i];
        if (![cl.type boolValue]) {
            [arrIndex addObject:@(i)];
        }
    }
    for (int i = (int)(arrIndex.count) - 1; i >=0; i--) {
        [self.arrData removeObjectAtIndex:[arrIndex[i] intValue]];
    }
    
    if (lblNone) [lblNone setHidden:YES];
    
    if (!self.arrData.count)
    {
        NSLog(@"没有闹钟");
        if(!lblNone)
        {
            lblNone = [[UILabel alloc] initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, 50)];
            lblNone.textColor = DBlack;
            lblNone.tag = 78;
            lblNone.text = kString(@"未设置");
            lblNone.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            lblNone.textAlignment = NSTextAlignmentCenter;
            
            lblNone.font = [UIFont systemFontOfSize:16];
            [self.view addSubview:lblNone];
        }
        
        [lblNone setHidden:NO];
    }
    
    if (self.arrData.count != 8 && self.Bluetooth.isLink) {
        [self initRightButtonisInHead:@"Increase" text:nil];
    }else
    {
        [self initRightButtonisInHead:nil text:nil];
    }
    [self refreshView];
    [self.tabView reloadData];
}

-(void)refreshView
{
    self.tabView.rowHeight = Bigger(RealHeight(100), 60);// 60;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcClock" bundle:nil] forCellReuseIdentifier:@"tvcClock"];
    self.tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view;
    });
}

-(void)changeViewByIsLink:(BOOL)isLink
{
    DDWeak(self)
   if (isLink)
   {
       self.tabView.userInteractionEnabled = YES;
       NextWaitInMain(
              DDStrong(self)
              if(self){
                  [self obserToClock];
                  [self.viewBottom setHidden:YES];
                  [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DHL"] forBarMetrics:UIBarMetricsDefault];
              }
       );
   }
   else
   {
       self.tabView.userInteractionEnabled = NO;
       NextWaitInMain(
              DDStrong(self)
              if(self){
                  [self.viewBottom setHidden:NO];
                  [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DHL2"] forBarMetrics:UIBarMetricsDefault];
              }
       );
   }
}


// 监视 所有本地 不重复的闹钟， 当 时间已过， 就关闭掉  reload
-(void)obserToClock
{
    if( !self.Bluetooth.isLink || timeF) return;        // 外面 至少5分钟内  进入此方法一次
    for (int i = 0; i < self.arrData.count; i++)        // 判断时间， 在时间相差5分钟内 开启 循环读取
    {
        Clock *clock = self.arrData[i];
        
        NSDate *dateFrom = [[DFD getDateFromArr:@[ clock.hour, clock.minute, @0, @0]] clearTimeZone]; // 今天的时间
        NSTimeInterval interval = [dateFrom timeIntervalSinceDate:DNow];  // >0 证明 这个闹钟还没响 < 5 * 60  将在5分钟之内响
        //NSLog(@"interval = %f", interval);
        if ([clock.repeat isEqualToString:@"0-0-0-0-0-0-0"] && [clock.isOn boolValue] && interval > 0 && interval <= 5 * 60)
        {
            timeF = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(read) userInfo:nil repeats:YES];
            break;
        }
    }
}

-(void)read
{
    BOOL isAllOff = YES; 
    for (int i = 0; i < self.arrData.count; i++)
    {
        Clock *clock = self.arrData[i];
        if ([clock.isOn boolValue]) {
            isAllOff = NO;
            break;
        }
    }
    
    if (isAllOff)
    {
        [timeF DF_stop];
        timeF = nil;
    }
    
    [self.Bluetooth setValue:@(YES) forKey:@"isOnlySetClock"];
    [self.Bluetooth readClock:self.userInfo.pUUIDString];
    DDWeak(self)
    NextWaitInMainAfter([weakself refreshData];, 1);
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcClock *cell = [tvcClock cellWithTableView:tableView];
    Clock *model = self.arrData[indexPath.row];
    cell.imv1.highlightedImage = [UIImage imageNamed:@"lightGray.png"];
    cell.model = model;
    cell.delegate_S = self;
    
    MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
    cell.rightButtons = @[btnDelete];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    DDWeak(self)
    btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
    {
        Clock *cl = self.arrData[indexPath.row];
        cl.type = @0;
        cl.repeat = @"0-0-0-0-0-0-0";
        cl.hour = @0;
        cl.minute = @0;
        cl.isOn = @NO;
        [cl perfect];
        DBSave;
        DDStrong(self)
        [self.Bluetooth setClock:self.userInfo.pUUIDString];
        [self refreshData];
        return NO;
    };
    
    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Clock *model = self.arrData[indexPath.row];
    if (self.Bluetooth.isLink)
    {
        isAdd = NO;
        [self performSegueWithIdentifier:@"clock_to_editClock" sender:model];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"clock_to_editClock"])
    {
        vcEditClock *vc = (vcEditClock *)segue.destinationViewController;
        vc.isAdd = isAdd;
        vc.clock = sender;
    }
}


#pragma mark tvcClockDelegate
-(void)switchClock:(tvcClock *)sender
{
    Clock *cl = sender.model;
    NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@", cl.isOn, cl.strRepeat, cl.strTime, cl.type);
    cl.isOn = @(![cl.isOn boolValue]);
    DBSave;
    
    [self.Bluetooth setClock:self.userInfo.pUUIDString];
    DDWeak(self)
    NextWaitInMainAfter(
         DDStrong(self)
         [self refreshData];
         [self obserToClock];
         , 1);
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (isLeft)return;
    if ([object isEqual:self.Bluetooth] && [keyPath isEqual:@"isLink"])
        [self changeViewByIsLink:self.Bluetooth.isLink];
}


-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    
    isReadOK = YES;
    if (type == 307)
    {
        DDWeak(self)
        NextWaitInMain(
               DDStrong(self)
               if(self){
                   NSLog(@"回调回来了");
                   [self refreshData];
                   self.tabView.userInteractionEnabled = YES;
               });
    }
}

-(void)rightButtonClick
{
//    Clock *newClock = [[Clock findAllSortedBy:@"iD" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(strTime == %@) and (isOn == %@)", @" 00:00", @(NO)] inContext:DBefaultContext] firstObject];
    isAdd = YES;
    NSLog(@"跳转时间");
    [self performSegueWithIdentifier:@"clock_to_editClock" sender:nil];
}



@end
