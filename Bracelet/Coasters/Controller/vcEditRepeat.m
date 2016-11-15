//
//  vcEditRepeat.m
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcEditRepeat.h"

@interface vcEditRepeat () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *arrRepeat;
    NSString *      strRepeat;
}
@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;



@property (nonatomic, strong) UITableView *                 tabView;
@property (nonatomic, strong) NSArray *                     arrData;

@end

@implementation vcEditRepeat

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLeftButtonisInHead:nil text:@"重复"];
    
    [self initView];
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DHL"] forBarMetrics:UIBarMetricsDefault];
}

//-(void)initLeftButton:(NSString *)imgName text:(NSString *)text
//{
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(17, (NavBarHeight - 35 ) / 2 + 10, 80, 35)];
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    btn.titleLabel.font = [UIFont systemFontOfSize:15];
//    btn.titleLabel.textColor = DWhite;
//    [btn setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
//    [btn setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
//    
//    [btn setTitle:kString(text) forState: UIControlStateNormal];
//    [btn setImageEdgeInsets: UIEdgeInsetsMake(6, -5, 6, 0)];
//    [btn setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -70)];
//    [btn setTitleColor:DWhite forState:UIControlStateNormal];
//    [btn setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
//    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    [self.viewHead addSubview:btn];
//    
//    self.viewHead.backgroundColor = DidConnectColor;
//    self.viewHeadHeight.constant = NavBarHeight;
//}

-(void)initView
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight)];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(88), 50);
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.backgroundColor = DLightGrayBlackGroundColor;
    [self.view addSubview:self.tabView];
    
    UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 19, ScreenWidth, 1)];
    [viewHead addSubview:viewLine];
    viewLine.backgroundColor = RGBA(211, 210, 214, 0.8);
    self.tabView.tableHeaderView = viewHead;
    UIView *viewLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    viewLine2.backgroundColor = RGBA(211, 210, 214, 0.8);
    self.tabView.tableFooterView = viewLine2;
}

-(void)initData
{
    self.arrData = @[ kString(@"每周日"), kString(@"每周一"),kString(@"每周二"),kString(@"每周三"),kString(@"每周四"),kString(@"每周五"),kString(@"每周六"),];
    arrRepeat = [[self.clock.repeat componentsSeparatedByString:@"-"] mutableCopy];
}

-(void)refreshArrRepeat
{
    strRepeat = [arrRepeat componentsJoinedByString:@"-"];
}

-(void)back
{
    [self.delegate changeRepeat:arrRepeat];
    [super back];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 7;
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"Cell"; // 标识符
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;                        //选中cell时无色
    }
    cell.textLabel.text = self.arrData[indexPath.row];
    if ([arrRepeat[indexPath.row] boolValue])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([arrRepeat[indexPath.row] boolValue])
    {
        arrRepeat[indexPath.row] = @"0";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        arrRepeat[indexPath.row] = @"1";
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self refreshArrRepeat];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

@end
